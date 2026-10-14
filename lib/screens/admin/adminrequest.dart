import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../glob/orders.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// owner reviews a custom request and sends a quotation (AdminInquiryDetailPage)
class AdminRequestState extends StatefulWidget {
  const AdminRequestState({super.key});

  @override
  State<AdminRequestState> createState() => AdminRequestPage();
}

class AdminRequestPage extends State<AdminRequestState> {
  dynamic r = AllRequests.find(AllRequests.selectedId);
  late final priceController = TextEditingController(text: r == null || r["quotePrice"] == 0 ? "" : "${r["quotePrice"]}");
  late final daysController = TextEditingController(text: r == null || r["leadDays"] == 0 ? "14" : "${r["leadDays"]}");
  late final noteController = TextEditingController(text: r?["quoteNote"] ?? "");

  //UPDATE - send or revise the quotation
  void sendQuote() {
    int? price = int.tryParse(priceController.text.replaceAll(",", ""));
    int? days = int.tryParse(daysController.text);
    if (price == null || price <= 0) {
      showToast(context, "Please enter the quotation price.");
      return;
    }
    if (days == null || days <= 0) {
      showToast(context, "Please enter the production days.");
      return;
    }
    bool revised = r["status"] == "Quoted";
    setState(() {
      r["quotePrice"] = price;
      r["leadDays"] = days;
      r["quoteNote"] = noteController.text.trim();
      r["status"] = "Quoted";
      r["updatedAt"] = Format.now();
    });
    AllActivity.notify(r["customer"], "${r["code"]} • ${revised ? "Quotation revised" : "Quotation ready"}", "We quoted ${Format.peso(price)} for your custom ${r["furnitureType"].toString().toLowerCase()} ($days days).", "request");
    AllActivity.log(AllUsers.activeEmail, "Sent quotation for ${r["code"]}");
    Store.save();
    showToast(context, "Quotation sent to ${AllUsers.fullName(r["customer"])}");
  }

  Future<void> rejectRequest() async {
    bool ok = await confirmDialog(context, "Reject Request", "Reject ${r["code"]}? The customer will be notified.", confirm: "Reject", danger: true);
    if (!ok) return;
    setState(() {
      r["status"] = "Rejected";
      r["updatedAt"] = Format.now();
    });
    AllActivity.notify(r["customer"], "${r["code"]} • Request declined", "Sorry, we can't take this custom request right now.", "request");
    Store.save();
  }

  //DELETE
  Future<void> deleteRequest() async {
    bool ok = await confirmDialog(context, "Delete Request", "Delete ${r["code"]} permanently?", confirm: "Delete", danger: true);
    if (!ok || !mounted) return;
    AllRequests.requestList.remove(r);
    Store.save();
    showToast(context, "Request deleted");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (r == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.design_services_outlined, title: "Request not found", subtitle: "It may have been deleted."));
    }
    String status = r["status"];
    bool canQuote = status == "Submitted" || status == "Quoted";

    return Scaffold(
      appBar: AppBar(
        title: Text(r["code"]),
        actions: [
          if (status == "Rejected" || status == "Withdrawn") IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteRequest()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            child: Row(
              children: [
                Avatar(AllUsers.initials(r["customer"]), size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AllUsers.fullName(r["customer"]), style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text("Submitted ${Format.dateTime(r["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                StatusPill(status),
              ],
            ),
          ),
          if (r["image"] != "") const SizedBox(height: 12),
          if (r["image"] != "")
            Container(
              height: 200,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
              clipBehavior: Clip.antiAlias,
              child: ProductImage(r["image"], fit: BoxFit.cover),
            ),
          const SectionTitle("Request"),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InfoRow("Type", r["furnitureType"]),
                InfoRow("Material", r["material"]),
                InfoRow("Dimensions", r["dimensions"]),
                InfoRow("Finish", r["finish"] == "" ? "-" : r["finish"]),
                InfoRow("Quantity", "${r["quantity"]}"),
                InfoRow("Budget", Format.peso(r["budget"]), bold: true),
                const Divider(),
                const Text("Design notes", style: TextStyle(fontSize: 12, color: AppColors.muted)),
                const SizedBox(height: 4),
                Text(r["notes"], style: const TextStyle(height: 1.5)),
              ],
            ),
          ),
          if (canQuote) SectionTitle(status == "Quoted" ? "Revise Quotation" : "Send Quotation"),
          if (canQuote)
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: AppTextField(controller: priceController, label: "Total price", hint: "24500", prefixText: "₱ ", keyboardType: TextInputType.number, pill: false)),
                      const SizedBox(width: 12),
                      Expanded(child: AppTextField(controller: daysController, label: "Production days", hint: "14", keyboardType: TextInputType.number, pill: false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: noteController, label: "Note to customer", hint: "Inclusions, payment terms...", maxLines: 3, pill: false),
                  const SizedBox(height: 16),
                  AppButton(label: status == "Quoted" ? "Update Quotation" : "Send Quotation", icon: Icons.send_outlined, onPressed: () => sendQuote()),
                  const SizedBox(height: 10),
                  AppButton(label: "Reject Request", variant: "outline", onPressed: () => rejectRequest()),
                ],
              ),
            ),
          if (!canQuote && r["quotePrice"] > 0) const SectionTitle("Quotation"),
          if (!canQuote && r["quotePrice"] > 0)
            AppCard(
              child: Column(
                children: [
                  InfoRow("Price", Format.peso(r["quotePrice"]), bold: true),
                  InfoRow("Production", "${r["leadDays"]} days"),
                  if (r["quoteNote"] != "") InfoRow("Note", r["quoteNote"]),
                ],
              ),
            ),
          if (status == "Approved" && AllOrders.find(r["orderId"]) != null)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: AppButton(
                label: "Open Production Order",
                icon: Icons.open_in_new,
                onPressed: () {
                  AllOrders.selectedId = r["orderId"];
                  Navigator.pushNamed(context, "/adminorder").then((v) => setState(() {}));
                },
              ),
            ),
        ],
      ),
    );
  }
}
