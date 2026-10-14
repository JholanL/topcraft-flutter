import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/addresses.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';

// CREATE / UPDATE delivery address
class AddressFormState extends StatefulWidget {
  const AddressFormState({super.key});

  @override
  State<AddressFormState> createState() => AddressFormPage();
}

class AddressFormPage extends State<AddressFormState> {
  dynamic editing = AllAddresses.find(AllAddresses.selectedId);
  late String label = editing?["label"] ?? "Home";
  late bool isDefault = editing?["isDefault"] ?? AllAddresses.ofUser(AllUsers.activeEmail).isEmpty;
  late final recipientController = TextEditingController(text: editing?["recipient"] ?? "${AllUsers.active["firstName"]} ${AllUsers.active["lastName"]}");
  late final phoneController = TextEditingController(text: editing?["phone"] ?? AllUsers.active["phone"]);
  late final streetController = TextEditingController(text: editing?["street"] ?? "");
  late final barangayController = TextEditingController(text: editing?["barangay"] ?? "");
  late final cityController = TextEditingController(text: editing?["city"] ?? "");
  late final provinceController = TextEditingController(text: editing?["province"] ?? "Metro Manila");

  void save() {
    if (recipientController.text.trim().isEmpty ||
        streetController.text.trim().isEmpty ||
        barangayController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        provinceController.text.trim().isEmpty) {
      showToast(context, "Please complete all address fields.");
      return;
    }
    if (!RegExp(r"^09\d{9}$").hasMatch(phoneController.text.trim())) {
      showToast(context, "Please enter a valid mobile number (09XXXXXXXXX).");
      return;
    }

    dynamic data = editing ?? {"id": Store.newId(), "email": AllUsers.activeEmail};
    data["label"] = label;
    data["recipient"] = recipientController.text.trim();
    data["phone"] = phoneController.text.trim();
    data["street"] = streetController.text.trim();
    data["barangay"] = barangayController.text.trim();
    data["city"] = cityController.text.trim();
    data["province"] = provinceController.text.trim();
    data["isDefault"] = isDefault;
    if (editing == null) AllAddresses.addressList.add(data);
    if (isDefault) {
      for (dynamic a in AllAddresses.ofUser(AllUsers.activeEmail)) {
        a["isDefault"] = a["id"] == data["id"];
      }
    }
    Store.save();
    showToast(context, editing == null ? "Address added" : "Address updated");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(editing == null ? "New Address" : "Edit Address")),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const SectionTitle("Label"),
          Wrap(
            spacing: 8,
            children: [
              for (String l in ["Home", "Office", "Other"])
                ChoiceChip(
                  label: Text(l),
                  selected: label == l,
                  showCheckmark: false,
                  labelStyle: TextStyle(color: label == l ? Colors.white : AppColors.text, fontWeight: FontWeight.w600),
                  onSelected: (v) => setState(() => label = l),
                ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(controller: recipientController, label: "Recipient name", hint: "Full name", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: phoneController, label: "Mobile number", hint: "09XXXXXXXXX", keyboardType: TextInputType.phone, pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: streetController, label: "House no. / Street", hint: "12 Mabini St.", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: barangayController, label: "Barangay", hint: "Brgy. San Roque", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: cityController, label: "City / Municipality", hint: "Quezon City", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: provinceController, label: "Province / Region", hint: "Metro Manila", pill: false),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: AppColors.accent,
            title: const Text("Set as default address", style: TextStyle(fontWeight: FontWeight.w600)),
            value: isDefault,
            onChanged: (v) => setState(() => isDefault = v),
          ),
          const SizedBox(height: 16),
          AppButton(label: "Save Address", onPressed: () => save()),
        ],
      ),
    );
  }
}
