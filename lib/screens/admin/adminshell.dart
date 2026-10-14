import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/materials.dart';
import '../../widgets/role_tab_bar.dart';
import 'adminhome.dart';
import 'operations.dart';
import 'inventory.dart';
import 'catalog.dart';
import 'adminmore.dart';

// Admin flow (owner): Home, Operations, Inventory, Catalog and More tabs
class AdminShellState extends StatefulWidget {
  const AdminShellState({super.key});

  @override
  State<AdminShellState> createState() => AdminShellPage();
}

class AdminShellPage extends State<AdminShellState> {
  int index = 0;
  String operationsFilter = "All";

  void refresh() => setState(() {});

  //the dashboard can open the Operations tab already filtered
  void openOperations(String filter) {
    setState(() {
      operationsFilter = filter;
      index = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (AllUsers.active == null) return const SizedBox.shrink();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: index,
          children: [
            AdminHomeTab(onRefresh: refresh, onOpenOperations: openOperations, onSwitchTab: (i) => setState(() => index = i)),
            OperationsTab(key: ValueKey(operationsFilter), onRefresh: refresh, initialFilter: operationsFilter),
            InventoryTab(onRefresh: refresh),
            CatalogTab(onRefresh: refresh),
            AdminMoreTab(onRefresh: refresh),
          ],
        ),
      ),
      bottomNavigationBar: RoleTabBar(
        index: index,
        onTap: (i) => setState(() => index = i),
        items: [
          const TabItem("Home", Icons.home_outlined, Icons.home),
          TabItem("Operations", Icons.grid_view_outlined, Icons.grid_view_rounded, AllOrders.countStatus("Pending") + AllOrders.countStatus("Quality Check")),
          TabItem("Inventory", Icons.inventory_2_outlined, Icons.inventory_2, AllMaterials.lowCount()),
          const TabItem("Catalog", Icons.chair_outlined, Icons.chair),
          const TabItem("More", Icons.more_horiz, Icons.more_horiz),
        ],
      ),
    );
  }
}
