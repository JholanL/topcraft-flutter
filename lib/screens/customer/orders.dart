import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// Orders tab (CustomerTrackPage of mobile-topcraft)
class OrdersTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const OrdersTab({super.key, required this.onRefresh});

  @override
  State<OrdersTab> createState() => OrdersTabPage();
}

class OrdersTabPage extends State<OrdersTab> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    List<dynamic> all = AllOrders.ofCustomer(AllUsers.activeEmail);
    List<String> filters = ["All", "Active", ...AllOrders.stages, "Cancelled"];
    Map<String, int> counts = {};
    for (String f in filters) {
      counts[f] = 0;
    }
    List<dynamic> list = [];
    for (dynamic o in all) {
      bool active = o["status"] != "Completed" && o["status"] != "Cancelled";
      counts["All"] = counts["All"]! + 1;
      if (active) counts["Active"] = counts["Active"]! + 1;
      counts[o["status"]] = (counts[o["status"]] ?? 0) + 1;
      if (filter == "All" || o["status"] == filter || (filter == "Active" && active)) list.add(o);
    }

    return Column(
      children: [
        const PageHeader(title: "My Orders", subtitle: "Track your furniture"),
        FilterChips(options: filters, selected: filter, counts: counts, onSelected: (v) => setState(() => filter = v)),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? ListView(children: const [
                  EmptyState(icon: Icons.receipt_long_outlined, title: "No orders here", subtitle: "Orders you place will appear here so you can track them."),
                ])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (c, i) {
                    dynamic o = list[i];
                    List<dynamic> items = o["items"];
                    int stage = AllOrders.stages.indexOf(o["status"]);
                    return AppCard(
                      onTap: () {
                        AllOrders.selectedId = o["id"];
                        Navigator.pushNamed(context, "/order").then((v) => widget.onRefresh());
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(o["code"], style: const TextStyle(fontWeight: FontWeight.w800)),
                              if (o["type"] == "Custom") const Padding(padding: EdgeInsets.only(left: 6), child: StatusPill("Quoted", label: "Custom")),
                              const Spacer(),
                              StatusPill(o["status"]),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(12)),
                                child: ProductImage(items.isEmpty ? "" : items[0]["image"], iconSize: 26),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AllOrders.itemSummary(o), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 2),
                                    Text("Placed ${Format.date(o["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Text(Format.pesoShort(o["total"]), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand)),
                            ],
                          ),
                          if (o["status"] != "Cancelled") const SizedBox(height: 12),
                          //mini progress bar of the stages
                          if (o["status"] != "Cancelled")
                            Row(
                              children: [
                                for (int s = 0; s < AllOrders.stages.length; s++)
                                  Expanded(
                                    child: Container(
                                      height: 5,
                                      margin: EdgeInsets.only(right: s == AllOrders.stages.length - 1 ? 0 : 4),
                                      decoration: BoxDecoration(
                                        color: s <= stage ? (stage == AllOrders.stages.length - 1 ? AppColors.success : AppColors.tabActive) : AppColors.line,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          if (o["status"] == "Out for Delivery")
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text("Your order is on the way. Tap to confirm receipt.", style: TextStyle(fontSize: 12, color: AppColors.orange, fontWeight: FontWeight.w600)),
                            ),
                          if (o["status"] == "Completed" && o["rated"] == false)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: Text("★ Rate your products", style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w700)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
