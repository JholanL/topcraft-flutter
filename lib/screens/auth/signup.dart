import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'authwidgets.dart';

class SignupState extends StatefulWidget {
  const SignupState({super.key});

  @override
  State<SignupState> createState() => SignupPage();
}

class SignupPage extends State<SignupState> {
  String theValue = "";
  bool agreed = false;
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //password policy: at least 8 characters with letters and numbers
  bool strongPassword(String value) {
    return value.length >= 8 && RegExp(r"[A-Za-z]").hasMatch(value) && RegExp(r"[0-9]").hasMatch(value);
  }

  //CREATE (step 1) - validate then send the OTP to the email
  void createAccount() {
    String email = emailController.text.trim();
    setState(() {
      if (firstNameController.text.trim().isEmpty || lastNameController.text.trim().isEmpty) {
        theValue = "Please enter your first and last name.";
      } else if (!RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email)) {
        theValue = "Please enter a valid email address.";
      } else if (AllUsers.find(email) != null) {
        theValue = "This email is already registered.";
      } else if (!RegExp(r"^09\d{9}$").hasMatch(phoneController.text.trim())) {
        theValue = "Please enter a valid mobile number (09XXXXXXXXX).";
      } else if (!strongPassword(passwordController.text)) {
        theValue = "Password must be at least 8 characters with letters and numbers.";
      } else if (passwordController.text != confirmPasswordController.text) {
        theValue = "Passwords do not match.";
      } else if (!agreed) {
        theValue = "Please agree to the Terms and Privacy Policy.";
      } else {
        theValue = "";
        AllUsers.pendingUser = {
          "id": "u${DateTime.now().millisecondsSinceEpoch}",
          "firstName": firstNameController.text.trim(),
          "lastName": lastNameController.text.trim(),
          "email": email,
          "phone": phoneController.text.trim(),
          "password": passwordController.text,
          "role": "customer",
          "position": "",
          "status": "Active",
          "createdAt": DateTime.now().toIso8601String(),
        };
        AllUsers.otpEmail = email;
        AllUsers.otpPurpose = "signup";
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
              Image.asset("assets/images/logo_black.png", width: 170),
              const SizedBox(height: 20),
              const AuthTitle("Create Account", subtitle: "Order furniture and track your projects."),
              AuthMessage(theValue),
              Row(
                children: [
                  Expanded(child: AppTextField(controller: firstNameController, hint: "First name")),
                  const SizedBox(width: 10),
                  Expanded(child: AppTextField(controller: lastNameController, hint: "Last name")),
                ],
              ),
              const SizedBox(height: 14),
              AppTextField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              AppTextField(controller: phoneController, hint: "Mobile number (09XXXXXXXXX)", keyboardType: TextInputType.phone),
              const SizedBox(height: 14),
              AppTextField(controller: passwordController, hint: "Password", password: true),
              const SizedBox(height: 14),
              AppTextField(controller: confirmPasswordController, hint: "Confirm password", password: true),
              const SizedBox(height: 6),
              Row(
                children: [
                  Checkbox(
                    value: agreed,
                    activeColor: AppColors.black,
                    onChanged: (v) => setState(() => agreed = v == true),
                  ),
                  const Expanded(
                    child: Text("I agree to the Terms of Service and Privacy Policy", style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AppButton(label: "Sign up", onPressed: () => createAccount()),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, "/login"),
                child: const Text("Already have an account? Sign in here!", style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
