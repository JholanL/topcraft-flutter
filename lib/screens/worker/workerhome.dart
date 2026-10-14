import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import 'taskcard.dart';

// Worker home (WorkerHomePage of mobile-topcraft)
class WorkerHomeTab extends StatefulWidget {
  final VoidCallback onRefresh;
  final ValueChanged<int> onSwitchTab;
  const WorkerHomeTab({super.key, required this.onRefresh, required this.onSwitchTab});

  @override
  State<WorkerHomeTab> createState() => WorkerHomeTabPage();
}

class WorkerHomeTabPage extends State<WorkerHomeTab> {
  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    dynamic user = AllUsers.active;
    List<dynamic> tasks = AllTasks.ofWorker(email);
    int active = 0;
    int doneThisWeek = 0;
    int overdue = 0;
    dynamic current;
    for (dynamic t in tasks) {
      if (t["progress"] != "Done") {
        active++;
        if (TaskCard.isOverdue(t)) overdue++;
        //the task in progress is the current task, otherwise the next to do
        if (current == null || (t["progress"] == "In Progress" && current["progress"] != "In Progress")) current = t;
      } else if (t["completedAt"] != "" && DateTime.now().difference(DateTime.parse(t["completedAt"])).inDays < 7) {
        doneThisWeek++;
      }
    }
    List<dynamic> updates = AllActivity.notificationsOf(email);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageHeader(
            subtitle: "Hello, ${user["firstName"]} • ${user["position"]}",
            title: "Workshop",
            actions: [
              IconBadgeButton(
                icon: Icons.notifications_none,
                count: AllActivity.unreadCount(email),
                onTap: () => Navigator.pushNamed(context, "/notifications").then((v) => widget.onRefresh()),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Expanded(child: StatCard(label: "Active tasks", value: "$active", icon: Icons.assignment_outlined, color: AppColors.accent, bg: AppColors.accentSoft, onTap: () => widget.onSwitchTab(1))),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: "Overdue", value: "$overdue", icon: Icons.alarm, color: AppColors.danger, bg: AppColors.dangerBg, onTap: () => widget.onSwitchTab(2))),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: "Done (7 days)", value: "$doneThisWeek", icon: Icons.task_alt, color: AppColors.success, bg: AppColors.successBg)),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(20, 12, 20, 0), child: SectionTitle("Current task")),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: current == null
                ? const AppCard(child: Text("No active tasks. Enjoy your break! ☕", style: TextStyle(color: AppColors.muted)))
                : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.tabActive, width: 1.5),
                    ),
                    child: TaskCard(task: current, onReturn: widget.onRefresh),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: SectionTitle("Recent updates", action: updates.isEmpty ? null : "See all", onAction: () => Navigator.pushNamed(context, "/notifications").then((v) => widget.onRefresh())),
          ),
          if (updates.isEmpty) const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("No updates yet.", style: TextStyle(color: AppColors.muted))),
          for (dynamic n in updates.take(5))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: AppCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.campaign_outlined, size: 18, color: AppColors.accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(n["title"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          Text(n["body"], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(Format.timeAgo(n["date"]), style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
