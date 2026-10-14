import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

class NotificationsState extends StatefulWidget {
  const NotificationsState({super.key});

  @override
  State<NotificationsState> createState() => NotificationsPage();
}

class NotificationsPage extends State<NotificationsState> {
  IconData iconOf(String type) {
    if (type == "order") return Icons.receipt_long_outlined;
    if (type == "request") return Icons.design_services_outlined;
    if (type == "inventory") return Icons.inventory_2_outlined;
    if (type == "task") return Icons.assignment_outlined;
    if (type == "review") return Icons.star_outline;
    return Icons.notifications_none;
  }

  //UPDATE - mark as read
  void markAllRead() {
    setState(() {
      for (int i = 0; i < AllActivity.notificationList.length; i++) {
        if (AllActivity.notificationList[i]["email"] == AllUsers.activeEmail) {
          AllActivity.notificationList[i]["read"] = true;
        }
      }
    });
    Store.save();
  }

  //DELETE - swipe to remove
  void deleteNotification(dynamic item) {
    setState(() => AllActivity.notificationList.remove(item));
    Store.save();
    showToast(context, "Notification removed");
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = AllActivity.notificationsOf(AllUsers.activeEmail);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        actions: [
          if (AllActivity.unreadCount(AllUsers.activeEmail) > 0)
            TextButton(onPressed: () => markAllRead(), child: const Text("Mark all read", style: TextStyle(color: AppColors.accent))),
        ],
      ),
      body: list.isEmpty
          ? const EmptyState(icon: Icons.notifications_none, title: "No notifications", subtitle: "Updates about your orders and tasks will show up here.")
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: list.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                dynamic item = list[i];
                bool unread = item["read"] == false;
                return Dismissible(
                  key: ValueKey(item["id"]),
                  direction: DismissDirection.endToStart,
                  onDismissed: (d) => deleteNotification(item),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: AppCard(
                    color: unread ? const Color(0xFFFFFBF5) : AppColors.surface,
                    onTap: () {
                      setState(() => item["read"] = true);
                      Store.save();
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                          child: Icon(iconOf(item["type"]), size: 20, color: AppColors.accent),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item["title"], style: TextStyle(fontSize: 14, fontWeight: unread ? FontWeight.w800 : FontWeight.w600)),
                              const SizedBox(height: 3),
                              Text(item["body"], style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                              const SizedBox(height: 6),
                              Text(Format.timeAgo(item["date"]), style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                            ],
                          ),
                        ),
                        if (unread)
                          Container(width: 9, height: 9, margin: const EdgeInsets.only(top: 4), decoration: const BoxDecoration(color: AppColors.tabActive, shape: BoxShape.circle)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
