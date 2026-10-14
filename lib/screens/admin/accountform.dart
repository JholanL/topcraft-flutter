import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/tasks.dart';
import '../../glob/activity.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';

// CREATE / UPDATE / DELETE account (AdminAccountDetailPage)
class AccountFormState extends StatefulWidget {
  const AccountFormState({super.key});

  @override
  State<AccountFormState> createState() => AccountFormPage();
}

class AccountFormPage extends State<AccountFormState> {
  dynamic editing = AllUsers.find(AllUsers.selectedEmail);
  late String role = editing?["role"] ?? "worker";
  late bool active = editing == null ? true : editing["status"] == "Active";
  late final firstNameController = TextEditingController(text: editing?["firstName"] ?? "");
  late final lastNameController = TextEditingController(text: editing?["lastName"] ?? "");
  late final emailController = TextEditingController(text: editing?["email"] ?? "");
  late final phoneController = TextEditingController(text: editing?["phone"] ?? "");
  late final positionController = TextEditingController(text: editing?["position"] ?? "");
  final passwordController = TextEditingController();

  bool get isSelf => editing != null && editing["email"] == AllUsers.activeEmail;

  void save() {
    String email = emailController.text.trim();
    String password = passwordController.text;
    if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      showToast(context, "First and last name are required.");
      return;
    }
    if (editing == null && !RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
      showToast(context, "Please enter a valid email.");
      return;
    }
    if (editing == null && AllUsers.find(email) != null) {
      showToast(context, "This email is already used by another account.");
      return;
    }
    if (!RegExp(r"^09\d{9}$").hasMatch(phoneController.text.trim())) {
      showToast(context, "Please enter a valid mobile number (09XXXXXXXXX).");
      return;
    }
    if ((editing == null || password.isNotEmpty) &&
        !(password.length >= 8 && RegExp(r"[A-Za-z]").hasMatch(password) && RegExp(r"[0-9]").hasMatch(password))) {
      showToast(context, "Password must be at least 8 characters with letters and numbers.");
      return;
    }
    if (role == "worker" && positionController.text.trim().isEmpty) {
      showToast(context, "Please enter the worker's position (ex. Welder).");
      return;
    }

    String position = role == "worker" ? positionController.text.trim() : role == "owner" ? "Owner" : "";
    if (editing == null) {
      AllUsers.userList.add({
        "id": Store.newId(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
        "email": email,
        "phone": phoneController.text.trim(),
        "password": password,
        "role": role,
        "position": position,
        "status": active ? "Active" : "Inactive",
        "createdAt": Format.now(),
      });
      AllActivity.notify(email, "Welcome to TopCraft", "Your $role account was created by the owner.", "account");
      showToast(context, "Account created");
    } else {
      editing["firstName"] = firstNameController.text.trim();
      editing["lastName"] = lastNameController.text.trim();
      editing["phone"] = phoneController.text.trim();
      editing["role"] = isSelf ? editing["role"] : role;
      editing["position"] = isSelf ? editing["position"] : position;
      editing["status"] = isSelf || active ? "Active" : "Inactive";
      if (password.isNotEmpty) editing["password"] = password;
      showToast(context, "Account updated");
    }
    Store.save();
    Navigator.pop(context);
  }

  Future<void> deleteAccount() async {
    int openTasks = AllTasks.activeCount(editing["email"]);
    if (openTasks > 0) {
      showToast(context, "This worker still has $openTasks active task(s). Reassign them first.");
      return;
    }
    bool ok = await confirmDialog(context, "Delete Account", "Delete ${editing["firstName"]}'s account permanently?", confirm: "Delete", danger: true);
    if (!ok || !mounted) return;
    AllUsers.userList.remove(editing);
    Store.save();
    showToast(context, "Account deleted");
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(editing == null ? "New Account" : "Edit Account"),
        actions: [
          if (editing != null && !isSelf) IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => deleteAccount()),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          if (editing != null)
            Center(
              child: Column(
                children: [
                  Avatar(AllUsers.initials(editing["email"]), size: 72),
                  const SizedBox(height: 8),
                  Text("Member since ${Format.date(editing["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          const SectionTitle("Role"),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: "owner", label: Text("Owner")),
              ButtonSegment(value: "worker", label: Text("Worker")),
              ButtonSegment(value: "customer", label: Text("Customer")),
            ],
            selected: {role},
            onSelectionChanged: isSelf ? null : (s) => setState(() => role = s.first),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: AppTextField(controller: firstNameController, label: "First name", hint: "Juan", pill: false)),
              const SizedBox(width: 12),
              Expanded(child: AppTextField(controller: lastNameController, label: "Last name", hint: "Dela Cruz", pill: false)),
            ],
          ),
          const SizedBox(height: 12),
          editing == null
              ? AppTextField(controller: emailController, label: "Email", hint: "name@imf.com", keyboardType: TextInputType.emailAddress, pill: false)
              : InfoRow("Email", editing["email"]),
          const SizedBox(height: 12),
          AppTextField(controller: phoneController, label: "Mobile number", hint: "09XXXXXXXXX", keyboardType: TextInputType.phone, pill: false),
          if (role == "worker") const SizedBox(height: 12),
          if (role == "worker") AppTextField(controller: positionController, label: "Position", hint: "ex. Welder, Carpenter, Finisher", pill: false),
          const SizedBox(height: 12),
          AppTextField(controller: passwordController, label: editing == null ? "Temporary password" : "New password (leave blank to keep)", hint: "At least 8 characters", password: true, pill: false),
          if (!isSelf)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeTrackColor: AppColors.accent,
              title: const Text("Active account", style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text("Inactive accounts cannot sign in"),
              value: active,
              onChanged: (v) => setState(() => active = v),
            ),
          const SizedBox(height: 20),
          AppButton(label: editing == null ? "Create Account" : "Save Changes", onPressed: () => save()),
        ],
      ),
    );
  }
}
