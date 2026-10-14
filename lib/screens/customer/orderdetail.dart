import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/tasks.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// Customer order details (CustomerOrderDetailsPage of mobile-topcraft)
class OrderDetailState extends StatefulWidget {
  const OrderDetailState({super.key});

  @override
  State<OrderDetailState> createState() => OrderDetailPage();
}

class OrderDetailPage extends State<OrderDetailState> {
  String statusMessage(String status) {
    switch (status) {
      case "Pending":
        return "We received your order and will assign a craftsman soon.";
      case "In Production":
        return "Our craftsmen are building your furniture.";
      case "Quality Check":
        return "Your furniture is being inspected before delivery.";
      case "Out for Delivery":
        return "Your order is on the way to your address.";
      case "Completed":
        return "Delivered. Thank you for choosing Industrial Manila!";
      default:
        return "This order was cancelled.";
    }
  }

  //UPDATE - customer cancels while Pending
  Future<void> cancelOrder(dynamic order) async {
    String? reason = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Why are you cancelling?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              for (String r in ["Changed my mind", "Ordered by mistake", "Found a better price", "Delivery takes too long"])
                ListTile(contentPadding: EdgeInsets.zero, title: Text(r), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.pop(c, r)),
            ],
          ),
        ),
      ),
    );
    if (reason == null) return;
    setState(() {
      //return the stock of the products
      for (dynamic item in order["items"]) {
        dynamic p = AllProducts.find(item["productId"]);
        if (p != null) p["stock"] = p["stock"] + item["qty"];
      }
      AllOrders.setStatus(order, "Cancelled", "Cancelled by customer: $reason");
      AllActivity.notifyRole("owner", "${order["code"]} cancelled", "${AllUsers.fullName(order["customer"])}: $reason", "order");
    });
    Store.save();
    if (mounted) showToast(context, "Order cancelled");
  }

  //UPDATE - customer confirms that the furniture arrived
  Future<void> confirmReceipt(dynamic order) async {
    bool ok = await confirmDialog(context, "Confirm Receipt", "Did you receive your order in good condition?", confirm: "Yes, received");
    if (!ok) return;
    setState(() {
      AllOrders.setStatus(order, "Completed", "Customer confirmed receipt.");
      AllActivity.notifyRole("owner", "${order["code"]} completed", "${AllUsers.fullName(order["customer"])} confirmed receipt.", "order");
    });
    Store.save();
    if (mounted) rateProducts(order);
  }

  //CREATE - reviews for the products of the order
  Future<void> rateProducts(dynamic order) async {
    List<dynamic> items = [];
    for (dynamic item in order["items"]) {
      if (AllProducts.find(item["productId"]) != null) items.add(item);
    }
    if (items.isEmpty) {
      setState(() => order["rated"] = true);
      Store.save();
      return;
    }
    bool? saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (c) => RateSheet(order: order, items: items),
    );
    if (saved == true) {
      setState(() {});
      if (mounted) showToast(context, "Thank you for your review!");
    }
  }

  void orderAgain(dynamic order) {
    int added = 0;
    for (dynamic item in order["items"]) {
      dynamic p = AllProducts.find(item["productId"]);
      if (p != null && AllOrders.addToCart(AllUsers.activeEmail, p, item["qty"]).isEmpty) added++;
    }
    Store.save();
    if (added == 0) {
      showToast(context, "These items are not available right now.");
      return;
    }
    Navigator.pushNamed(context, "/cart").then((v) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    dynamic order = AllOrders.find(AllOrders.selectedId);
    if (order == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.receipt_long_outlined, title: "Order not found", subtitle: "It may have been removed by the shop."));
    }
    String status = order["status"];
    List<Color> c = AppColors.status(status);
    dynamic task = AllTasks.forOrder(order["id"]);

    List<Widget> actions = [];
    if (status == "Pending") actions.add(AppButton(label: "Cancel Order", variant: "outline", onPressed: () => cancelOrder(order)));
    if (status == "Out for Delivery") actions.add(AppButton(label: "Order Received", icon: Icons.inventory_outlined, onPressed: () => confirmReceipt(order)));
    if (status == "Completed" && order["rated"] == false) actions.add(AppButton(label: "Rate Products", icon: Icons.star_outline, onPressed: () => rateProducts(order)));
    if ((status == "Completed" || status == "Cancelled") && order["type"] == "Shop") {
      actions.add(AppButton(label: "Order Again", variant: "outline", icon: Icons.replay, onPressed: () => orderAgain(order)));
    }

    return Scaffold(
      appBar: AppBar(title: Text(order["code"])),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: c[0], borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Icon(status == "Completed" ? Icons.verified_outlined : status == "Cancelled" ? Icons.cancel_outlined : Icons.local_shipping_outlined, color: c[1], size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(status, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c[1])),
                      const SizedBox(height: 2),
                      Text(statusMessage(status), style: TextStyle(fontSize: 13, color: c[1])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (Widget a in actions) Padding(padding: const EdgeInsets.only(bottom: 10), child: a),
          const SectionTitle("Order Timeline"),
          AppCard(child: OrderTimeline(order: order, stages: AllOrders.stages)),
          if (order["worker"] != "") const SizedBox(height: 12),
          if (order["worker"] != "")
            AppCard(
              child: Row(
                children: [
                  Avatar(AllUsers.initials(order["worker"]), size: 40),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Your craftsman", style: TextStyle(fontSize: 12, color: AppColors.muted)),
                        Text(AllUsers.fullName(order["worker"]), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  if (task != null) StatusPill(task["progress"]),
                ],
              ),
            ),
          const SizedBox(height: 8),
          const SectionTitle("Items"),
          AppCard(
            child: Column(
              children: [
                for (dynamic item in order["items"])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(12)),
                          child: ProductImage(item["image"], iconSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["name"], style: const TextStyle(fontWeight: FontWeight.w700)),
                              Text("${Format.peso(item["price"])} x ${item["qty"]}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                            ],
                          ),
                        ),
                        Text(Format.peso((item["price"] as num) * (item["qty"] as num)), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                const Divider(),
                InfoRow("Subtotal", Format.peso(order["subtotal"])),
                InfoRow("Delivery fee", Format.peso(order["deliveryFee"])),
                InfoRow("Total", Format.peso(order["total"]), bold: true),
                InfoRow("Payment", order["payment"]),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SectionTitle("Delivery Details"),
          AppCard(
            child: Column(
              children: [
                InfoRow("Recipient", order["recipient"]),
                InfoRow("Phone", order["phone"]),
                InfoRow("Address", order["address"]),
                InfoRow("Placed on", Format.dateTime(order["createdAt"])),
                if (order["notes"] != "") InfoRow("Notes", order["notes"]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// bottom sheet for rating the products (RateProductModal of mobile-topcraft)
class RateSheet extends StatefulWidget {
  final dynamic order;
  final List<dynamic> items;
  const RateSheet({super.key, required this.order, required this.items});

  @override
  State<RateSheet> createState() => RateSheetState();
}

class RateSheetState extends State<RateSheet> {
  late List<int> ratings = List.filled(widget.items.length, 5);
  late List<TextEditingController> comments = List.generate(widget.items.length, (i) => TextEditingController());

  void submit() {
    for (int i = 0; i < widget.items.length; i++) {
      AllProducts.reviewList.add({
        "id": Store.newId(),
        "productId": widget.items[i]["productId"],
        "orderId": widget.order["id"],
        "customer": AllUsers.activeEmail,
        "rating": ratings[i],
        "comment": comments[i].text.trim(),
        "date": Format.now(),
      });
    }
    widget.order["rated"] = true;
    AllActivity.notifyRole("owner", "New review for ${widget.order["code"]}", "${AllUsers.fullName(AllUsers.activeEmail)} rated ${widget.items.length} product(s).", "review");
    Store.save();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Rate your products", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              const Text("Your feedback helps other customers.", style: TextStyle(color: AppColors.muted)),
              const SizedBox(height: 16),
              for (int i = 0; i < widget.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 44, height: 44, child: ProductImage(widget.items[i]["image"])),
                          const SizedBox(width: 10),
                          Expanded(child: Text(widget.items[i]["name"], style: const TextStyle(fontWeight: FontWeight.w700))),
                        ],
                      ),
                      Row(
                        children: [
                          for (int s = 1; s <= 5; s++)
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              onPressed: () => setState(() => ratings[i] = s),
                              icon: Icon(s <= ratings[i] ? Icons.star_rounded : Icons.star_outline_rounded, color: AppColors.warning, size: 32),
                            ),
                        ],
                      ),
                      TextField(
                        controller: comments[i],
                        decoration: InputDecoration(
                          hintText: "Share your experience (optional)",
                          filled: true,
                          fillColor: AppColors.surfaceSoft,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                    ],
                  ),
                ),
              AppButton(label: "Submit Review", onPressed: () => submit()),
            ],
          ),
        ),
      ),
    );
  }
}
