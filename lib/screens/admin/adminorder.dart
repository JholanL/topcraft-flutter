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

// Owner order details: assign worker, quality check, delivery
// (AdminOperationTaskPage / AdminQCDetailPage / AdminDeliveryDetailPage)
class AdminOrderState extends StatefulWidget {
  const AdminOrderState({super.key});

  @override
  State<AdminOrderState> createState() => AdminOrderPage();
}

class AdminOrderPage extends State<AdminOrderState> {
  String taskDetails(dynamic order) {
    List<String> parts = [];
    for (dynamic item in order["items"]) {
      parts.add("${item["name"]} x${item["qty"]}");
    }
    return parts.join(", ");
  }

  //UPDATE - assign a worker, this creates the production task
  Future<void> assignWorker(dynamic order) async {
    dynamic existing = AllTasks.forOrder(order["id"]);
    DateTime due = DateTime.now().add(const Duration(days: 5));
    List<dynamic> workers = [];
    for (dynamic w in AllUsers.byRole("worker")) {
      if (w["status"] == "Active") workers.add(w);
    }

    String? picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (c) => StatefulBuilder(
        builder: (c, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(existing == null ? "Assign Worker" : "Reassign Worker", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text("${order["code"]} • ${taskDetails(order)}", style: const TextStyle(color: AppColors.muted, fontSize: 13)),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined, color: AppColors.accent),
                  title: const Text("Target finish date"),
                  subtitle: Text(Format.date(due.toIso8601String())),
                  trailing: const Text("Change", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600)),
                  onTap: () async {
                    DateTime? d = await showDatePicker(
                      context: c,
                      initialDate: due,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 120)),
                    );
                    if (d != null) setSheet(() => due = d);
                  },
                ),
                const Divider(),
                if (workers.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text("No active workers. Add one in More > Accounts.")),
                for (dynamic w in workers)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Avatar(AllUsers.initials(w["email"]), size: 40),
                    title: Text("${w["firstName"]} ${w["lastName"]}", style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("${w["position"]} • ${AllTasks.activeCount(w["email"])} active task(s)"),
                    trailing: order["worker"] == w["email"] ? const StatusPill("Active", label: "Current") : const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pop(c, w["email"]),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked == null) return;

    setState(() {
      String name = AllUsers.fullName(picked);
      if (existing != null && existing["progress"] != "Done") {
        //reassign the open task
        AllActivity.notify(existing["worker"], "Task reassigned", "${order["code"]} was moved to another worker.", "task");
        existing["worker"] = picked;
        existing["dueDate"] = due.toIso8601String();
        existing["assignedAt"] = Format.now();
      } else {
        AllTasks.taskList.add({
          "id": Store.newId(),
          "orderId": order["id"],
          "orderCode": order["code"],
          "worker": picked,
          "title": "Build ${order["code"]}",
          "details": taskDetails(order),
          "progress": "To Do",
          "dueDate": due.toIso8601String(),
          "assignedAt": Format.now(),
          "completedAt": "",
          "note": "",
        });
      }
      order["worker"] = picked;
      if (order["status"] == "Pending") {
        AllOrders.setStatus(order, "In Production", "Assigned to $name. Target finish: ${Format.date(due.toIso8601String())}.");
      } else {
        order["updatedAt"] = Format.now();
      }
      AllActivity.notify(picked, "New task: ${order["code"]}", "${taskDetails(order)} • due ${Format.date(due.toIso8601String())}", "task");
      AllActivity.log(AllUsers.activeEmail, "Assigned ${order["code"]} to $name");
    });
    Store.save();
    if (mounted) showToast(context, "Assigned to ${AllUsers.fullName(picked)}");
  }

  //UPDATE - quality check passed or failed
  Future<void> qualityCheck(dynamic order, bool passed) async {
    String note = "";
    if (!passed) {
      TextEditingController controller = TextEditingController();
      bool? ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text("Return to production", style: TextStyle(fontWeight: FontWeight.w700)),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(hintText: "What needs to be fixed?", border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
            TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Return", style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700))),
          ],
        ),
      );
      if (ok != true) return;
      note = controller.text.trim().isEmpty ? "Needs rework." : controller.text.trim();
    } else {
      bool ok = await confirmDialog(context, "Pass Quality Check", "Approve ${order["code"]} and send it out for delivery?", confirm: "Pass & Dispatch");
      if (!ok) return;
    }

    setState(() {
      if (passed) {
        order["qcNotes"] = "Passed";
        AllOrders.setStatus(order, "Out for Delivery", "Passed quality check and is on the way.");
        AllActivity.log(AllUsers.activeEmail, "Passed QC of ${order["code"]}");
      } else {
        order["qcNotes"] = note;
        AllOrders.setStatus(order, "In Production", "Returned for rework: $note");
        dynamic task = AllTasks.forOrder(order["id"]);
        if (task != null) {
          task["progress"] = "In Progress";
          task["completedAt"] = "";
          task["note"] = "QC: $note";
          AllActivity.notify(task["worker"], "Rework needed: ${order["code"]}", note, "task");
        }
        AllActivity.log(AllUsers.activeEmail, "Returned ${order["code"]} for rework");
      }
    });
    Store.save();
  }

  Future<void> markDelivered(dynamic order) async {
    bool ok = await confirmDialog(context, "Mark as Delivered", "Confirm that ${order["code"]} was delivered to the customer?", confirm: "Delivered");
    if (!ok) return;
    setState(() => AllOrders.setStatus(order, "Completed", "Delivered by Industrial Manila team."));
    AllActivity.log(AllUsers.activeEmail, "Completed ${order["code"]}");
    Store.save();
  }

  Future<void> cancelOrder(dynamic order) async {
    bool ok = await confirmDialog(context, "Cancel Order", "Cancel ${order["code"]}? Product stock will be returned.", confirm: "Cancel Order", danger: true);
    if (!ok) return;
    setState(() {
      for (dynamic item in order["items"]) {
        dynamic p = AllProducts.find(item["productId"]);
        if (p != null) p["stock"] = p["stock"] + item["qty"];
      }
      AllTasks.taskList.removeWhere((t) => t["orderId"] == order["id"] && t["progress"] != "Done");
      AllOrders.setStatus(order, "Cancelled", "Cancelled by the shop.");
    });
    Store.save();
  }

  //DELETE - remove a finished or cancelled order
  Future<void> deleteOrder(dynamic order) async {
    bool ok = await confirmDialog(context, "Delete Order", "Delete ${order["code"]} and its tasks permanently?", confirm: "Delete", danger: true);
    if (!ok || !mounted) return;
    AllTasks.taskList.removeWhere((t) => t["orderId"] == order["id"]);
    AllOrders.orderList.remove(order);
    Store.save();
    showToast(context, "${order["code"]} deleted");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    dynamic order = AllOrders.find(AllOrders.selectedId);
    if (order == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.receipt_long_outlined, title: "Order not found", subtitle: "It may have been deleted."));
    }
    String status = order["status"];
    dynamic task = AllTasks.forOrder(order["id"]);
    dynamic customer = AllUsers.find(order["customer"]);

    List<Widget> actions = [];
    if (status == "Pending") {
      actions.add(AppButton(label: "Assign Worker", icon: Icons.engineering_outlined, onPressed: () => assignWorker(order)));
      actions.add(AppButton(label: "Cancel Order", variant: "outline", onPressed: () => cancelOrder(order)));
    } else if (status == "In Production") {
      actions.add(AppButton(label: "Reassign Worker", variant: "outline", icon: Icons.swap_horiz, onPressed: () => assignWorker(order)));
    } else if (status == "Quality Check") {
      actions.add(Row(
        children: [
          Expanded(child: AppButton(label: "Return", variant: "outline", icon: Icons.undo, onPressed: () => qualityCheck(order, false))),
          const SizedBox(width: 10),
          Expanded(child: AppButton(label: "Pass QC", icon: Icons.verified_outlined, onPressed: () => qualityCheck(order, true))),
        ],
      ));
    } else if (status == "Out for Delivery") {
      actions.add(AppButton(label: "Mark as Delivered", icon: Icons.done_all, onPressed: () => markDelivered(order)));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(order["code"]),
        actions: [
          if (status == "Completed" || status == "Cancelled")
            IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteOrder(order)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(order["type"] == "Custom" ? "Custom order" : "Shop order", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                      Text(Format.peso(order["total"]), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                      Text("${order["payment"]} • ${Format.dateTime(order["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
                StatusPill(status),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (Widget a in actions) Padding(padding: const EdgeInsets.only(bottom: 10), child: a),
          if (order["qcNotes"] != "" && order["qcNotes"] != "Passed")
            AppCard(
              color: AppColors.dangerBg,
              child: Text("Last QC result: ${order["qcNotes"]}", style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
            ),
          if (task != null) const SectionTitle("Production Task"),
          if (task != null)
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Avatar(AllUsers.initials(task["worker"]), size: 42),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AllUsers.fullName(task["worker"]), style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(AllUsers.find(task["worker"])?["position"] ?? "Worker", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      StatusPill(task["progress"]),
                    ],
                  ),
                  const SizedBox(height: 8),
                  InfoRow("Target finish", Format.date(task["dueDate"])),
                  if (task["completedAt"] != "") InfoRow("Finished", Format.dateTime(task["completedAt"])),
                  if (task["note"] != "") InfoRow("Worker note", task["note"]),
                ],
              ),
            ),
          const SizedBox(height: 4),
          const SectionTitle("Timeline"),
          AppCard(child: OrderTimeline(order: order, stages: AllOrders.stages)),
          const SizedBox(height: 4),
          const SectionTitle("Items"),
          AppCard(
            child: Column(
              children: [
                for (dynamic item in order["items"])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(10)),
                          child: ProductImage(item["image"], iconSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(child: Text("${item["name"]}\n${Format.peso(item["price"])} x ${item["qty"]}", style: const TextStyle(fontSize: 13))),
                        Text(Format.peso((item["price"] as num) * (item["qty"] as num)), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                const Divider(),
                InfoRow("Subtotal", Format.peso(order["subtotal"])),
                InfoRow("Delivery fee", Format.peso(order["deliveryFee"])),
                InfoRow("Total", Format.peso(order["total"]), bold: true),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const SectionTitle("Customer"),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Avatar(AllUsers.initials(order["customer"]), size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AllUsers.fullName(order["customer"]), style: const TextStyle(fontWeight: FontWeight.w700)),
                          Text(customer?["email"] ?? order["customer"], style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                InfoRow("Recipient", order["recipient"]),
                InfoRow("Phone", order["phone"]),
                InfoRow("Address", order["address"]),
                if (order["notes"] != "") InfoRow("Notes", order["notes"]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
