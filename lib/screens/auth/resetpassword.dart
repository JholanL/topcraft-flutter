import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import 'authwidgets.dart';

class ResetPasswordState extends StatefulWidget {
  const ResetPasswordState({super.key});

  @override
  State<ResetPasswordState> createState() => ResetPasswordPage();
}

class ResetPasswordPage extends State<ResetPasswordState> {
  String theValue = "";
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //UPDATE - save the new password
  void resetPassword() {
    String password = passwordController.text;
    bool strong = password.length >= 8 && RegExp(r"[A-Za-z]").hasMatch(password) && RegExp(r"[0-9]").hasMatch(password);
    setState(() {
      if (!strong) {
        theValue = "Password must be at least 8 characters with letters and numbers.";
      } else if (password != confirmPasswordController.text) {
        theValue = "Passwords do not match.";
      } else {
        AllUsers.find(AllUsers.otpEmail)["password"] = password;
        Store.save();
        showToast(context, "Password updated. Please sign in.");
        Navigator.pushNamedAndRemoveUntil(context, "/login", ModalRoute.withName("/landing"));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const AuthLogo(top: 0),
              AuthTitle("Reset Password", subtitle: "Create a new password for ${AllUsers.otpEmail}"),
              AuthMessage(theValue),
              AppTextField(controller: passwordController, hint: "New password", password: true),
              const SizedBox(height: 14),
              AppTextField(controller: confirmPasswordController, hint: "Confirm new password", password: true),
              const SizedBox(height: 28),
              AppButton(label: "Save Password", onPressed: () => resetPassword()),
            ],
          ),
        ),
      ),
    );
  }
}
