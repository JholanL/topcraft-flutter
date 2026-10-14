import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../glob/materials.dart';
import '../../glob/requests.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

// Owner dashboard (AdminHomePage of mobile-topcraft)
class AdminHomeTab extends StatefulWidget {
  final VoidCallback onRefresh;
  final ValueChanged<String> onOpenOperations;
  final ValueChanged<int> onSwitchTab;
  const AdminHomeTab({super.key, required this.onRefresh, required this.onOpenOperations, required this.onSwitchTab});

  @override
  State<AdminHomeTab> createState() => AdminHomeTabPage();
}

class AdminHomeTabPage extends State<AdminHomeTab> {
  void openPage(String route) {
    Navigator.pushNamed(context, route).then((v) => widget.onRefresh());
  }

  String greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  //sales of the last 7 days (orders that are not cancelled)
  List<double> weeklySales() {
    List<double> totals = List.filled(7, 0);
    DateTime today = DateTime.now();
    DateTime start = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 6));
    for (dynamic o in AllOrders.orderList) {
      if (o["status"] == "Cancelled") continue;
      DateTime d = DateTime.parse(o["createdAt"]);
      int index = DateTime(d.year, d.month, d.day).difference(start).inDays;
      if (index >= 0 && index < 7) totals[index] = totals[index] + (o["total"] as num).toDouble();
    }
    return totals;
  }

  Widget salesChart() {
    List<double> sales = weeklySales();
    double maxY = 1000;
    double sum = 0;
    for (double s in sales) {
      if (s > maxY) maxY = s;
      sum = sum + s;
    }
    DateTime start = DateTime.now().subtract(const Duration(days: 6));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Sales this week", style: TextStyle(fontSize: 13, color: AppColors.muted)),
          const SizedBox(height: 2),
          Text(Format.peso(sum), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY * 1.15,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (g) => AppColors.black,
                    getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(Format.pesoShort(rod.toY), const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(DateFormat("E").format(start.add(Duration(days: value.toInt()))), style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                      ),
                    ),
                  ),
                ),
                barGroups: [
                  for (int i = 0; i < 7; i++)
                    BarChartGroupData(x: i, barRods: [
                      BarChartRodData(
                        toY: sales[i],
                        width: 18,
                        color: i == 6 ? AppColors.tabActive : AppColors.accent,
                        borderRadius: BorderRadius.circular(6),
                        backDrawRodData: BackgroundBarChartRodData(show: true, toY: maxY * 1.15, color: AppColors.surfaceSoft),
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget pipeline() {
    List<Color> colors = [AppColors.warning, AppColors.accent, AppColors.info, AppColors.orange, AppColors.success];
    int total = 0;
    for (String s in AllOrders.stages) {
      total = total + AllOrders.countStatus(s);
    }
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Production pipeline", style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                for (int i = 0; i < AllOrders.stages.length; i++)
                  if (AllOrders.countStatus(AllOrders.stages[i]) > 0)
                    Expanded(
                      flex: AllOrders.countStatus(AllOrders.stages[i]),
                      child: Container(height: 12, color: colors[i]),
                    ),
                if (total == 0) Expanded(child: Container(height: 12, color: AppColors.line)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < AllOrders.stages.length; i++)
            InkWell(
              onTap: () => widget.onOpenOperations(AllOrders.stages[i]),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(AllOrders.stages[i], style: const TextStyle(fontSize: 13))),
                    Text("${AllOrders.countStatus(AllOrders.stages[i])}", style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.soft),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget quickAction(IconData icon, String label, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.line)),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    num revenue = 0;
    for (dynamic o in AllOrders.orderList) {
      if (o["status"] == "Completed") revenue = revenue + o["total"];
    }
    List<dynamic> attention = [];
    for (int i = AllOrders.orderList.length - 1; i >= 0; i--) {
      String s = AllOrders.orderList[i]["status"];
      if (s == "Pending" || s == "Quality Check") attention.add(AllOrders.orderList[i]);
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () async => widget.onRefresh(),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          PageHeader(
            subtitle: "${greeting()}, ${AllUsers.active["firstName"]}",
            title: "Dashboard",
            actions: [IconBadgeButton(icon: Icons.notifications_none, count: AllActivity.unreadCount(email), onTap: () => openPage("/notifications"))],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                  padding: const EdgeInsets.only(top: 8, bottom: 12),
                  children: [
                    StatCard(label: "Waiting assignment", value: "${AllOrders.countStatus("Pending")}", icon: Icons.pending_actions, color: AppColors.warning, bg: AppColors.warningBg, onTap: () => widget.onOpenOperations("Pending")),
                    StatCard(label: "In production", value: "${AllOrders.countStatus("In Production")}", icon: Icons.handyman_outlined, color: AppColors.accent, bg: AppColors.accentSoft, onTap: () => widget.onOpenOperations("In Production")),
                    StatCard(label: "QC queue", value: "${AllOrders.countStatus("Quality Check")}", icon: Icons.fact_check_outlined, color: AppColors.info, bg: AppColors.infoBg, onTap: () => widget.onOpenOperations("Quality Check")),
                    StatCard(label: "Low stock materials", value: "${AllMaterials.lowCount()}", icon: Icons.warning_amber_rounded, color: AppColors.danger, bg: AppColors.dangerBg, onTap: () => widget.onSwitchTab(2)),
                    StatCard(label: "Revenue (completed)", value: Format.pesoShort(revenue), icon: Icons.payments_outlined, color: AppColors.success, bg: AppColors.successBg, onTap: () => openPage("/reports")),
                    StatCard(label: "New custom requests", value: "${AllRequests.countStatus("Submitted")}", icon: Icons.design_services_outlined, color: AppColors.orange, bg: AppColors.orangeBg, onTap: () => openPage("/adminrequests")),
                  ],
                ),
                Row(
                  children: [
                    quickAction(Icons.add_box_outlined, "Add\nProduct", () => widget.onSwitchTab(3)),
                    quickAction(Icons.request_quote_outlined, "Custom\nRequests", () => openPage("/adminrequests")),
                    quickAction(Icons.person_add_alt, "New\nAccount", () {
                      AllUsers.selectedEmail = "";
                      openPage("/accountform");
                    }),
                    quickAction(Icons.bar_chart_rounded, "Sales\nReport", () => openPage("/reports")),
                  ],
                ),
                const SizedBox(height: 8),
                salesChart(),
                const SizedBox(height: 12),
                pipeline(),
                const SizedBox(height: 4),
                SectionTitle("Needs attention", action: attention.isEmpty ? null : "View all", onAction: () => widget.onOpenOperations("All")),
                if (attention.isEmpty)
                  const AppCard(child: Text("All caught up! No orders waiting for you.", style: TextStyle(color: AppColors.muted))),
                for (dynamic o in attention.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      onTap: () {
                        AllOrders.selectedId = o["id"];
                        openPage("/adminorder");
                      },
                      child: Row(
                        children: [
                          Avatar(AllUsers.initials(o["customer"]), size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${o["code"]} • ${AllUsers.fullName(o["customer"])}", style: const TextStyle(fontWeight: FontWeight.w700)),
                                Text(o["status"] == "Pending" ? "Assign a worker" : "Inspect and approve for delivery", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                          ),
                          StatusPill(o["status"]),
                        ],
                      ),
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
