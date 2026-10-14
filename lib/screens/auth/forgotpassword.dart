import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'authwidgets.dart';

class ForgotPasswordState extends StatefulWidget {
  const ForgotPasswordState({super.key});

  @override
  State<ForgotPasswordState> createState() => ForgotPasswordPage();
}

class ForgotPasswordPage extends State<ForgotPasswordState> {
  String theValue = "";
  final emailController = TextEditingController();

  void sendCode() {
    String email = emailController.text.trim();
    setState(() {
      if (email.isEmpty) {
        theValue = "Please enter your email.";
      } else if (AllUsers.find(email) == null) {
        theValue = "We couldn't find an account with that email.";
      } else {
        theValue = "";
        AllUsers.otpEmail = AllUsers.find(email)["email"];
        AllUsers.otpPurpose = "reset";
        AllUsers.newOtp();
        Navigator.pushNamed(context, "/otp");
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
              const AuthTitle("Forgot Password", subtitle: "Enter the email of your account and we'll send you a verification code."),
              AuthMessage(theValue),
              AppTextField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 28),
              AppButton(label: "Send Code", onPressed: () => sendCode()),
            ],
          ),
        ),
      ),
    );
  }
}
