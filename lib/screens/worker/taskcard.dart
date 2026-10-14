import 'package:flutter/material.dart';
import '../../glob/orders.dart';
import '../../glob/tasks.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// task card shared by the worker tabs
class TaskCard extends StatelessWidget {
  final dynamic task;
  final VoidCallback onReturn;
  const TaskCard({super.key, required this.task, required this.onReturn});

  static bool isOverdue(dynamic task) {
    if (task["progress"] == "Done") return false;
    DateTime due = DateTime.parse(task["dueDate"]);
    DateTime today = DateTime.now();
    return DateTime(due.year, due.month, due.day).isBefore(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    dynamic order = AllOrders.find(task["orderId"]);
    List<dynamic> items = order == null ? [] : order["items"];
    bool overdue = isOverdue(task);

    return AppCard(
      onTap: () {
        AllTasks.selectedId = task["id"];
        Navigator.pushNamed(context, "/task").then((v) => onReturn());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(task["orderCode"], style: const TextStyle(fontWeight: FontWeight.w800)),
              if (order != null && order["type"] == "Custom") const Padding(padding: EdgeInsets.only(left: 6), child: StatusPill("Quoted", label: "Custom")),
              const Spacer(),
              StatusPill(task["progress"]),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(12)),
                child: ProductImage(items.isEmpty ? "" : items[0]["image"], iconSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(task["details"], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.event_outlined, size: 15, color: overdue ? AppColors.danger : AppColors.muted),
              const SizedBox(width: 6),
              Text(
                task["progress"] == "Done" ? "Finished ${Format.date(task["completedAt"])}" : "${overdue ? "Overdue • " : "Due "}${Format.date(task["dueDate"])}",
                style: TextStyle(fontSize: 12, color: overdue ? AppColors.danger : AppColors.muted, fontWeight: overdue ? FontWeight.w700 : FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
