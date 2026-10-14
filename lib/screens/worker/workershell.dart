import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../widgets/role_tab_bar.dart';
import 'workerhome.dart';
import 'tasks.dart';
import 'schedule.dart';
import 'logs.dart';
import 'workermore.dart';

// Worker flow: Home, My Tasks, Schedule, Logs and More (WorkerNavigator)
class WorkerShellState extends StatefulWidget {
  const WorkerShellState({super.key});

  @override
  State<WorkerShellState> createState() => WorkerShellPage();
}

class WorkerShellPage extends State<WorkerShellState> {
  int index = 0;

  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    if (AllUsers.active == null) return const SizedBox.shrink();
    int toDo = 0;
    for (dynamic t in AllTasks.ofWorker(AllUsers.activeEmail)) {
      if (t["progress"] == "To Do") toDo++;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: [
            WorkerHomeTab(onRefresh: refresh, onSwitchTab: (i) => setState(() => index = i)),
            TasksTab(onRefresh: refresh),
            ScheduleTab(onRefresh: refresh),
            LogsTab(onRefresh: refresh),
            WorkerMoreTab(onRefresh: refresh),
          ],
        ),
      ),
      bottomNavigationBar: RoleTabBar(
        index: index,
        onTap: (i) => setState(() => index = i),
        items: [
          const TabItem("Home", Icons.home_outlined, Icons.home),
          TabItem("My Tasks", Icons.assignment_outlined, Icons.assignment, toDo),
          const TabItem("Schedule", Icons.calendar_today_outlined, Icons.calendar_today),
          const TabItem("Logs", Icons.receipt_outlined, Icons.receipt),
          const TabItem("More", Icons.more_horiz, Icons.more_horiz),
        ],
      ),
    );
  }
}
