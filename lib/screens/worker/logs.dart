import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

// Logs tab: history of what the worker did (WorkerMessagesPage "Logs")
class LogsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const LogsTab({super.key, required this.onRefresh});

  @override
  State<LogsTab> createState() => LogsTabPage();
}

class LogsTabPage extends State<LogsTab> {
  IconData iconOf(String action) {
    String a = action.toLowerCase();
    if (a.contains("finished")) return Icons.task_alt;
    if (a.contains("started")) return Icons.play_circle_outline;
    if (a.contains("took out") || a.contains("added")) return Icons.inventory_2_outlined;
    if (a.contains("note")) return Icons.edit_note;
    if (a.contains("signed")) return Icons.login;
    return Icons.history;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> logs = AllActivity.logsOf(AllUsers.activeEmail);
    List<Widget> rows = [];
    String lastDate = "";
    for (dynamic log in logs) {
      String day = Format.date(log["date"]);
      if (day != lastDate) {
        rows.add(Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
          child: Text(day == Format.date(Format.now()) ? "Today" : day, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.muted)),
        ));
        lastDate = day;
      }
      rows.add(Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                  child: Icon(iconOf(log["action"]), size: 18, color: AppColors.accent),
                ),
                Container(width: 2, height: 18, color: AppColors.line),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(log["action"], style: const TextStyle(fontWeight: FontWeight.w600))),
            Text(Format.time(log["date"]), style: const TextStyle(fontSize: 12, color: AppColors.soft)),
          ],
        ),
      ));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: "Activity Logs", subtitle: "Your work history"),
        if (logs.isEmpty) const EmptyState(icon: Icons.history, title: "No activity yet", subtitle: "Your task updates and material usage will be logged here."),
        ...rows,
      ],
    );
  }
}
