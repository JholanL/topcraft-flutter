import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/activity.dart';
import '../../glob/orders.dart';
import '../../widgets/role_tab_bar.dart';
import 'shop.dart';
import 'orders.dart';
import 'custom.dart';
import 'customermore.dart';

// Client flow: Shop, Orders, Custom (Designs) and More tabs
class CustomerShellState extends StatefulWidget {
  const CustomerShellState({super.key});

  @override
  State<CustomerShellState> createState() => CustomerShellPage();
}

class CustomerShellPage extends State<CustomerShellState> {
  int index = 0;

  void refresh() => setState(() {});

  void switchTab(int i) => setState(() => index = i);

  @override
  Widget build(BuildContext context) {
    if (AllUsers.active == null) return const SizedBox.shrink();
    String email = AllUsers.activeEmail;
    int activeOrders = 0;
    for (dynamic o in AllOrders.ofCustomer(email)) {
      if (o["status"] != "Completed" && o["status"] != "Cancelled") activeOrders++;
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: [
            ShopTab(onRefresh: refresh, onSwitchTab: switchTab),
            OrdersTab(onRefresh: refresh),
            CustomTab(onRefresh: refresh),
            CustomerMoreTab(onRefresh: refresh),
          ],
        ),
      ),
      bottomNavigationBar: RoleTabBar(
        index: index,
        onTap: switchTab,
        items: [
          const TabItem("Shop", Icons.storefront_outlined, Icons.storefront),
          TabItem("Orders", Icons.receipt_outlined, Icons.receipt, activeOrders),
          const TabItem("Custom", Icons.color_lens_outlined, Icons.color_lens),
          TabItem("More", Icons.person_outline, Icons.person, AllActivity.unreadCount(email)),
        ],
      ),
    );
  }
}
