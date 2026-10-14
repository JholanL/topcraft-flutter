import 'package:flutter/material.dart';
import '../glob/products.dart';
import '../theme/app_colors.dart';
import '../theme/format.dart';
import 'product_image.dart';

// 2-column grid card of the Shop tab (ProductGridCard of mobile-topcraft)
class ProductCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const ProductCard({super.key, required this.product, required this.onTap, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    double rating = AllProducts.averageRating(product["id"]);
    int reviews = AllProducts.reviewsOf(product["id"]).length;
    bool outOfStock = product["stock"] <= 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.line),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Hero(
                      tag: "product-${product["id"]}",
                      child: ProductImage(product["image"]),
                    ),
                  ),
                  if (outOfStock)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(8)),
                        child: const Text("Sold out", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 2, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product["category"].toString().toUpperCase(),
                    style: const TextStyle(fontSize: 10, letterSpacing: 0.8, fontWeight: FontWeight.w700, color: AppColors.title),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product["name"],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reviews == 0 ? "No ratings yet" : "★ ${rating.toStringAsFixed(1)} ($reviews)",
                    style: TextStyle(fontSize: 11, color: reviews == 0 ? AppColors.soft : AppColors.warning, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Format.pesoShort(product["price"]),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.brand),
                        ),
                      ),
                      Material(
                        color: outOfStock ? AppColors.line : AppColors.black,
                        borderRadius: BorderRadius.circular(10),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: outOfStock ? null : onAdd,
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(Icons.add, size: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
