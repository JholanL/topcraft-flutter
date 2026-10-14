import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/requests.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common.dart';
import '../shared/logout.dart';

class CustomerMoreTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const CustomerMoreTab({super.key, required this.onRefresh});

  @override
  State<CustomerMoreTab> createState() => CustomerMoreTabPage();
}

class CustomerMoreTabPage extends State<CustomerMoreTab> {
  void openPage(String route) {
    Navigator.pushNamed(context, route).then((v) => widget.onRefresh());
  }

  void showInfo(String title, String body) {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(body, style: const TextStyle(color: AppColors.muted, height: 1.6)),
            ],
          ),
        ),
      ),
    );
  }

  Widget stat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    dynamic user = AllUsers.active;
    List<dynamic> orders = AllOrders.ofCustomer(email);
    int completed = 0;
    for (dynamic o in orders) {
      if (o["status"] == "Completed") completed++;
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        const PageHeader(title: "Account"),
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B1815), Color(0xFF5C3A28)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Avatar(AllUsers.initials(email), size: 56, color: AppColors.gold),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${user["firstName"]} ${user["lastName"]}", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        Text(email, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => openPage("/profile"), icon: const Icon(Icons.edit_outlined, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  stat("${orders.length}", "Orders"),
                  stat("$completed", "Completed"),
                  stat("${AllRequests.ofCustomer(email).length}", "Custom"),
                ],
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
                MenuTile(icon: Icons.person_outline, title: "My Profile", subtitle: "Name and contact number", onTap: () => openPage("/profile")),
                MenuTile(icon: Icons.location_on_outlined, title: "My Addresses", subtitle: "Delivery locations", onTap: () => openPage("/addresses")),
                MenuTile(icon: Icons.shopping_bag_outlined, title: "My Cart", badge: AllOrders.cartCount(email), onTap: () => openPage("/cart")),
                MenuTile(icon: Icons.notifications_none, title: "Notifications", badge: AllActivity.unreadCount(email), onTap: () => openPage("/notifications")),
                MenuTile(icon: Icons.lock_outline, title: "Change Password", onTap: () => openPage("/changepassword")),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AppCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                MenuTile(
                  icon: Icons.help_outline,
                  title: "Help Center",
                  color: AppColors.info,
                  onTap: () => showInfo("Help Center",
                      "• Orders can be cancelled while they are still Pending.\n• Delivery is available within Metro Manila for a flat fee.\n• Custom requests are quoted within 1-2 days.\n• Tap 'Order Received' once your furniture arrives so you can rate it.\n\nContact us: 0917 123 4567 • hello@industrialmanila.ph"),
                ),
                MenuTile(
                  icon: Icons.info_outline,
                  title: "About",
                  color: AppColors.info,
                  onTap: () => showInfo("Industrial Manila Furniture",
                      "TopCraft mobile simulation built with Flutter.\n\nA front-end simulation of the TopCraft furniture business system: e-commerce, custom requests, production tracking, inventory and worker tasks. Data is stored on this device only (no database)."),
                ),
                MenuTile(icon: Icons.logout, title: "Sign out", color: AppColors.danger, onTap: () => logout(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
