import 'package:flutter/material.dart';
import '../../glob/products.dart';
import '../../glob/orders.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/product_image.dart';

// CREATE / UPDATE / DELETE product (AdminCatalogProductDetailPage)
class ProductFormState extends StatefulWidget {
  const ProductFormState({super.key});

  @override
  State<ProductFormState> createState() => ProductFormPage();
}

class ProductFormPage extends State<ProductFormState> {
  dynamic editing = AllProducts.find(AllProducts.selectedId);
  late String image = editing?["image"] ?? "";
  late String category = editing?["category"] ?? "Chairs";
  late bool featured = editing?["featured"] ?? false;
  late final nameController = TextEditingController(text: editing?["name"] ?? "");
  late final priceController = TextEditingController(text: editing == null ? "" : "${editing["price"]}");
  late final stockController = TextEditingController(text: editing == null ? "" : "${editing["stock"]}");
  late final materialController = TextEditingController(text: editing?["material"] ?? "");
  late final dimensionsController = TextEditingController(text: editing?["dimensions"] ?? "");
  late final descriptionController = TextEditingController(text: editing?["description"] ?? "");

  void save() {
    int? price = int.tryParse(priceController.text.replaceAll(",", ""));
    int? stock = int.tryParse(stockController.text);
    if (image == "") {
      showToast(context, "Please add a product photo.");
      return;
    }
    if (nameController.text.trim().isEmpty) {
      showToast(context, "Product name is required.");
      return;
    }
    if (price == null || price <= 0) {
      showToast(context, "Please enter a valid price.");
      return;
    }
    if (stock == null || stock < 0) {
      showToast(context, "Please enter a valid stock.");
      return;
    }
    if (editing == null) {
      AllProducts.productList.add({
        "id": Store.newId(),
        "name": nameController.text.trim(),
        "category": category,
        "price": price,
        "stock": stock,
        "material": materialController.text.trim().isEmpty ? "-" : materialController.text.trim(),
        "dimensions": dimensionsController.text.trim().isEmpty ? "-" : dimensionsController.text.trim(),
        "description": descriptionController.text.trim(),
        "image": image,
        "featured": featured,
        "createdAt": Format.now(),
      });
      showToast(context, "Product added to the catalog");
    } else {
      editing["name"] = nameController.text.trim();
      editing["category"] = category;
      editing["price"] = price;
      editing["stock"] = stock;
      editing["material"] = materialController.text.trim().isEmpty ? "-" : materialController.text.trim();
      editing["dimensions"] = dimensionsController.text.trim().isEmpty ? "-" : dimensionsController.text.trim();
      editing["description"] = descriptionController.text.trim();
      editing["image"] = image;
      editing["featured"] = featured;
      showToast(context, "Product updated");
    }
    Store.save();
    Navigator.pop(context);
  }

  Future<void> deleteProduct() async {
    bool ok = await confirmDialog(context, "Delete Product", "Delete ${editing["name"]} from the catalog?", confirm: "Delete", danger: true);
    if (!ok || !mounted) return;
    AllProducts.productList.remove(editing);
    AllOrders.cartList.removeWhere((c) => c["productId"] == editing["id"]);
    Store.save();
    showToast(context, "Product deleted");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing == null ? "Add Product" : "Edit Product"),
        actions: [
          if (editing != null) IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteProduct()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          GestureDetector(
            onTap: () async {
              String? picked = await pickPhoto(context);
              if (picked != null) setState(() => image = picked);
            },
            child: Container(
              height: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceSoft,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.line),
              ),
              child: image == ""
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.soft),
                        SizedBox(height: 8),
                        Text("Add product photo", style: TextStyle(fontWeight: FontWeight.w600)),
                        Text("Gallery, camera or built-in photo", style: TextStyle(fontSize: 12, color: AppColors.muted)),
                      ],
                    )
                  : Stack(
                      children: [
                        Positioned.fill(child: ProductImage(image)),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(20)),
                            child: const Text("Change photo", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(controller: nameController, label: "Product name", hint: "ex. Kyoto Dining Armchair", pill: false),
          const SizedBox(height: 14),
          const SectionTitle("Category"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (String c in AllProducts.categories)
                ChoiceChip(
                  label: Text(c),
                  selected: category == c,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: category == c ? Colors.white : AppColors.text, fontWeight: FontWeight.w600),
                  onSelected: (v) => setState(() => category = c),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AppTextField(controller: priceController, label: "Price", hint: "6800", prefixText: "₱ ", keyboardType: TextInputType.number, pill: false)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: stockController, label: "Stock", hint: "10", keyboardType: TextInputType.number, pill: false)),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(controller: materialController, label: "Material", hint: "ex. Solid acacia wood", pill: false),
          const SizedBox(height: 14),
          AppTextField(controller: dimensionsController, label: "Dimensions", hint: "ex. 52 x 50 x 78 cm", pill: false),
          const SizedBox(height: 14),
          AppTextField(controller: descriptionController, label: "Description", hint: "Describe the product...", maxLines: 4, pill: false),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.accent,
            title: const Text("Featured product", style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: const Text("Show on the Featured carousel of the Shop"),
            value: featured,
            onChanged: (v) => setState(() => featured = v),
          ),
          const SizedBox(height: 16),
          AppButton(label: editing == null ? "Add Product" : "Save Changes", onPressed: () => save()),
        ],
      ),
    );
  }
}
