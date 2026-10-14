import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'authwidgets.dart';

// Sign In screen based on login-reference.jpg
class LoginState extends StatefulWidget {
  const LoginState({super.key});

  @override
  State<LoginState> createState() => LoginPage();
}

class LoginPage extends State<LoginState> {
  String theValue = "";
  bool loading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> loginAccount() async {
    String email = emailController.text.trim();
    String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => theValue = "Please enter your email and password.");
      return;
    }

    setState(() {
      theValue = "";
      loading = true;
    });
    //small delay to simulate the request to the server
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    dynamic user = AllUsers.find(email);
    if (user == null || user["password"] != password) {
      setState(() {
        loading = false;
        theValue = "Invalid email or password.";
      });
      return;
    }
    if (user["status"] != "Active") {
      setState(() {
        loading = false;
        theValue = "This account is deactivated. Please contact the owner.";
      });
      return;
    }

    Store.signIn(user["email"]);
    AllActivity.log(user["email"], "Signed in");
    Store.save();
    Navigator.pushNamedAndRemoveUntil(context, AllUsers.homeRoute(user["role"]), (route) => false);
  }

  void fillDemo(String email) {
    setState(() {
      emailController.text = email;
      passwordController.text = "12345678";
      theValue = "";
    });
  }

  Widget demoChip(String label, String email, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: AppColors.accent),
      label: Text(label, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.surface,
      onPressed: () => fillDemo(email),
    );
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
              const AuthTitle("Sign In Account"),
              AuthMessage(theValue),
              AppTextField(controller: emailController, hint: "Email", keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 18),
              AppTextField(controller: passwordController, hint: "Password", password: true),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, "/forgot"),
                  child: const Text("Forgot Password?", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: loading
                    ? const SizedBox(height: 52, child: Center(child: CircularProgressIndicator(color: AppColors.black)))
                    : AppButton(label: "Sign in", onPressed: () => loginAccount()),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => Navigator.pushReplacementNamed(context, "/signup"),
                child: const Text("Don't have an account yet? Sign up here!", style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 36),
              const Text("Demo accounts (password: 12345678)", style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  demoChip("Owner", "owner@imf.com", Icons.storefront_outlined),
                  demoChip("Worker", "juan@imf.com", Icons.handyman_outlined),
                  demoChip("Customer", "maria@gmail.com", Icons.person_outline),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
