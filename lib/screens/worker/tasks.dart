import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../widgets/common.dart';
import 'taskcard.dart';

// My Tasks tab (WorkerTasksPage)
class TasksTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const TasksTab({super.key, required this.onRefresh});

  @override
  State<TasksTab> createState() => TasksTabPage();
}

class TasksTabPage extends State<TasksTab> {
  String filter = "Active";

  @override
  Widget build(BuildContext context) {
    List<dynamic> all = AllTasks.ofWorker(AllUsers.activeEmail);
    List<String> filters = ["Active", "To Do", "In Progress", "Done", "All"];
    Map<String, int> counts = {"All": all.length, "Active": 0, "To Do": 0, "In Progress": 0, "Done": 0};
    List<dynamic> list = [];
    for (dynamic t in all) {
      counts[t["progress"]] = counts[t["progress"]]! + 1;
      if (t["progress"] != "Done") counts["Active"] = counts["Active"]! + 1;
      if (filter == "All" || t["progress"] == filter || (filter == "Active" && t["progress"] != "Done")) list.add(t);
    }
    //nearest due date first
    list.sort((a, b) => a["dueDate"].toString().compareTo(b["dueDate"].toString()));

    return Column(
      children: [
        const PageHeader(title: "My Tasks", subtitle: "Assigned production work"),
        FilterChips(options: filters, selected: filter, counts: counts, onSelected: (v) => setState(() => filter = v)),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? ListView(children: const [EmptyState(icon: Icons.assignment_turned_in_outlined, title: "No tasks here", subtitle: "Tasks assigned by the owner will appear here.")])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (c, i) => TaskCard(task: list[i], onReturn: widget.onRefresh),
                ),
        ),
      ],
    );
  }
}
