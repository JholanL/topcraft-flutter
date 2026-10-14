import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import 'taskcard.dart';

// Schedule tab: tasks per due date (WorkerSchedulePage)
class ScheduleTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const ScheduleTab({super.key, required this.onRefresh});

  @override
  State<ScheduleTab> createState() => ScheduleTabPage();
}

class ScheduleTabPage extends State<ScheduleTab> {
  DateTime selected = DateTime.now();

  bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    List<dynamic> tasks = AllTasks.ofWorker(AllUsers.activeEmail);
    DateTime today = DateTime.now();
    List<DateTime> days = List.generate(14, (i) => DateTime(today.year, today.month, today.day).add(Duration(days: i)));
    List<dynamic> dayTasks = [];
    List<dynamic> overdue = [];
    for (dynamic t in tasks) {
      if (t["progress"] == "Done") continue;
      DateTime due = DateTime.parse(t["dueDate"]);
      if (sameDay(due, selected)) dayTasks.add(t);
      if (TaskCard.isOverdue(t)) overdue.add(t);
    }

    int countOn(DateTime d) {
      int c = 0;
      for (dynamic t in tasks) {
        if (t["progress"] != "Done" && sameDay(DateTime.parse(t["dueDate"]), d)) c++;
      }
      return c;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        PageHeader(title: "Schedule", subtitle: DateFormat("MMMM yyyy").format(selected)),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: days.length,
            separatorBuilder: (c, i) => const SizedBox(width: 8),
            itemBuilder: (c, i) {
              DateTime d = days[i];
              bool active = sameDay(d, selected);
              int count = countOn(d);
              return GestureDetector(
                onTap: () => setState(() => selected = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 58,
                  decoration: BoxDecoration(
                    color: active ? AppColors.black : AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: active ? AppColors.black : AppColors.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(DateFormat("E").format(d), style: TextStyle(fontSize: 12, color: active ? Colors.white70 : AppColors.muted)),
                      const SizedBox(height: 4),
                      Text("${d.day}", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: active ? Colors.white : AppColors.text)),
                      const SizedBox(height: 4),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: count > 0 ? AppColors.tabActive : Colors.transparent, shape: BoxShape.circle),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (overdue.isNotEmpty) Padding(padding: const EdgeInsets.fromLTRB(20, 16, 20, 0), child: SectionTitle("Overdue (${overdue.length})")),
        for (dynamic t in overdue) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: TaskCard(task: t, onReturn: widget.onRefresh)),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: SectionTitle(sameDay(selected, today) ? "Due today" : "Due ${DateFormat("EEEE, MMM d").format(selected)}"),
        ),
        if (dayTasks.isEmpty) const EmptyState(icon: Icons.event_available_outlined, title: "Nothing due", subtitle: "No tasks are due on this day."),
        for (dynamic t in dayTasks) Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 10), child: TaskCard(task: t, onReturn: widget.onRefresh)),
      ],
    );
  }
}
