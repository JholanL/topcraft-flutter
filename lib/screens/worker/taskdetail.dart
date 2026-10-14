import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/tasks.dart';
import '../../glob/materials.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';
import '../admin/inventory.dart';
import 'taskcard.dart';

// Worker task details (WorkerProjectDetailPage)
class TaskDetailState extends StatefulWidget {
  const TaskDetailState({super.key});

  @override
  State<TaskDetailState> createState() => TaskDetailPage();
}

class TaskDetailPage extends State<TaskDetailState> {
  //UPDATE - To Do -> In Progress
  void startTask(dynamic task) {
    setState(() => task["progress"] = "In Progress");
    AllActivity.log(AllUsers.activeEmail, "Started task for ${task["orderCode"]}");
    AllActivity.notifyRole("owner", "${task["orderCode"]} started", "${AllUsers.fullName(AllUsers.activeEmail)} started working on it.", "task");
    Store.save();
    showToast(context, "Task started");
  }

  //UPDATE - In Progress -> Done, the order moves to Quality Check
  Future<void> finishTask(dynamic task, dynamic order) async {
    bool ok = await confirmDialog(context, "Mark as Done", "Finished building ${task["orderCode"]}? It will be sent to quality check.", confirm: "Done");
    if (!ok) return;
    setState(() {
      task["progress"] = "Done";
      task["completedAt"] = Format.now();
      if (order != null) AllOrders.setStatus(order, "Quality Check", "Production finished by ${AllUsers.fullName(AllUsers.activeEmail)}. Waiting for inspection.");
    });
    AllActivity.log(AllUsers.activeEmail, "Finished task for ${task["orderCode"]}");
    AllActivity.notifyRole("owner", "${task["orderCode"]} ready for QC", "${AllUsers.fullName(AllUsers.activeEmail)} finished production.", "task");
    Store.save();
    if (mounted) showToast(context, "Sent to quality check");
  }

  Future<void> editNote(dynamic task) async {
    TextEditingController controller = TextEditingController(text: task["note"]);
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text("Work note", style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: "Progress, issues, materials used...", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(c, true), child: const Text("Save", style: TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok != true) return;
    setState(() => task["note"] = controller.text.trim());
    AllActivity.log(AllUsers.activeEmail, "Updated note for ${task["orderCode"]}");
    Store.save();
  }

  //records the materials used for this task (stock out)
  Future<void> useMaterials(dynamic task) async {
    dynamic picked = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (c, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: [
            const Text("Which material did you use?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (dynamic m in AllMaterials.materialList)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m["name"], style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text("${m["stock"]} ${m["unit"]} available"),
                trailing: AllMaterials.isLow(m) ? const StatusPill("Low Stock") : const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(c, m),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    if (await showStockSheet(context, picked, workerMode: true)) {
      setState(() {});
      if (mounted) showToast(context, "Material usage recorded");
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic task = AllTasks.find(AllTasks.selectedId);
    if (task == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.assignment_outlined, title: "Task not found", subtitle: "It may have been reassigned or removed."));
    }
    dynamic order = AllOrders.find(task["orderId"]);
    String progress = task["progress"];
    bool overdue = TaskCard.isOverdue(task);
    int step = progress == "To Do" ? 0 : progress == "In Progress" ? 1 : 2;

    return Scaffold(
      appBar: AppBar(title: Text(task["orderCode"])),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(task["title"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                    StatusPill(progress),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    for (int i = 0; i < 3; i++)
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(color: i <= step ? (step == 2 ? AppColors.success : AppColors.tabActive) : AppColors.line, borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(height: 6),
                            Text(["To Do", "In Progress", "Done"][i], style: TextStyle(fontSize: 11, color: i <= step ? AppColors.text : AppColors.soft, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                InfoRow("Assigned", Format.dateTime(task["assignedAt"])),
                InfoRow("Target finish", "${Format.date(task["dueDate"])}${overdue ? " (overdue)" : ""}"),
                if (task["completedAt"] != "") InfoRow("Finished", Format.dateTime(task["completedAt"])),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (progress == "To Do") AppButton(label: "Start Task", icon: Icons.play_arrow_rounded, onPressed: () => startTask(task)),
          if (progress == "In Progress") AppButton(label: "Mark as Done", icon: Icons.check_rounded, onPressed: () => finishTask(task, order)),
          if (progress != "Done") const SizedBox(height: 10),
          if (progress != "Done")
            Row(
              children: [
                Expanded(child: AppButton(label: "Work Note", variant: "outline", icon: Icons.edit_note, onPressed: () => editNote(task))),
                const SizedBox(width: 10),
                Expanded(child: AppButton(label: "Use Material", variant: "outline", icon: Icons.inventory_2_outlined, onPressed: () => useMaterials(task))),
              ],
            ),
          if (task["note"] != "") const SizedBox(height: 12),
          if (task["note"] != "")
            AppCard(
              color: task["note"].toString().startsWith("QC:") ? AppColors.dangerBg : AppColors.warningBg,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.sticky_note_2_outlined, color: task["note"].toString().startsWith("QC:") ? AppColors.danger : AppColors.warning),
                  const SizedBox(width: 10),
                  Expanded(child: Text(task["note"], style: const TextStyle(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          const SectionTitle("What to build"),
          AppCard(
            child: Column(
              children: [
                if (order == null) const Text("The order was removed.", style: TextStyle(color: AppColors.muted)),
                if (order != null)
                  for (dynamic item in order["items"])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(12)),
                            child: ProductImage(item["image"], iconSize: 26),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item["name"], style: const TextStyle(fontWeight: FontWeight.w700))),
                          Text("x${item["qty"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
              ],
            ),
          ),
          if (order != null && order["notes"] != "") const SectionTitle("Specifications / Notes"),
          if (order != null && order["notes"] != "") AppCard(child: Text(order["notes"], style: const TextStyle(height: 1.5))),
          if (order != null) const SectionTitle("Order stage"),
          if (order != null)
            AppCard(
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_outlined, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Order for ${AllUsers.fullName(order["customer"])}", style: const TextStyle(fontWeight: FontWeight.w600))),
                  StatusPill(order["status"]),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
