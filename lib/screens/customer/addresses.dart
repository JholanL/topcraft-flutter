import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/addresses.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';

class AddressesState extends StatefulWidget {
  const AddressesState({super.key});

  @override
  State<AddressesState> createState() => AddressesPage();
}

class AddressesPage extends State<AddressesState> {
  void openForm(String id) {
    AllAddresses.selectedId = id;
    Navigator.pushNamed(context, "/addressform").then((v) => setState(() {}));
  }

  //UPDATE - make it the default address
  void setDefault(dynamic address) {
    setState(() {
      for (dynamic a in AllAddresses.ofUser(AllUsers.activeEmail)) {
        a["isDefault"] = a["id"] == address["id"];
      }
    });
    Store.save();
    showToast(context, "${address["label"]} is now your default address");
  }

  //DELETE
  Future<void> deleteAddress(dynamic address) async {
    bool ok = await confirmDialog(context, "Delete Address", "Delete your ${address["label"]} address?", confirm: "Delete", danger: true);
    if (!ok) return;
    setState(() {
      AllAddresses.addressList.remove(address);
      List<dynamic> left = AllAddresses.ofUser(AllUsers.activeEmail);
      if (address["isDefault"] == true && left.isNotEmpty) left[0]["isDefault"] = true;
    });
    Store.save();
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> list = AllAddresses.ofUser(AllUsers.activeEmail);

    return Scaffold(
      appBar: AppBar(title: const Text("My Addresses")),
      body: list.isEmpty
          ? const EmptyState(icon: Icons.location_off_outlined, title: "No addresses yet", subtitle: "Add a delivery address for your orders.")
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: list.length,
              separatorBuilder: (c, i) => const SizedBox(height: 10),
              itemBuilder: (c, i) {
                dynamic a = list[i];
                return AppCard(
                  onTap: () => openForm(a["id"]),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(color: AppColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                        child: Icon(a["label"] == "Office" ? Icons.business_outlined : a["label"] == "Home" ? Icons.home_outlined : Icons.place_outlined, color: AppColors.accent),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(a["label"], style: const TextStyle(fontWeight: FontWeight.w800)),
                                if (a["isDefault"] == true) const Padding(padding: EdgeInsets.only(left: 8), child: StatusPill("Completed", label: "Default")),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text("${a["recipient"]} • ${a["phone"]}", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text(AllAddresses.fullText(a), style: const TextStyle(fontSize: 13, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (v) {
                          if (v == "edit") openForm(a["id"]);
                          if (v == "default") setDefault(a);
                          if (v == "delete") deleteAddress(a);
                        },
                        itemBuilder: (c) => [
                          const PopupMenuItem(value: "edit", child: Text("Edit")),
                          if (a["isDefault"] != true) const PopupMenuItem(value: "default", child: Text("Set as default")),
                          const PopupMenuItem(value: "delete", child: Text("Delete", style: TextStyle(color: AppColors.danger))),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(label: "Add New Address", icon: Icons.add, onPressed: () => openForm("")),
        ),
      ),
    );
  }
}
