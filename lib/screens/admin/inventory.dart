import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/materials.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';

// Records a stock in / stock out. Shared by the owner and the worker.
// Returns true when saved.
Future<bool> showStockSheet(BuildContext context, dynamic material, {bool workerMode = false}) async {
  String type = workerMode ? "Stock Out" : "Stock In";
  TextEditingController qtyController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  String error = "";

  bool? saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (c) => StatefulBuilder(
      builder: (c, setSheet) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(c).viewInsets.bottom),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(material["name"], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                Text("Current stock: ${material["stock"]} ${material["unit"]}", style: const TextStyle(color: AppColors.muted)),
                const SizedBox(height: 14),
                if (!workerMode)
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: "Stock In", label: Text("Stock In"), icon: Icon(Icons.add)),
                      ButtonSegment(value: "Stock Out", label: Text("Stock Out"), icon: Icon(Icons.remove)),
                    ],
                    selected: {type},
                    onSelectionChanged: (s) => setSheet(() => type = s.first),
                  ),
                const SizedBox(height: 14),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(labelText: "Quantity (${material["unit"]})", border: const OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(labelText: workerMode ? "Used for (ex. ORD-1004)" : "Note (supplier, order, reason)", border: const OutlineInputBorder()),
                ),
                if (error.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(error, style: const TextStyle(color: AppColors.danger))),
                const SizedBox(height: 16),
                AppButton(
                  label: "Save $type",
                  onPressed: () {
                    int? qty = int.tryParse(qtyController.text);
                    if (qty == null || qty <= 0) {
                      setSheet(() => error = "Enter a valid quantity.");
                      return;
                    }
                    if (type == "Stock Out" && qty > material["stock"]) {
                      setSheet(() => error = "Not enough stock. Only ${material["stock"]} ${material["unit"]} left.");
                      return;
                    }
                    material["stock"] = type == "Stock In" ? material["stock"] + qty : material["stock"] - qty;
                    AllMaterials.stockLogs.add({
                      "id": Store.newId(),
                      "materialId": material["id"],
                      "materialName": material["name"],
                      "type": type,
                      "qty": qty,
                      "note": noteController.text.trim(),
                      "by": AllUsers.activeEmail,
                      "date": Format.now(),
                    });
                    AllActivity.log(AllUsers.activeEmail, "${type == "Stock In" ? "Added" : "Took out"} $qty ${material["unit"]} of ${material["name"]}");
                    if (AllMaterials.isLow(material)) {
                      AllActivity.notifyRole("owner", "Low stock: ${material["name"]}", "Only ${material["stock"]} ${material["unit"]} left (reorder at ${material["reorder"]}).", "inventory");
                    }
                    Store.save();
                    Navigator.pop(c, true);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  return saved == true;
}

class InventoryTab extends StatefulWidget {
  final VoidCallback onRefresh;
  const InventoryTab({super.key, required this.onRefresh});

  @override
  State<InventoryTab> createState() => InventoryTabPage();
}

class InventoryTabPage extends State<InventoryTab> {
  String filter = "All";
  String search = "";

  void openForm(String id) {
    AllMaterials.selectedId = id;
    Navigator.pushNamed(context, "/materialform").then((v) => widget.onRefresh());
  }

  Future<void> deleteMaterial(dynamic m) async {
    bool ok = await confirmDialog(context, "Delete Material", "Delete ${m["name"]} from the inventory?", confirm: "Delete", danger: true);
    if (!ok) return;
    AllMaterials.materialList.remove(m);
    Store.save();
    widget.onRefresh();
    if (mounted) showToast(context, "${m["name"]} deleted");
  }

  void openActions(dynamic m) {
    showModalBottomSheet(
      context: context,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(m["name"], style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text("${m["category"]} • ${m["supplier"]}")),
            ListTile(
              leading: const Icon(Icons.swap_vert, color: AppColors.accent),
              title: const Text("Stock In / Stock Out"),
              onTap: () async {
                Navigator.pop(c);
                if (await showStockSheet(context, m)) {
                  widget.onRefresh();
                  if (mounted) showToast(context, "Stock updated");
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined, color: AppColors.accent),
              title: const Text("Edit Material"),
              onTap: () {
                Navigator.pop(c);
                openForm(m["id"]);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text("Delete", style: TextStyle(color: AppColors.danger)),
              onTap: () {
                Navigator.pop(c);
                deleteMaterial(m);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> filters = ["All", "Low Stock", ...AllMaterials.categories];
    List<dynamic> list = [];
    for (dynamic m in AllMaterials.materialList) {
      bool matchFilter = filter == "All" || (filter == "Low Stock" && AllMaterials.isLow(m)) || m["category"] == filter;
      bool matchSearch = search.isEmpty || m["name"].toString().toLowerCase().contains(search.toLowerCase());
      if (matchFilter && matchSearch) list.add(m);
    }

    return Column(
      children: [
        PageHeader(
          title: "Inventory",
          subtitle: "Raw materials",
          actions: [
            IconBadgeButton(icon: Icons.history, onTap: () => Navigator.pushNamed(context, "/stocklogs")),
            IconBadgeButton(icon: Icons.add, onTap: () => openForm("")),
          ],
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(child: StatCard(label: "Materials", value: "${AllMaterials.materialList.length}", icon: Icons.category_outlined, color: AppColors.accent, bg: AppColors.accentSoft)),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: "Low stock", value: "${AllMaterials.lowCount()}", icon: Icons.warning_amber_rounded, color: AppColors.danger, bg: AppColors.dangerBg, onTap: () => setState(() => filter = "Low Stock"))),
                    const SizedBox(width: 10),
                    Expanded(child: StatCard(label: "Value", value: Format.pesoShort(AllMaterials.inventoryValue()), icon: Icons.account_balance_wallet_outlined, color: AppColors.success, bg: AppColors.successBg)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                child: TextField(
                  onChanged: (v) => setState(() => search = v),
                  decoration: InputDecoration(
                    hintText: "Search materials",
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
              const SizedBox(height: 10),
              if (list.isEmpty) const EmptyState(icon: Icons.inventory_2_outlined, title: "No materials", subtitle: "Tap + to add a raw material."),
              for (dynamic m in list)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: AppCard(
                    onTap: () => openActions(m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m["name"], style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                                  Text("${m["category"]} • ${Format.peso(m["unitCost"])}/${m["unit"]}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                                ],
                              ),
                            ),
                            if (AllMaterials.isLow(m)) const StatusPill("Low Stock"),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  minHeight: 8,
                                  value: m["reorder"] <= 0 ? 1.0 : (m["stock"] / (m["reorder"] * 3)).clamp(0.0, 1.0).toDouble(),
                                  backgroundColor: AppColors.line,
                                  color: AllMaterials.isLow(m) ? AppColors.danger : AppColors.success,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text("${m["stock"]} ${m["unit"]}", style: const TextStyle(fontWeight: FontWeight.w800)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text("Reorder level: ${m["reorder"]} ${m["unit"]}", style: const TextStyle(fontSize: 11, color: AppColors.soft)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
