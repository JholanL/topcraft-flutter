import 'dart:async';
import 'package:flutter/material.dart';
import '../../glob/users.dart';
import '../../glob/store.dart';
import '../../glob/activity.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/common.dart';
import 'authwidgets.dart';

// OTP verification. There is no email server, so the code is shown
// on the screen to simulate the email that mobile-topcraft sends.
class OtpState extends StatefulWidget {
  const OtpState({super.key});

  @override
  State<OtpState> createState() => OtpPage();
}

class OtpPage extends State<OtpState> {
  String theValue = "";
  final otpController = TextEditingController();
  final FocusNode focus = FocusNode();
  int seconds = 30;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => showCode());
  }

  void startTimer() {
    timer?.cancel();
    seconds = 30;
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        seconds--;
        if (seconds <= 0) t.cancel();
      });
    });
  }

  void showCode() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 6),
        content: Text("📧 Simulated email to ${AllUsers.otpEmail}: your code is ${AllUsers.otpCode}"),
      ),
    );
  }

  void resend() {
    AllUsers.newOtp();
    otpController.clear();
    setState(() => theValue = "");
    startTimer();
    showCode();
  }

  void verify() {
    if (otpController.text.length < 6) {
      setState(() => theValue = "Please enter the 6-digit code.");
      return;
    }
    if (otpController.text != AllUsers.otpCode) {
      setState(() => theValue = "Invalid code. Please try again.");
      return;
    }

    if (AllUsers.otpPurpose == "signup") {
      //CREATE (step 2) - the account is saved after the email is verified
      AllUsers.userList.add(AllUsers.pendingUser);
      AllActivity.notify(AllUsers.otpEmail, "Welcome to Industrial Manila!", "Your account is ready. Start shopping or request a custom piece.", "account");
      AllActivity.notifyRole("owner", "New customer", "${AllUsers.pendingUser["firstName"]} ${AllUsers.pendingUser["lastName"]} created an account.", "account");
      AllUsers.pendingUser = null;
      Store.save();
      showToast(context, "Account verified! You can now sign in.");
      Navigator.pushNamedAndRemoveUntil(context, "/login", ModalRoute.withName("/landing"));
    } else {
      Navigator.pushReplacementNamed(context, "/reset");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String code = otpController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.accent),
              ),
              AuthTitle("Verify your email", subtitle: "Enter the 6-digit code we sent to\n${AllUsers.otpEmail}"),
              AuthMessage(theValue),
              //6 boxes on top of one hidden text field
              GestureDetector(
                onTap: () => focus.requestFocus(),
                child: Stack(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: TextField(
                        controller: otpController,
                        focusNode: focus,
                        autofocus: true,
                        maxLength: 6,
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          setState(() => theValue = "");
                          if (v.length == 6) verify();
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (int i = 0; i < 6; i++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 46,
                            height: 56,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: i == code.length ? AppColors.black : AppColors.field,
                                width: i == code.length ? 2 : 1.2,
                              ),
                            ),
                            child: Text(i < code.length ? code[i] : "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              AppButton(label: "Verify", onPressed: () => verify()),
              const SizedBox(height: 16),
              seconds > 0
                  ? Text("Resend code in ${seconds}s", style: const TextStyle(color: AppColors.muted))
                  : TextButton(
                      onPressed: () => resend(),
                      child: const Text("Resend code", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700)),
                    ),
              TextButton(
                onPressed: () => showCode(),
                child: const Text("Show simulated email again", style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
