import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/common.dart';
import '../../widgets/product_card.dart';
import '../../widgets/product_image.dart';

// Shop tab (CustomerEcommercePage of mobile-topcraft)
class ShopTab extends StatefulWidget {
  final VoidCallback onRefresh;
  final ValueChanged<int> onSwitchTab;
  const ShopTab({super.key, required this.onRefresh, required this.onSwitchTab});

  @override
  State<ShopTab> createState() => ShopTabPage();
}

class ShopTabPage extends State<ShopTab> {
  String search = "";
  String category = "All";
  final searchController = TextEditingController();
  final PageController featuredController = PageController(viewportFraction: 0.86);

  void openPage(String route) {
    Navigator.pushNamed(context, route).then((value) => widget.onRefresh());
  }

  void openProduct(dynamic product) {
    AllProducts.selectedId = product["id"];
    openPage("/product");
  }

  void quickAdd(dynamic product) {
    String error = AllOrders.addToCart(AllUsers.activeEmail, product, 1);
    if (error.isNotEmpty) {
      showToast(context, error);
      return;
    }
    Store.save();
    widget.onRefresh();
    showToast(context, "${product["name"]} added to cart");
  }

  List<dynamic> filteredProducts() {
    List<dynamic> list = [];
    String q = search.trim().toLowerCase();
    for (int i = 0; i < AllProducts.productList.length; i++) {
      dynamic p = AllProducts.productList[i];
      bool matchCategory = category == "All" || p["category"] == category;
      bool matchSearch = q.isEmpty || "${p["name"]} ${p["category"]} ${p["description"]}".toLowerCase().contains(q);
      if (matchCategory && matchSearch) list.add(p);
    }
    return list;
  }

  List<String> categoryList() {
    List<String> list = ["All"];
    for (int i = 0; i < AllProducts.productList.length; i++) {
      String c = AllProducts.productList[i]["category"];
      if (!list.contains(c)) list.add(c);
    }
    return list;
  }

  String categoryImage(String c) {
    for (int i = 0; i < AllProducts.productList.length; i++) {
      if (AllProducts.productList[i]["category"] == c) return AllProducts.productList[i]["image"];
    }
    return "";
  }

  Widget heroBanner() {
    return Container(
      height: 150,
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        image: const DecorationImage(image: AssetImage("assets/images/hero.jpg"), fit: BoxFit.cover, alignment: Alignment(0, 0.3)),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(colors: [Colors.black.withValues(alpha: 0.75), Colors.black.withValues(alpha: 0.05)]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("CRAFTED IN MANILA", style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            const Text("Have a design\nin mind?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, height: 1.2)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => widget.onSwitchTab(2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: const Text("Request Custom", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget categoryRow() {
    List<String> list = categoryList();
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: list.length,
        separatorBuilder: (c, i) => const SizedBox(width: 14),
        itemBuilder: (c, i) {
          bool active = list[i] == category;
          return GestureDetector(
            onTap: () => setState(() => category = list[i]),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.black : AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: active ? AppColors.black : AppColors.line),
                  ),
                  child: list[i] == "All"
                      ? Icon(Icons.grid_view_rounded, color: active ? Colors.white : AppColors.text)
                      : ProductImage(categoryImage(list[i]), iconSize: 24),
                ),
                const SizedBox(height: 6),
                Text(list[i], style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget featuredCarousel() {
    List<dynamic> featured = [];
    for (dynamic p in AllProducts.productList) {
      if (p["featured"] == true) featured.add(p);
    }
    if (featured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: SectionTitle("Featured")),
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: featuredController,
            padEnds: false,
            itemCount: featured.length,
            itemBuilder: (c, i) {
              dynamic p = featured[i];
              return GestureDetector(
                onTap: () => openProduct(p),
                child: Container(
                  margin: EdgeInsets.only(left: i == 0 ? 20 : 6, right: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF2A211C), Color(0xFF5C3A28)]),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p["category"].toString().toUpperCase(), style: const TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                            const SizedBox(height: 6),
                            Text(p["name"], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, height: 1.2)),
                            const SizedBox(height: 8),
                            Text(Format.pesoShort(p["price"]), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                              child: const Text("Shop now", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 110, child: ProductImage(p["image"])),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String email = AllUsers.activeEmail;
    List<dynamic> products = filteredProducts();
    bool browsing = search.isEmpty && category == "All";

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: PageHeader(
            subtitle: "Hello, ${AllUsers.active["firstName"]} 👋",
            title: "Find your piece",
            actions: [
              IconBadgeButton(icon: Icons.notifications_none, count: AllActivity.unreadCount(email), onTap: () => openPage("/notifications")),
              IconBadgeButton(icon: Icons.shopping_bag_outlined, count: AllOrders.cartCount(email), onTap: () => openPage("/cart")),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: searchController,
              onChanged: (v) => setState(() => search = v),
              decoration: InputDecoration(
                hintText: "Search chairs, tables...",
                hintStyle: const TextStyle(color: AppColors.soft),
                prefixIcon: const Icon(Icons.search, color: AppColors.soft),
                suffixIcon: search.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() {
                          search = "";
                          searchController.clear();
                        }),
                      ),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
              ),
            ),
          ),
        ),
        if (browsing) SliverToBoxAdapter(child: heroBanner()),
        const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.fromLTRB(20, 8, 20, 0), child: SectionTitle("Categories"))),
        SliverToBoxAdapter(child: categoryRow()),
        if (browsing) SliverToBoxAdapter(child: featuredCarousel()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SectionTitle(category == "All" ? "All Products (${products.length})" : "$category (${products.length})"),
          ),
        ),
        if (products.isEmpty)
          const SliverToBoxAdapter(
            child: EmptyState(icon: Icons.search_off, title: "No products found", subtitle: "Try adjusting your search or category."),
          ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.66,
            ),
            delegate: SliverChildBuilderDelegate(
              (c, i) => ProductCard(product: products[i], onTap: () => openProduct(products[i]), onAdd: () => quickAdd(products[i])),
              childCount: products.length,
            ),
          ),
        ),
      ],
    );
  }
}
