import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/addresses.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

class CheckoutState extends StatefulWidget {
  const CheckoutState({super.key});

  @override
  State<CheckoutState> createState() => CheckoutPage();
}

class CheckoutPage extends State<CheckoutState> {
  String addressId = AllAddresses.defaultOf(AllUsers.activeEmail)?["id"] ?? "";
  String payment = "Cash on Delivery";
  bool placing = false;
  final notesController = TextEditingController();

  void chooseAddress() async {
    List<dynamic> list = AllAddresses.ofUser(AllUsers.activeEmail);
    String? picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Delivery Address", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              for (dynamic a in list)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(a["id"] == addressId ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.accent),
                  title: Text("${a["label"]} • ${a["recipient"]}", style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(AllAddresses.fullText(a)),
                  onTap: () => Navigator.pop(c, a["id"]),
                ),
              const SizedBox(height: 8),
              AppButton(label: "Add New Address", variant: "outline", icon: Icons.add, onPressed: () => Navigator.pop(c, "new")),
            ],
          ),
        ),
      ),
    );
    if (picked == null || !mounted) return;
    if (picked == "new") {
      AllAddresses.selectedId = "";
      await Navigator.pushNamed(context, "/addressform");
      //use the address that was just added
      List<dynamic> after = AllAddresses.ofUser(AllUsers.activeEmail);
      if (after.isNotEmpty) setState(() => addressId = after.last["id"]);
    } else {
      setState(() => addressId = picked);
    }
  }

  //CREATE - place the order
  Future<void> placeOrder(List<dynamic> cart, int subtotal) async {
    dynamic address = AllAddresses.find(addressId);
    if (address == null) {
      showToast(context, "Please add a delivery address.");
      return;
    }
    for (dynamic item in cart) {
      dynamic p = AllProducts.find(item["productId"]);
      if (item["qty"] > p["stock"]) {
        showToast(context, "${p["name"]} only has ${p["stock"]} left.");
        return;
      }
    }

    if (payment == "GCash") {
      bool paid = await simulateGCash(subtotal + AllOrders.deliveryFee);
      if (!paid) return;
    }

    setState(() => placing = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    List<dynamic> items = [];
    for (dynamic item in cart) {
      dynamic p = AllProducts.find(item["productId"]);
      items.add({"productId": p["id"], "name": p["name"], "price": p["price"], "qty": item["qty"], "image": p["image"]});
      p["stock"] = p["stock"] - item["qty"];
    }
    String code = "ORD-${AllOrders.orderCounter}";
    AllOrders.orderCounter++;
    dynamic order = {
      "id": Store.newId(),
      "code": code,
      "customer": AllUsers.activeEmail,
      "type": "Shop",
      "items": items,
      "subtotal": subtotal,
      "deliveryFee": AllOrders.deliveryFee,
      "total": subtotal + AllOrders.deliveryFee,
      "payment": payment,
      "recipient": address["recipient"],
      "phone": address["phone"],
      "address": AllAddresses.fullText(address),
      "status": "Pending",
      "worker": "",
      "notes": notesController.text.trim(),
      "qcNotes": "",
      "rated": false,
      "createdAt": Format.now(),
      "updatedAt": Format.now(),
      "timeline": [
        {"status": "Pending", "note": payment == "GCash" ? "Order placed and paid via GCash." : "Order placed by customer.", "date": Format.now()},
      ],
    };
    AllOrders.orderList.add(order);
    AllOrders.cartList.removeWhere((c) => c["email"] == AllUsers.activeEmail);
    AllActivity.notifyRole("owner", "New order $code", "${AllUsers.fullName(AllUsers.activeEmail)} placed an order (${AllOrders.itemSummary(order)}).", "order");
    AllActivity.notify(AllUsers.activeEmail, "$code • Order placed", "We received your order. We'll notify you once production starts.", "order");
    for (dynamic p in AllProducts.productList) {
      if (p["stock"] <= 2) AllActivity.notifyRole("owner", "Low product stock", "${p["name"]} only has ${p["stock"]} left.", "inventory");
    }
    Store.save();
    setState(() => placing = false);

    AllOrders.selectedId = order["id"];
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: AppColors.successBg, shape: BoxShape.circle),
              child: const Icon(Icons.check_rounded, color: AppColors.success, size: 42),
            ),
            const SizedBox(height: 16),
            const Text("Order Placed!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text("Your order $code was sent to Industrial Manila Furniture.", textAlign: TextAlign.center, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 20),
            AppButton(label: "Track Order", onPressed: () => Navigator.pop(c)),
          ],
        ),
      ),
    );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/order", ModalRoute.withName("/customer"));
  }

  Future<bool> simulateGCash(int total) async {
    bool? ok = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: false,
      builder: (c) => GCashSheet(total: total),
    );
    return ok == true;
  }

  Widget paymentOption(String value, String subtitle, IconData icon) {
    bool active = payment == value;
    return GestureDetector(
      onTap: () => setState(() => payment = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.accentSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.accent : AppColors.line, width: active ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ),
            Icon(active ? Icons.radio_button_checked : Icons.radio_button_off, color: AppColors.accent),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> cart = AllOrders.cartOf(AllUsers.activeEmail);
    int subtotal = 0;
    for (dynamic item in cart) {
      subtotal = subtotal + (AllProducts.find(item["productId"])["price"] as int) * (item["qty"] as int);
    }
    dynamic address = AllAddresses.find(addressId);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionTitle("Delivery Address"),
          AppCard(
            onTap: () => chooseAddress(),
            child: address == null
                ? const Row(
                    children: [
                      Icon(Icons.add_location_alt_outlined, color: AppColors.accent),
                      SizedBox(width: 12),
                      Expanded(child: Text("Add a delivery address", style: TextStyle(fontWeight: FontWeight.w600))),
                      Icon(Icons.chevron_right),
                    ],
                  )
                : Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("${address["recipient"]} • ${address["phone"]}", style: const TextStyle(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text(AllAddresses.fullText(address), style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      const Text("Change", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
          const SizedBox(height: 8),
          const SectionTitle("Payment Method"),
          paymentOption("Cash on Delivery", "Pay when your furniture arrives", Icons.payments_outlined),
          paymentOption("GCash", "Simulated e-wallet payment", Icons.account_balance_wallet_outlined),
          const SizedBox(height: 4),
          const SectionTitle("Order Summary"),
          AppCard(
            child: Column(
              children: [
                for (dynamic item in cart)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(width: 44, height: 44, child: ProductImage(AllProducts.find(item["productId"])["image"])),
                        const SizedBox(width: 10),
                        Expanded(child: Text("${AllProducts.find(item["productId"])["name"]}\nx${item["qty"]}", style: const TextStyle(fontSize: 13))),
                        Text(Format.peso((AllProducts.find(item["productId"])["price"] as int) * (item["qty"] as int)), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                const Divider(),
                InfoRow("Subtotal", Format.peso(subtotal)),
                InfoRow("Delivery fee", Format.peso(AllOrders.deliveryFee)),
                InfoRow("Total", Format.peso(subtotal + AllOrders.deliveryFee), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppTextField(controller: notesController, hint: "Notes for the shop (optional)", maxLines: 3, pill: false),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: placing
              ? const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(color: AppColors.black)))
              : AppButton(
                  label: "Place Order • ${Format.peso(subtotal + AllOrders.deliveryFee)}",
                  onPressed: cart.isEmpty ? null : () => placeOrder(cart, subtotal),
                ),
        ),
      ),
    );
  }
}

// simulated GCash payment screen
class GCashSheet extends StatefulWidget {
  final int total;
  const GCashSheet({super.key, required this.total});

  @override
  State<GCashSheet> createState() => GCashSheetState();
}

class GCashSheetState extends State<GCashSheet> {
  bool processing = false;

  Future<void> pay() async {
    setState(() => processing = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFF007DFE), borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 12),
            const Text("GCash Payment (Simulation)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            const Text("No real money will be charged.", style: TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            Text(Format.peso(widget.total), style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text("Pay to: Industrial Manila Furniture", style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 24),
            processing
                ? const Column(children: [CircularProgressIndicator(color: Color(0xFF007DFE)), SizedBox(height: 10), Text("Processing payment...")])
                : Row(
                    children: [
                      Expanded(child: AppButton(label: "Cancel", variant: "outline", onPressed: () => Navigator.pop(context, false))),
                      const SizedBox(width: 10),
                      Expanded(child: AppButton(label: "Pay Now", variant: "brown", onPressed: () => pay())),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
