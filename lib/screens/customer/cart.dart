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

class CartState extends StatefulWidget {
  const CartState({super.key});

  @override
  State<CartState> createState() => CartPage();
}

class CartPage extends State<CartState> {
  //UPDATE - change the quantity
  void changeQty(dynamic item, dynamic product, int amount) {
    int newQty = item["qty"] + amount;
    if (newQty < 1) return;
    if (newQty > product["stock"]) {
      showToast(context, "Only ${product["stock"]} left in stock.");
      return;
    }
    setState(() => item["qty"] = newQty);
    Store.save();
  }

  //DELETE - remove from cart
  void removeItem(dynamic item) {
    setState(() => AllOrders.cartList.remove(item));
    Store.save();
    showToast(context, "Item removed from cart");
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> cart = AllOrders.cartOf(AllUsers.activeEmail);
    //products that were deleted by the owner are removed from the cart
    cart.removeWhere((item) {
      if (AllProducts.find(item["productId"]) == null) {
        AllOrders.cartList.remove(item);
        return true;
      }
      return false;
    });

    int subtotal = 0;
    for (dynamic item in cart) {
      subtotal = subtotal + (AllProducts.find(item["productId"])["price"] as int) * (item["qty"] as int);
    }

    return Scaffold(
      appBar: AppBar(title: Text("My Cart (${AllOrders.cartCount(AllUsers.activeEmail)})")),
      body: cart.isEmpty
          ? EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: "Your cart is empty",
              subtitle: "Browse our furniture and add your favorites here.",
              action: SizedBox(width: 200, child: AppButton(label: "Browse Products", small: true, onPressed: () => Navigator.pop(context))),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemCount: cart.length,
              separatorBuilder: (c, i) => const SizedBox(height: 10),
              itemBuilder: (c, i) {
                dynamic item = cart[i];
                dynamic product = AllProducts.find(item["productId"]);
                return Dismissible(
                  key: ValueKey(item["id"]),
                  direction: DismissDirection.endToStart,
                  onDismissed: (d) => removeItem(item),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  child: AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.surfaceSoft, borderRadius: BorderRadius.circular(14)),
                          child: ProductImage(product["image"]),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(child: Text(product["name"], maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700))),
                                  GestureDetector(onTap: () => removeItem(item), child: const Icon(Icons.close, size: 18, color: AppColors.soft)),
                                ],
                              ),
                              Text(product["category"], style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: Text(Format.peso(product["price"]), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand))),
                                  QtyStepper(value: item["qty"], onMinus: () => changeQty(item, product, -1), onPlus: () => changeQty(item, product, 1)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                decoration: const BoxDecoration(color: AppColors.surface, border: Border(top: BorderSide(color: AppColors.line))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InfoRow("Subtotal", Format.peso(subtotal)),
                    InfoRow("Delivery fee", Format.peso(AllOrders.deliveryFee)),
                    const Divider(),
                    InfoRow("Total", Format.peso(subtotal + AllOrders.deliveryFee), bold: true),
                    const SizedBox(height: 10),
                    AppButton(
                      label: "Proceed to Checkout",
                      onPressed: () => Navigator.pushNamed(context, "/checkout").then((v) => setState(() {})),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
