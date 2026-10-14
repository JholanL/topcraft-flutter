import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';

// accounts list for the owner (AdminAccountsListPage)
class AccountsState extends StatefulWidget {
  const AccountsState({super.key});

  @override
  State<AccountsState> createState() => AccountsPage();
}

class AccountsPage extends State<AccountsState> {
  String filter = "All";
  String search = "";

  void openForm(String email) {
    AllUsers.selectedEmail = email;
    Navigator.pushNamed(context, "/accountform").then((v) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> roleOf = {"Owners": "owner", "Workers": "worker", "Customers": "customer"};
    List<String> filters = ["All", "Owners", "Workers", "Customers"];
    Map<String, int> counts = {
      "All": AllUsers.userList.length,
      "Owners": AllUsers.byRole("owner").length,
      "Workers": AllUsers.byRole("worker").length,
      "Customers": AllUsers.byRole("customer").length,
    };
    List<dynamic> list = [];
    for (dynamic u in AllUsers.userList) {
      bool matchFilter = filter == "All" || u["role"] == roleOf[filter];
      bool matchSearch = search.isEmpty || "${u["firstName"]} ${u["lastName"]} ${u["email"]}".toLowerCase().contains(search.toLowerCase());
      if (matchFilter && matchSearch) list.add(u);
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Accounts")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: InputDecoration(
                hintText: "Search name or email",
                prefixIcon: const Icon(Icons.search, color: AppColors.soft),
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.line)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
              ),
            ),
          ),
          FilterChips(options: filters, selected: filter, counts: counts, onSelected: (v) => setState(() => filter = v)),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
              itemCount: list.length,
              separatorBuilder: (c, i) => const SizedBox(height: 8),
              itemBuilder: (c, i) {
                dynamic u = list[i];
                String role = u["role"];
                Color color = role == "owner" ? AppColors.brand : role == "worker" ? AppColors.info : AppColors.success;
                return AppCard(
                  padding: const EdgeInsets.all(14),
                  onTap: () => openForm(u["email"]),
                  child: Row(
                    children: [
                      Avatar(AllUsers.initials(u["email"]), size: 44, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(child: Text("${u["firstName"]} ${u["lastName"]}", overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700))),
                                if (u["email"] == AllUsers.activeEmail) const Text("  (You)", style: TextStyle(fontSize: 12, color: AppColors.muted)),
                              ],
                            ),
                            Text(u["email"], style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                            const SizedBox(height: 4),
                            Text(
                              role == "worker" ? "${u["position"]} • ${AllTasks.activeCount(u["email"])} active task(s)" : role[0].toUpperCase() + role.substring(1),
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      StatusPill(u["status"] == "Active" ? "Active" : "Cancelled", label: u["status"]),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: AppButton(label: "New Account", icon: Icons.person_add_alt, onPressed: () => openForm("")),
        ),
      ),
    );
  }
}
