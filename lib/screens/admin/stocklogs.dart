import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/materials.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

// history of stock movements (InventoryLogsTab of mobile-topcraft)
class StockLogsState extends StatefulWidget {
  const StockLogsState({super.key});

  @override
  State<StockLogsState> createState() => StockLogsPage();
}

class StockLogsPage extends State<StockLogsState> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = [];
    for (int i = AllMaterials.stockLogs.length - 1; i >= 0; i--) {
      dynamic log = AllMaterials.stockLogs[i];
      if (filter == "All" || log["type"] == filter) list.add(log);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Stock Logs")),
      body: Column(
        children: [
          FilterChips(options: const ["All", "Stock In", "Stock Out", "Adjustment"], selected: filter, onSelected: (v) => setState(() => filter = v)),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.history, title: "No stock movements", subtitle: "Stock in and stock out records will show here.")
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (c, i) {
                      dynamic log = list[i];
                      bool isIn = log["type"] == "Stock In" || (log["type"] == "Adjustment" && log["qty"] >= 0);
                      return AppCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(color: isIn ? AppColors.successBg : AppColors.dangerBg, borderRadius: BorderRadius.circular(12)),
                              child: Icon(isIn ? Icons.south_west : Icons.north_east, color: isIn ? AppColors.success : AppColors.danger, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(log["materialName"], style: const TextStyle(fontWeight: FontWeight.w700)),
                                  Text("${log["type"]} • ${AllUsers.fullName(log["by"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                  if (log["note"] != "") Text(log["note"], style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text("${isIn ? "+" : "-"}${(log["qty"] as num).abs()}", style: TextStyle(fontWeight: FontWeight.w800, color: isIn ? AppColors.success : AppColors.danger)),
                                Text(Format.timeAgo(log["date"]), style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                              ],
                            ),
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
