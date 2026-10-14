import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import '../../widgets/product_image.dart';

class ProductDetailState extends StatefulWidget {
  const ProductDetailState({super.key});

  @override
  State<ProductDetailState> createState() => ProductDetailPage();
}

class ProductDetailPage extends State<ProductDetailState> {
  int qty = 1;

  //CREATE - add to cart, buyNow opens the cart right away
  void addToCart(dynamic product, bool buyNow) {
    String error = AllOrders.addToCart(AllUsers.activeEmail, product, qty);
    if (error.isNotEmpty) {
      showToast(context, error);
      return;
    }
    Store.save();
    if (buyNow) {
      Navigator.pushReplacementNamed(context, "/cart");
    } else {
      setState(() => qty = 1);
      showToast(context, "Added to cart");
    }
  }

  Widget spec(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.muted)),
                Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic product = AllProducts.find(AllProducts.selectedId);
    if (product == null) {
      return Scaffold(appBar: AppBar(), body: const EmptyState(icon: Icons.chair_outlined, title: "Product not found", subtitle: "It may have been removed."));
    }
    List<dynamic> reviews = AllProducts.reviewsOf(product["id"]);
    double rating = AllProducts.averageRating(product["id"]);
    int stock = product["stock"];

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.surfaceSoft,
            actions: [
              IconButton(
                icon: Badge(
                  isLabelVisible: AllOrders.cartCount(AllUsers.activeEmail) > 0,
                  label: Text("${AllOrders.cartCount(AllUsers.activeEmail)}"),
                  child: const Icon(Icons.shopping_bag_outlined),
                ),
                onPressed: () => Navigator.pushNamed(context, "/cart").then((v) => setState(() {})),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: const EdgeInsets.fromLTRB(40, 90, 40, 24),
                child: Hero(tag: "product-${product["id"]}", child: ProductImage(product["image"], iconSize: 80)),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product["category"].toString().toUpperCase(), style: const TextStyle(color: AppColors.title, fontWeight: FontWeight.w700, letterSpacing: 1, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(product["name"], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 20),
                      Text(reviews.isEmpty ? " No ratings yet" : " ${rating.toStringAsFixed(1)} • ${reviews.length} review${reviews.length == 1 ? "" : "s"}", style: const TextStyle(fontWeight: FontWeight.w600)),
                      const Spacer(),
                      StatusPill(stock <= 0 ? "Rejected" : stock <= 5 ? "Pending" : "Completed",
                          label: stock <= 0 ? "Out of stock" : stock <= 5 ? "Only $stock left" : "In stock"),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(Format.peso(product["price"]), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.brand)),
                  const SizedBox(height: 16),
                  Text(product["description"], style: const TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5)),
                  const SizedBox(height: 20),
                  spec(Icons.forest_outlined, "Material", product["material"]),
                  spec(Icons.straighten, "Dimensions", product["dimensions"]),
                  spec(Icons.local_shipping_outlined, "Delivery", "Metro Manila • ${Format.peso(AllOrders.deliveryFee)} flat fee"),
                  const SizedBox(height: 10),
                  SectionTitle("Reviews (${reviews.length})"),
                  if (reviews.isEmpty)
                    const Text("Be the first to review this product after your order is delivered.", style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  for (dynamic r in reviews)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Avatar(AllUsers.initials(r["customer"]), size: 30),
                              const SizedBox(width: 10),
                              Expanded(child: Text(AllUsers.fullName(r["customer"]), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13))),
                              Text("★" * (r["rating"] as int), style: const TextStyle(color: AppColors.warning)),
                            ],
                          ),
                          if (r["comment"].toString().isNotEmpty) const SizedBox(height: 8),
                          if (r["comment"].toString().isNotEmpty) Text(r["comment"], style: const TextStyle(fontSize: 13)),
                          const SizedBox(height: 4),
                          Text(Format.date(r["date"]), style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.line))),
          child: Row(
            children: [
              QtyStepper(
                value: qty,
                onMinus: () => setState(() => qty = qty > 1 ? qty - 1 : 1),
                onPlus: () => setState(() => qty = qty < stock ? qty + 1 : qty),
              ),
              const SizedBox(width: 10),
              Expanded(child: AppButton(label: "Add to Cart", variant: "outline", small: true, onPressed: stock <= 0 ? null : () => addToCart(product, false))),
              const SizedBox(width: 8),
              Expanded(child: AppButton(label: "Buy Now", small: true, onPressed: stock <= 0 ? null : () => addToCart(product, true))),
            ],
          ),
        ),
      ),
    );
  }
}
