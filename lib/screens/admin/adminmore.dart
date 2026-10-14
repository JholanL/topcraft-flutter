import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../shared/logout.dart';

class AdminMoreTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const AdminMoreTab({super.key, required this.onRefresh});

  @override
  State<AdminMoreTab> createState() => AdminMoreTabPage();
}

class AdminMoreTabPage extends State<AdminMoreTab> {
  void openPage(String route) {
    Navigator.pushNamed(context, route).then((v) => widget.onRefresh());
  }

  Future<void> resetData() async {
    bool ok = await confirmDialog(
      context,
      "Reset Demo Data",
      "This brings back the original sample products, orders and accounts. Everything you added will be removed.",
      confirm: "Reset",
      danger: true,
    );
    if (!ok || !mounted) return;
    Store.reset();
    //the owner account always exists in the demo data
    Store.signIn("owner@imf.com");
    widget.onRefresh();
    showToast(context, "Demo data restored");
  }

  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    dynamic user = AllUsers.active;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: "More"),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppCard(
            onTap: () => openPage("/profile"),
            child: Row(
              children: [
                Avatar(AllUsers.initials(email), size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${user["firstName"]} ${user["lastName"]}", style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                      Text(email, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                      const SizedBox(height: 4),
                      const StatusPill("Active", label: "Owner"),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.soft),
              ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionTitle("Business")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                MenuTile(icon: Icons.design_services_outlined, title: "Custom Requests", subtitle: "Review and send quotations", badge: AllRequests.countStatus("Submitted"), onTap: () => openPage("/adminrequests")),
                MenuTile(icon: Icons.groups_outlined, title: "Customers", subtitle: "Customer list and order history", onTap: () => openPage("/customers")),
                MenuTile(icon: Icons.manage_accounts_outlined, title: "Accounts", subtitle: "Owners, workers and customers", onTap: () => openPage("/accounts")),
                MenuTile(icon: Icons.bar_chart_rounded, title: "Sales Reports", subtitle: "Revenue, best sellers and workers", onTap: () => openPage("/reports")),
                MenuTile(icon: Icons.history, title: "Stock Logs", subtitle: "Inventory movements", onTap: () => openPage("/stocklogs")),
              ],
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 0), child: SectionTitle("Account")),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                MenuTile(icon: Icons.notifications_none, title: "Notifications", badge: AllActivity.unreadCount(email), onTap: () => openPage("/notifications")),
                MenuTile(icon: Icons.lock_outline, title: "Change Password", onTap: () => openPage("/changepassword")),
                MenuTile(icon: Icons.restart_alt, title: "Reset Demo Data", subtitle: "Restore the original sample data", color: AppColors.warning, onTap: () => resetData()),
                MenuTile(icon: Icons.logout, title: "Sign out", color: AppColors.danger, onTap: () => logout(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
