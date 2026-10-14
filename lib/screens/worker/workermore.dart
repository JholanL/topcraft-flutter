import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../shared/logout.dart';

// More tab of the worker (WorkerMoreModule)
class WorkerMoreTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const WorkerMoreTab({super.key, required this.onRefresh});

  @override
  State<WorkerMoreTab> createState() => WorkerMoreTabPage();
}

class WorkerMoreTabPage extends State<WorkerMoreTab> {
  void openPage(String route) {
    Navigator.pushNamed(context, route).then((v) => widget.onRefresh());
  }

  //READ - finished tasks (project history)
  void showHistory() {
    List<dynamic> done = [];
    for (dynamic t in AllTasks.ofWorker(AllUsers.activeEmail)) {
      if (t["progress"] == "Done") done.add(t);
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (c, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text("Project History (${done.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            if (done.isEmpty) const Text("No finished tasks yet.", style: TextStyle(color: AppColors.muted)),
            for (dynamic t in done)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.task_alt, color: AppColors.success),
                title: Text(t["orderCode"], style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text("${t["details"]}\nFinished ${Format.date(t["completedAt"])}"),
                isThreeLine: true,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    dynamic user = AllUsers.active;
    int done = 0;
    for (dynamic t in AllTasks.ofWorker(email)) {
      if (t["progress"] == "Done") done++;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: "More"),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B1815), Color(0xFF2B4C8C)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Avatar(AllUsers.initials(email), size: 56, color: Colors.white),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${user["firstName"]} ${user["lastName"]}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                    Text("${user["position"]} • $done tasks finished", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                MenuTile(icon: Icons.person_outline, title: "My Profile", onTap: () => openPage("/profile")),
                MenuTile(icon: Icons.history_edu_outlined, title: "Project History", subtitle: "Finished tasks", onTap: () => showHistory()),
                MenuTile(icon: Icons.notifications_none, title: "Notifications", badge: AllActivity.unreadCount(email), onTap: () => openPage("/notifications")),
                MenuTile(icon: Icons.lock_outline, title: "Change Password", onTap: () => openPage("/changepassword")),
                MenuTile(icon: Icons.logout, title: "Sign out", color: AppColors.danger, onTap: () => logout(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
