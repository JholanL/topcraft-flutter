import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/requests.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

// Customers / CRM list (AdminCRMListPage of mobile-topcraft)
class CustomersState extends StatefulWidget {
  const CustomersState({super.key});

  @override
  State<CustomersState> createState() => CustomersPage();
}

class CustomersPage extends State<CustomersState> {
  String sort = "Top spenders";

  num totalSpent(String email) {
    num total = 0;
    for (dynamic o in AllOrders.ofCustomer(email)) {
      if (o["status"] != "Cancelled") total = total + o["total"];
    }
    return total;
  }

  void openCustomer(dynamic u) {
    List<dynamic> orders = AllOrders.ofCustomer(u["email"]);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (c, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Row(
              children: [
                Avatar(AllUsers.initials(u["email"]), size: 52, color: AppColors.success),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${u["firstName"]} ${u["lastName"]}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text("${u["email"]} • ${u["phone"]}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: StatCard(label: "Orders", value: "${orders.length}", icon: Icons.receipt_long_outlined, color: AppColors.accent, bg: AppColors.accentSoft)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: "Total spent", value: Format.pesoShort(totalSpent(u["email"])), icon: Icons.payments_outlined, color: AppColors.success, bg: AppColors.successBg)),
                const SizedBox(width: 10),
                Expanded(child: StatCard(label: "Custom", value: "${AllRequests.ofCustomer(u["email"]).length}", icon: Icons.design_services_outlined, color: AppColors.orange, bg: AppColors.orangeBg)),
              ],
            ),
            const SectionTitle("Order history"),
            if (orders.isEmpty) const Text("No orders yet.", style: TextStyle(color: AppColors.muted)),
            for (dynamic o in orders)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text("${o["code"]} • ${Format.peso(o["total"])}", style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text("${AllOrders.itemSummary(o)}\n${Format.date(o["createdAt"])}"),
                isThreeLine: true,
                trailing: StatusPill(o["status"]),
                onTap: () {
                  Navigator.pop(c);
                  AllOrders.selectedId = o["id"];
                  Navigator.pushNamed(context, "/adminorder").then((v) => setState(() {}));
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = List.from(AllUsers.byRole("customer"));
    if (sort == "Top spenders") {
      list.sort((a, b) => totalSpent(b["email"]).compareTo(totalSpent(a["email"])));
    } else if (sort == "Most orders") {
      list.sort((a, b) => AllOrders.ofCustomer(b["email"]).length.compareTo(AllOrders.ofCustomer(a["email"]).length));
    } else {
      list.sort((a, b) => b["createdAt"].toString().compareTo(a["createdAt"].toString()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Customers")),
      body: Column(
        children: [
          FilterChips(options: const ["Top spenders", "Most orders", "Newest"], selected: sort, onSelected: (v) => setState(() => sort = v)),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.groups_outlined, title: "No customers yet", subtitle: "Customers who sign up will appear here.")
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (c, i) {
                      dynamic u = list[i];
                      List<dynamic> orders = AllOrders.ofCustomer(u["email"]);
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        onTap: () => openCustomer(u),
                        child: Row(
                          children: [
                            Avatar(AllUsers.initials(u["email"]), size: 44, color: AppColors.success),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${u["firstName"]} ${u["lastName"]}", style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text("${orders.length} order(s) • ${orders.isEmpty ? "No orders yet" : "Last ${Format.date(orders.first["createdAt"])}"}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Text(Format.pesoShort(totalSpent(u["email"])), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
