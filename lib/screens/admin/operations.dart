import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/orders.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';

// Operations tab: all orders grouped by production stage (AdminOperationsPage)
class OperationsTab extends StatefulWidget {
  final VoidCallback onRefresh;
  final String initialFilter;
  const OperationsTab({super.key, required this.onRefresh, this.initialFilter = "All"});

  @override
  State<OperationsTab> createState() => OperationsTabPage();
}

class OperationsTabPage extends State<OperationsTab> {
  late String filter = widget.initialFilter;
  String search = "";

  @override
  Widget build(BuildContext context) {
    List<String> filters = ["All", ...AllOrders.stages, "Cancelled"];
    Map<String, int> counts = {"All": AllOrders.orderList.length};
    for (String s in filters.skip(1)) {
      counts[s] = AllOrders.countStatus(s);
    }
    List<dynamic> list = [];
    String q = search.toLowerCase();
    for (int i = AllOrders.orderList.length - 1; i >= 0; i--) {
      dynamic o = AllOrders.orderList[i];
      bool matchFilter = filter == "All" || o["status"] == filter;
      bool matchSearch = q.isEmpty || "${o["code"]} ${AllUsers.fullName(o["customer"])}".toLowerCase().contains(q);
      if (matchFilter && matchSearch) list.add(o);
    }

    return Column(
      children: [
        const PageHeader(title: "Operations", subtitle: "Orders and production"),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Search order code or customer",
              hintStyle: const TextStyle(color: AppColors.soft),
              prefixIcon: const Icon(Icons.search, color: AppColors.soft),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
            ),
          ),
        ),
        FilterChips(options: filters, selected: filter, counts: counts, onSelected: (v) => setState(() => filter = v)),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? ListView(children: const [EmptyState(icon: Icons.inbox_outlined, title: "No orders", subtitle: "Orders in this stage will appear here.")])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (c, i) {
                    dynamic o = list[i];
                    return AppCard(
                      onTap: () {
                        AllOrders.selectedId = o["id"];
                        Navigator.pushNamed(context, "/adminorder").then((v) => widget.onRefresh());
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Avatar(AllUsers.initials(o["customer"]), size: 36),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(AllUsers.fullName(o["customer"]), style: const TextStyle(fontWeight: FontWeight.w600)),
                                    Text(AllOrders.itemSummary(o), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                  ],
                                ),
                              ),
                              Text(Format.pesoShort(o["total"]), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand)),
                            ],
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(Icons.engineering_outlined, size: 16, color: AppColors.muted),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  o["worker"] == "" ? "No worker assigned" : AllUsers.fullName(o["worker"]),
                                  style: TextStyle(fontSize: 12, color: o["worker"] == "" ? AppColors.warning : AppColors.text, fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(Format.timeAgo(o["updatedAt"]), style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                            ],
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
