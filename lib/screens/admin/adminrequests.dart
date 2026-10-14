import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// list of custom requests for the owner (AdminInquiriesListPage)
class AdminRequestsState extends StatefulWidget {
  const AdminRequestsState({super.key});

  @override
  State<AdminRequestsState> createState() => AdminRequestsPage();
}

class AdminRequestsPage extends State<AdminRequestsState> {
  String filter = "All";

  @override
  Widget build(BuildContext context) {
    List<String> filters = ["All", "Submitted", "Quoted", "Approved", "Rejected", "Withdrawn"];
    Map<String, int> counts = {"All": AllRequests.requestList.length};
    for (String f in filters.skip(1)) {
      counts[f] = AllRequests.countStatus(f);
    }
    List<dynamic> list = [];
    for (int i = AllRequests.requestList.length - 1; i >= 0; i--) {
      if (filter == "All" || AllRequests.requestList[i]["status"] == filter) list.add(AllRequests.requestList[i]);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Custom Requests")),
      body: Column(
        children: [
          FilterChips(options: filters, selected: filter, counts: counts, onSelected: (v) => setState(() => filter = v)),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const EmptyState(icon: Icons.design_services_outlined, title: "No requests", subtitle: "Custom requests from customers will show here.")
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: list.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 10),
                    itemBuilder: (c, i) {
                      dynamic r = list[i];
                      return AppCard(
                        onTap: () {
                          AllRequests.selectedId = r["id"];
                          Navigator.pushNamed(context, "/adminrequest").then((v) => setState(() {}));
                        },
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(14)),
                              clipBehavior: Clip.antiAlias,
                              child: r["image"] == "" ? const Icon(Icons.design_services_outlined, color: AppColors.accent) : ProductImage(r["image"], fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${r["code"]} • ${r["furnitureType"]}", style: const TextStyle(fontWeight: FontWeight.w800)),
                                  Text(AllUsers.fullName(r["customer"]), style: const TextStyle(fontSize: 13)),
                                  Text("Budget ${Format.peso(r["budget"])} • ${Format.timeAgo(r["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            StatusPill(r["status"]),
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
