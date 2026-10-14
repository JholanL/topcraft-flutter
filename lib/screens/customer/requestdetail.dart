import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../glob/orders.dart';
import '../../glob/addresses.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

class RequestDetailState extends StatefulWidget {
  const RequestDetailState({super.key});

  @override
  State<RequestDetailState> createState() => RequestDetailPage();
}

class RequestDetailPage extends State<RequestDetailState> {
  //UPDATE - approve the quote, this creates a custom order
  Future<void> approveQuote(dynamic r) async {
    dynamic address = AllAddresses.defaultOf(AllUsers.activeEmail);
    if (address == null) {
      showToast(context, "Please add a delivery address first (More > My Addresses).");
      return;
    }
    bool ok = await confirmDialog(context, "Approve Quotation", "Approve ${Format.peso(r["quotePrice"])} for ${r["code"]}? This will create a production order delivered to your ${address["label"]} address.", confirm: "Approve");
    if (!ok) return;

    int price = r["quotePrice"];
    int qty = r["quantity"];
    String code = "ORD-${AllOrders.orderCounter}";
    AllOrders.orderCounter++;
    String orderId = Store.newId();
    AllOrders.orderList.add({
      "id": orderId,
      "code": code,
      "customer": AllUsers.activeEmail,
      "type": "Custom",
      "items": [
        {"productId": "", "name": "Custom ${r["furnitureType"]} (${r["code"]})", "price": price ~/ qty, "qty": qty, "image": r["image"]},
      ],
      "subtotal": (price ~/ qty) * qty,
      "deliveryFee": AllOrders.deliveryFee,
      "total": (price ~/ qty) * qty + AllOrders.deliveryFee,
      "payment": "Cash on Delivery",
      "recipient": address["recipient"],
      "phone": address["phone"],
      "address": AllAddresses.fullText(address),
      "status": "Pending",
      "worker": "",
      "notes": "${r["material"]}, ${r["dimensions"]}. ${r["finish"]}. ${r["notes"]}",
      "qcNotes": "",
      "rated": false,
      "createdAt": Format.now(),
      "updatedAt": Format.now(),
      "timeline": [
        {"status": "Pending", "note": "Quotation ${r["code"]} approved by customer.", "date": Format.now()},
      ],
    });
    setState(() {
      r["status"] = "Approved";
      r["orderId"] = orderId;
      r["updatedAt"] = Format.now();
    });
    AllActivity.notifyRole("owner", "${r["code"]} approved", "${AllUsers.fullName(AllUsers.activeEmail)} approved the quote. Order $code was created.", "request");
    Store.save();
    if (mounted) showToast(context, "Quote approved! Order $code created.");
  }

  Future<void> rejectQuote(dynamic r) async {
    bool ok = await confirmDialog(context, "Decline Quotation", "Decline the quotation for ${r["code"]}?", confirm: "Decline", danger: true);
    if (!ok) return;
    setState(() {
      r["status"] = "Rejected";
      r["updatedAt"] = Format.now();
    });
    AllActivity.notifyRole("owner", "${r["code"]} declined", "${AllUsers.fullName(AllUsers.activeEmail)} declined the quotation.", "request");
    Store.save();
  }

  Future<void> withdraw(dynamic r) async {
    bool ok = await confirmDialog(context, "Withdraw Request", "Withdraw ${r["code"]}? The shop will stop reviewing it.", confirm: "Withdraw", danger: true);
    if (!ok) return;
    setState(() {
      r["status"] = "Withdrawn";
      r["updatedAt"] = Format.now();
    });
    Store.save();
  }

  //DELETE - remove a closed request
  Future<void> deleteRequest(dynamic r) async {
    bool ok = await confirmDialog(context, "Delete Request", "Delete ${r["code"]} permanently?", confirm: "Delete", danger: true);
    if (!ok || !mounted) return;
    AllRequests.requestList.remove(r);
    Store.save();
    showToast(context, "Request deleted");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    dynamic r = AllRequests.find(AllRequests.selectedId);
    if (r == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.design_services_outlined, title: "Request not found", subtitle: "It may have been deleted."));
    }
    String status = r["status"];

    return Scaffold(
      appBar: AppBar(
        title: Text(r["code"]),
        actions: [
          if (status == "Submitted")
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => Navigator.pushNamed(context, "/requestform").then((v) => setState(() {})),
            ),
          if (status == "Rejected" || status == "Withdrawn")
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteRequest(r)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          if (r["image"] != "")
            Container(
              height: 200,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: ProductImage(r["image"], fit: BoxFit.cover),
            ),
          Row(
            children: [
              Expanded(child: Text("Custom ${r["furnitureType"]}", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
              StatusPill(status),
            ],
          ),
          const SizedBox(height: 4),
          Text("Submitted ${Format.dateTime(r["createdAt"])}", style: const TextStyle(color: AppColors.muted, fontSize: 13)),
          const SizedBox(height: 16),
          if (status == "Submitted")
            const AppCard(
              color: AppColors.warningBg,
              child: Row(
                children: [
                  Icon(Icons.hourglass_top, color: AppColors.warning),
                  SizedBox(width: 12),
                  Expanded(child: Text("Our team is reviewing your request. You'll get a quotation soon.", style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          if (status == "Quoted" || status == "Approved" || (status == "Rejected" && r["quotePrice"] > 0))
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF2A211C), Color(0xFF5C3A28)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("QUOTATION", style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w700, letterSpacing: 1.2, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(Format.peso(r["quotePrice"]), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text("Production time: ${r["leadDays"]} days", style: const TextStyle(color: Colors.white70)),
                  if (r["quoteNote"] != "") const SizedBox(height: 8),
                  if (r["quoteNote"] != "") Text(r["quoteNote"], style: const TextStyle(color: Colors.white)),
                  if (status == "Quoted") const SizedBox(height: 16),
                  if (status == "Quoted")
                    Row(
                      children: [
                        Expanded(child: AppButton(label: "Decline", variant: "outline", onPressed: () => rejectQuote(r))),
                        const SizedBox(width: 10),
                        Expanded(child: AppButton(label: "Approve", variant: "light", onPressed: () => approveQuote(r))),
                      ],
                    ),
                ],
              ),
            ),
          if (status == "Approved" && AllOrders.find(r["orderId"]) != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: AppButton(
                label: "Track Production Order",
                icon: Icons.local_shipping_outlined,
                onPressed: () {
                  AllOrders.selectedId = r["orderId"];
                  Navigator.pushNamed(context, "/order").then((v) => setState(() {}));
                },
              ),
            ),
          const SizedBox(height: 8),
          const SectionTitle("Request Details"),
          AppCard(
            child: Column(
              children: [
                InfoRow("Type", r["furnitureType"]),
                InfoRow("Material", r["material"]),
                InfoRow("Dimensions", r["dimensions"]),
                InfoRow("Finish", r["finish"] == "" ? "-" : r["finish"]),
                InfoRow("Quantity", "${r["quantity"]}"),
                InfoRow("Budget", Format.peso(r["budget"])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Design notes", style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(r["notes"], style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
          if (status == "Submitted") const SizedBox(height: 16),
          if (status == "Submitted") AppButton(label: "Withdraw Request", variant: "outline", onPressed: () => withdraw(r)),
        ],
      ),
    );
  }
}
