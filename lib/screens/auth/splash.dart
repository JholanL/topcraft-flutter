import 'package:flutter/material.dart';
import '../../glob/users.dart';

class SplashState extends StatefulWidget {
  const SplashState({super.key});

  @override
  State<SplashState> createState() => SplashPage();
}

class SplashPage extends State<SplashState> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), openNextPage);
  }

  //restores the session: logged users go straight to their home page
  void openNextPage() {
    if (!mounted) return;
    if (AllUsers.active != null && AllUsers.active["status"] == "Active") {
      Navigator.pushReplacementNamed(context, AllUsers.homeRoute(AllUsers.activeRole));
    } else {
      Navigator.pushReplacementNamed(context, "/landing");
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
          child: ScaleTransition(
            scale: Tween(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/logo_white.png", width: 240),
                const SizedBox(height: 28),
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
