import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../glob/activity.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../auth/authwidgets.dart';

class ChangePasswordState extends StatefulWidget {
  const ChangePasswordState({super.key});

  @override
  State<ChangePasswordState> createState() => ChangePasswordPage();
}

class ChangePasswordPage extends State<ChangePasswordState> {
  String theValue = "";
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  void changePassword() {
    String password = newController.text;
    bool strong = password.length >= 8 && RegExp(r"[A-Za-z]").hasMatch(password) && RegExp(r"[0-9]").hasMatch(password);
    setState(() {
      if (currentController.text != AllUsers.active["password"]) {
        theValue = "Your current password is incorrect.";
      } else if (!strong) {
        theValue = "New password must be at least 8 characters with letters and numbers.";
      } else if (password == currentController.text) {
        theValue = "New password must be different from your current password.";
      } else if (password != confirmController.text) {
        theValue = "Passwords do not match.";
      } else {
        AllUsers.active["password"] = password;
        AllActivity.log(AllUsers.activeEmail, "Changed password");
        Store.save();
        showToast(context, "Password changed successfully.");
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            AuthMessage(theValue),
            AppTextField(controller: currentController, hint: "Current password", password: true),
            const SizedBox(height: 14),
            AppTextField(controller: newController, hint: "New password", password: true),
            const SizedBox(height: 14),
            AppTextField(controller: confirmController, hint: "Confirm new password", password: true),
            const SizedBox(height: 28),
            AppButton(label: "Update Password", onPressed: () => changePassword()),
          ],
        ),
      ),
    );
  }
}
