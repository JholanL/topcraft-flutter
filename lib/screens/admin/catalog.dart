import 'package:flutter/material.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

// Catalog tab: product list for the owner (AdminCatalogListPage)
class CatalogTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const CatalogTab({super.key, required this.onRefresh});

  @override
  State<CatalogTab> createState() => CatalogTabPage();
}

class CatalogTabPage extends State<CatalogTab> {
  String filter = "All";
  String search = "";

  void openForm(String id) {
    AllProducts.selectedId = id;
    Navigator.pushNamed(context, "/productform").then((v) => widget.onRefresh());
  }

  //UPDATE - show/hide on the featured carousel
  void toggleFeatured(dynamic p) {
    setState(() => p["featured"] = !(p["featured"] == true));
    Store.save();
    showToast(context, p["featured"] ? "${p["name"]} is now featured" : "${p["name"]} removed from featured");
  }

  //DELETE
  Future<void> deleteProduct(dynamic p) async {
    bool ok = await confirmDialog(context, "Delete Product", "Delete ${p["name"]} from the catalog? Customers won't see it anymore.", confirm: "Delete", danger: true);
    if (!ok) return;
    AllProducts.productList.remove(p);
    AllOrders.cartList.removeWhere((c) => c["productId"] == p["id"]);
    Store.save();
    widget.onRefresh();
    if (mounted) showToast(context, "${p["name"]} deleted");
  }

  @override
  Widget build(BuildContext context) {
    List<String> filters = ["All", "Low Stock", ...AllProducts.categories];
    List<dynamic> list = [];
    for (dynamic p in AllProducts.productList) {
      bool matchFilter = filter == "All" || (filter == "Low Stock" && p["stock"] <= 5) || p["category"] == filter;
      bool matchSearch = search.isEmpty || p["name"].toString().toLowerCase().contains(search.toLowerCase());
      if (matchFilter && matchSearch) list.add(p);
    }

    return Column(
      children: [
        PageHeader(
          title: "Catalog",
          subtitle: "${AllProducts.productList.length} products",
          actions: [IconBadgeButton(icon: Icons.add, onTap: () => openForm(""))],
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: TextField(
            onChanged: (v) => setState(() => search = v),
            decoration: InputDecoration(
              hintText: "Search products",
              prefixIcon: const Icon(Icons.search, color: AppColors.soft),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
            ),
          ),
        ),
        FilterChips(options: filters, selected: filter, onSelected: (v) => setState(() => filter = v)),
        const SizedBox(height: 8),
        Expanded(
          child: list.isEmpty
              ? ListView(children: const [EmptyState(icon: Icons.chair_outlined, title: "No products", subtitle: "Tap + to add a product to the catalog.")])
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 10),
                  itemBuilder: (c, i) {
                    dynamic p = list[i];
                    double rating = AllProducts.averageRating(p["id"]);
                    int sold = AllProducts.soldCount(p["id"], AllOrders.orderList);
                    return AppCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => openForm(p["id"]),
                      child: Row(
                        children: [
                          Container(
                            width: 78,
                            height: 78,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(14)),
                            child: ProductImage(p["image"]),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(p["name"], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                                    if (p["featured"] == true) const Icon(Icons.star_rounded, size: 18, color: AppColors.tabActive),
                                  ],
                                ),
                                Text(p["category"], style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                const SizedBox(height: 6),
                                Text(Format.peso(p["price"]), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusPill(p["stock"] <= 0 ? "Rejected" : p["stock"] <= 5 ? "Pending" : "Completed", label: "Stock ${p["stock"]}"),
                                    const SizedBox(width: 6),
                                    Text("$sold sold${rating > 0 ? " • ★ ${rating.toStringAsFixed(1)}" : ""}", style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == "edit") openForm(p["id"]);
                              if (v == "feature") toggleFeatured(p);
                              if (v == "delete") deleteProduct(p);
                            },
                            itemBuilder: (c) => [
                              const PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(value: "feature", child: Text(p["featured"] == true ? "Remove from featured" : "Mark as featured")),
                              const PopupMenuItem(value: "delete", child: Text("Delete", style: TextStyle(color: AppColors.danger))),
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
