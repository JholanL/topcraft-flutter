import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/materials.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';

// CREATE / UPDATE raw material
class MaterialFormState extends StatefulWidget {
  const MaterialFormState({super.key});

  @override
  State<MaterialFormState> createState() => MaterialFormPage();
}

class MaterialFormPage extends State<MaterialFormState> {
  dynamic editing = AllMaterials.find(AllMaterials.selectedId);
  late String category = editing?["category"] ?? "Wood";
  late final nameController = TextEditingController(text: editing?["name"] ?? "");
  late final unitController = TextEditingController(text: editing?["unit"] ?? "pcs");
  late final stockController = TextEditingController(text: editing == null ? "" : "${editing["stock"]}");
  late final reorderController = TextEditingController(text: editing == null ? "" : "${editing["reorder"]}");
  late final costController = TextEditingController(text: editing == null ? "" : "${editing["unitCost"]}");
  late final supplierController = TextEditingController(text: editing?["supplier"] ?? "");

  void save() {
    int? stock = int.tryParse(stockController.text);
    int? reorder = int.tryParse(reorderController.text);
    int? cost = int.tryParse(costController.text);
    if (nameController.text.trim().isEmpty || unitController.text.trim().isEmpty) {
      showToast(context, "Name and unit are required.");
      return;
    }
    if (stock == null || stock < 0 || reorder == null || reorder < 0 || cost == null || cost < 0) {
      showToast(context, "Please enter valid numbers for stock, reorder level and cost.");
      return;
    }
    if (editing == null) {
      String id = Store.newId();
      AllMaterials.materialList.add({
        "id": id,
        "name": nameController.text.trim(),
        "category": category,
        "unit": unitController.text.trim(),
        "stock": stock,
        "reorder": reorder,
        "unitCost": cost,
        "supplier": supplierController.text.trim(),
      });
      AllMaterials.stockLogs.add({"id": Store.newId(), "materialId": id, "materialName": nameController.text.trim(), "type": "Stock In", "qty": stock, "note": "Initial stock", "by": AllUsers.activeEmail, "date": Format.now()});
      showToast(context, "Material added");
    } else {
      if (stock != editing["stock"]) {
        AllMaterials.stockLogs.add({"id": Store.newId(), "materialId": editing["id"], "materialName": nameController.text.trim(), "type": "Adjustment", "qty": stock - editing["stock"], "note": "Manual stock count", "by": AllUsers.activeEmail, "date": Format.now()});
      }
      editing["name"] = nameController.text.trim();
      editing["category"] = category;
      editing["unit"] = unitController.text.trim();
      editing["stock"] = stock;
      editing["reorder"] = reorder;
      editing["unitCost"] = cost;
      editing["supplier"] = supplierController.text.trim();
      showToast(context, "Material updated");
    }
    Store.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing == null ? "Add Material" : "Edit Material")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          AppTextField(controller: nameController, label: "Material name", hint: "ex. Black Steel Pipe 1in", pill: false),
          const SizedBox(height: 14),
          const SectionTitle("Category"),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (String c in AllMaterials.categories)
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
              Expanded(child: AppTextField(controller: unitController, label: "Unit", hint: "pcs", pill: false)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: costController, label: "Unit cost", hint: "350", prefixText: "₱ ", keyboardType: TextInputType.number, pill: false)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: AppTextField(controller: stockController, label: editing == null ? "Starting stock" : "Current stock", hint: "0", keyboardType: TextInputType.number, pill: false)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: reorderController, label: "Reorder level", hint: "10", keyboardType: TextInputType.number, pill: false)),
            ],
          ),
          const SizedBox(height: 14),
          AppTextField(controller: supplierController, label: "Supplier", hint: "ex. Manila Steel Supply", pill: false),
          const SizedBox(height: 24),
          AppButton(label: editing == null ? "Add Material" : "Save Changes", onPressed: () => save()),
        ],
      ),
    );
  }
}
