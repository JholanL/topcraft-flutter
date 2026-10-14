import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../theme/app_colors.dart';
import '../../theme/format.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';

class ProfileState extends StatefulWidget {
  const ProfileState({super.key});

  @override
  State<ProfileState> createState() => ProfilePage();
}

class ProfilePage extends State<ProfileState> {
  final firstNameController = TextEditingController(text: AllUsers.active["firstName"]);
  final lastNameController = TextEditingController(text: AllUsers.active["lastName"]);
  final phoneController = TextEditingController(text: AllUsers.active["phone"]);

  //UPDATE - the logged user edits his/her own account
  void saveProfile() {
    if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
      showToast(context, "First and last name are required.");
      return;
    }
    if (!RegExp(r"^09\d{9}$").hasMatch(phoneController.text.trim())) {
      showToast(context, "Please enter a valid mobile number (09XXXXXXXXX).");
      return;
    }
    setState(() {
      AllUsers.active["firstName"] = firstNameController.text.trim();
      AllUsers.active["lastName"] = lastNameController.text.trim();
      AllUsers.active["phone"] = phoneController.text.trim();
    });
    Store.save();
    showToast(context, "Profile updated.");
  }

  @override
  Widget build(BuildContext context) {
    dynamic user = AllUsers.active;
    String role = user["role"];
    String roleLabel = role == "owner" ? "Owner" : role == "worker" ? "Worker • ${user["position"]}" : "Customer";

    return Scaffold(
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            Avatar(AllUsers.initials(user["email"]), size: 88),
            const SizedBox(height: 12),
            Text(AllUsers.fullName(user["email"]), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(user["email"], style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 10),
            StatusPill("Active", label: roleLabel),
            const SizedBox(height: 6),
            Text("Member since ${Format.date(user["createdAt"])}", style: const TextStyle(fontSize: 12, color: AppColors.soft)),
            const SizedBox(height: 24),
            AppCard(
              child: Column(
                children: [
                  AppTextField(controller: firstNameController, label: "First name", hint: "First name", pill: false),
                  const SizedBox(height: 12),
                  AppTextField(controller: lastNameController, label: "Last name", hint: "Last name", pill: false),
                  const SizedBox(height: 12),
                  AppTextField(controller: phoneController, label: "Mobile number", hint: "09XXXXXXXXX", pill: false, keyboardType: TextInputType.phone),
                  const SizedBox(height: 18),
                  AppButton(label: "Save Changes", onPressed: () => saveProfile()),
                ],
              ),
            ),
            const SizedBox(height: 12),
            AppCard(
              padding: EdgeInsets.zero,
              child: MenuTile(
                icon: Icons.lock_outline,
                title: "Change Password",
                subtitle: "Update your sign in password",
                onTap: () => Navigator.pushNamed(context, "/changepassword"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
