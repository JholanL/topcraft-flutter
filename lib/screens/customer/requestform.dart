import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/requests.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_picker.dart';
import '../../widgets/product_image.dart';

// CREATE / UPDATE custom request (CustomerCustomOrderPage of mobile-topcraft)
class RequestFormState extends StatefulWidget {
  const RequestFormState({super.key});

  @override
  State<RequestFormState> createState() => RequestFormPage();
}

class RequestFormPage extends State<RequestFormState> {
  dynamic editing = AllRequests.find(AllRequests.selectedId);
  late String type = editing?["furnitureType"] ?? "Table";
  late String material = editing?["material"] ?? "Narra Wood";
  late String image = editing?["image"] ?? "";
  late int quantity = editing?["quantity"] ?? 1;
  late final dimensionsController = TextEditingController(text: editing?["dimensions"] ?? "");
  late final finishController = TextEditingController(text: editing?["finish"] ?? "");
  late final budgetController = TextEditingController(text: editing == null ? "" : "${editing["budget"]}");
  late final notesController = TextEditingController(text: editing?["notes"] ?? "");

  Widget choiceGroup(List<String> options, String value, ValueChanged<String> onChanged) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (String o in options)
          ChoiceChip(
            label: Text(o),
            selected: o == value,
            showCheckmark: false,
            labelStyle: TextStyle(color: o == value ? Colors.white : AppColors.text, fontWeight: FontWeight.w600),
            onSelected: (v) => onChanged(o),
          ),
      ],
    );
  }

  void submit() {
    int? budget = int.tryParse(budgetController.text.replaceAll(",", ""));
    if (dimensionsController.text.trim().isEmpty) {
      showToast(context, "Please enter the dimensions (ex. 120 x 60 x 75 cm).");
      return;
    }
    if (budget == null || budget < 1000) {
      showToast(context, "Please enter a budget of at least ₱1,000.");
      return;
    }
    if (notesController.text.trim().length < 10) {
      showToast(context, "Please describe your design (at least 10 characters).");
      return;
    }

    if (editing == null) {
      String code = "CR-${AllRequests.requestCounter}";
      AllRequests.requestCounter++;
      AllRequests.requestList.add({
        "id": Store.newId(),
        "code": code,
        "customer": AllUsers.activeEmail,
        "furnitureType": type,
        "dimensions": dimensionsController.text.trim(),
        "material": material,
        "finish": finishController.text.trim(),
        "quantity": quantity,
        "budget": budget,
        "notes": notesController.text.trim(),
        "image": image,
        "status": "Submitted",
        "quotePrice": 0,
        "quoteNote": "",
        "leadDays": 0,
        "orderId": "",
        "createdAt": Format.now(),
        "updatedAt": Format.now(),
      });
      AllActivity.notifyRole("owner", "New custom request $code", "${AllUsers.fullName(AllUsers.activeEmail)} requested a $material $type.", "request");
      showToast(context, "Request $code submitted!");
    } else {
      editing["furnitureType"] = type;
      editing["dimensions"] = dimensionsController.text.trim();
      editing["material"] = material;
      editing["finish"] = finishController.text.trim();
      editing["quantity"] = quantity;
      editing["budget"] = budget;
      editing["notes"] = notesController.text.trim();
      editing["image"] = image;
      editing["updatedAt"] = Format.now();
      showToast(context, "Request updated.");
    }
    Store.save();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing == null ? "New Custom Request" : "Edit ${editing["code"]}")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionTitle("Furniture type"),
          choiceGroup(AllRequests.furnitureTypes, type, (v) => setState(() => type = v)),
          const SizedBox(height: 12),
          const SectionTitle("Material"),
          choiceGroup(AllRequests.materials, material, (v) => setState(() => material = v)),
          const SizedBox(height: 16),
          AppTextField(controller: dimensionsController, label: "Dimensions (L x W x H)", hint: "ex. 120 x 60 x 75 cm", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: finishController, label: "Color / Finish", hint: "ex. Walnut stain, matte black legs", pill: false),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: AppTextField(controller: budgetController, label: "Budget", hint: "25000", prefixText: "₱ ", keyboardType: TextInputType.number, pill: false)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(padding: EdgeInsets.only(left: 6, bottom: 6), child: Text("Quantity", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted))),
                  Container(
                    height: 54,
                    alignment: Alignment.center,
                    child: QtyStepper(value: quantity, onMinus: () => setState(() => quantity = quantity > 1 ? quantity - 1 : 1), onPlus: () => setState(() => quantity++)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppTextField(controller: notesController, label: "Describe your design", hint: "Tell us the style, purpose and other details...", maxLines: 4, pill: false),
          const SizedBox(height: 16),
          const SectionTitle("Reference photo (optional)"),
          GestureDetector(
            onTap: () async {
              String? picked = await pickPhoto(context, builtIn: false);
              if (picked != null) setState(() => image = picked);
            },
            child: Container(
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.field),
              ),
              clipBehavior: Clip.antiAlias,
              child: image == ""
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.soft),
                        SizedBox(height: 6),
                        Text("Tap to upload a photo or sketch", style: TextStyle(color: AppColors.muted)),
                      ],
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImage(image, fit: BoxFit.cover),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: Colors.black54),
                            onPressed: () => setState(() => image = ""),
                            icon: const Icon(Icons.close, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(label: editing == null ? "Submit Request" : "Save Changes", onPressed: () => submit()),
        ],
      ),
    );
  }
}
