import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/tasks.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// Sales reports for the owner
class ReportsState extends StatefulWidget {
  const ReportsState({super.key});

  @override
  State<ReportsState> createState() => ReportsPage();
}

class ReportsPage extends State<ReportsState> {
  String range = "Last 30 days";

  bool inRange(String iso) {
    if (range == "All time") return true;
    int days = range == "Last 7 days" ? 7 : 30;
    return DateTime.now().difference(DateTime.parse(iso)).inDays < days;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> orders = [];
    for (dynamic o in AllOrders.orderList) {
      if (inRange(o["createdAt"])) orders.add(o);
    }
    num revenue = 0;
    int completed = 0;
    int cancelled = 0;
    Map<String, int> qtyByProduct = {};
    Map<String, num> salesByProduct = {};
    Map<String, String> imageByProduct = {};
    for (dynamic o in orders) {
      if (o["status"] == "Cancelled") {
        cancelled++;
        continue;
      }
      revenue = revenue + o["total"];
      if (o["status"] == "Completed") completed++;
      for (dynamic item in o["items"]) {
        String name = item["name"];
        qtyByProduct[name] = (qtyByProduct[name] ?? 0) + (item["qty"] as int);
        salesByProduct[name] = (salesByProduct[name] ?? 0) + item["price"] * item["qty"];
        imageByProduct[name] = item["image"];
      }
    }
    int valid = orders.length - cancelled;
    List<String> top = qtyByProduct.keys.toList()..sort((a, b) => qtyByProduct[b]!.compareTo(qtyByProduct[a]!));

    List<Color> colors = [AppColors.warning, AppColors.accent, AppColors.info, AppColors.orange, AppColors.success, AppColors.neutral];
    List<String> statuses = [...AllOrders.stages, "Cancelled"];
    List<PieChartSectionData> sections = [];
    for (int i = 0; i < statuses.length; i++) {
      int count = 0;
      for (dynamic o in orders) {
        if (o["status"] == statuses[i]) count++;
      }
      if (count > 0) {
        sections.add(PieChartSectionData(
          value: count.toDouble(),
          color: colors[i],
          title: "$count",
          radius: 46,
          titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
        ));
      }
    }

    List<dynamic> workers = AllUsers.byRole("worker");

    return Scaffold(
      appBar: AppBar(title: const Text("Sales Reports")),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          FilterChips(options: const ["Last 7 days", "Last 30 days", "All time"], selected: range, onSelected: (v) => setState(() => range = v)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  children: [
                    StatCard(label: "Gross sales", value: Format.pesoShort(revenue), icon: Icons.payments_outlined, color: AppColors.success, bg: AppColors.successBg),
                    StatCard(label: "Orders", value: "$valid", icon: Icons.receipt_long_outlined, color: AppColors.accent, bg: AppColors.accentSoft),
                    StatCard(label: "Average order", value: Format.pesoShort(valid == 0 ? 0 : revenue / valid), icon: Icons.trending_up, color: AppColors.info, bg: AppColors.infoBg),
                    StatCard(label: "Completed / Cancelled", value: "$completed / $cancelled", icon: Icons.fact_check_outlined, color: AppColors.orange, bg: AppColors.orangeBg),
                  ],
                ),
                const SizedBox(height: 4),
                const SectionTitle("Orders by status"),
                AppCard(
                  child: sections.isEmpty
                      ? const Text("No orders in this period.", style: TextStyle(color: AppColors.muted))
                      : Row(
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: PieChart(PieChartData(sections: sections, centerSpaceRadius: 24, sectionsSpace: 2)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  for (int i = 0; i < statuses.length; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 3),
                                      child: Row(
                                        children: [
                                          Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                                          const SizedBox(width: 8),
                                          Expanded(child: Text(statuses[i], style: const TextStyle(fontSize: 12))),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
                const SectionTitle("Best sellers"),
                AppCard(
                  child: top.isEmpty
                      ? const Text("No sales in this period.", style: TextStyle(color: AppColors.muted))
                      : Column(
                          children: [
                            for (int i = 0; i < top.length && i < 5; i++)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  children: [
                                    SizedBox(width: 24, child: Text("${i + 1}", style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.title))),
                                    SizedBox(width: 40, height: 40, child: ProductImage(imageByProduct[top[i]] ?? "", iconSize: 20)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(top[i], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                          Text("${qtyByProduct[top[i]]} pcs", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                    Text(Format.pesoShort(salesByProduct[top[i]]!), style: const TextStyle(fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                ),
                const SectionTitle("Worker productivity"),
                AppCard(
                  child: Column(
                    children: [
                      for (dynamic w in workers)
                        Builder(builder: (c) {
                          int done = 0;
                          for (dynamic t in AllTasks.ofWorker(w["email"])) {
                            if (t["progress"] == "Done") done++;
                          }
                          int active = AllTasks.activeCount(w["email"]);
                          int total = done + active;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Avatar(AllUsers.initials(w["email"]), size: 36, color: AppColors.info),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("${w["firstName"]} ${w["lastName"]}", style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 4),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: total == 0 ? 0 : done / total,
                                          minHeight: 6,
                                          backgroundColor: AppColors.line,
                                          color: AppColors.success,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text("$done done\n$active active", textAlign: TextAlign.right, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
