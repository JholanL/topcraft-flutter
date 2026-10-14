import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_button.dart';

// Landing page based on landing-reference.jpg of mobile-topcraft
class LandingState extends StatefulWidget {
  const LandingState({super.key});

  @override
  State<LandingState> createState() => LandingPage();
}

class LandingPage extends State<LandingState> with SingleTickerProviderStateMixin {
  late AnimationController controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget slideIn(Widget child, double fromX, double delay) {
    Animation<double> anim = CurvedAnimation(parent: controller, curve: Interval(delay, 1, curve: Curves.easeOutCubic));
    return AnimatedBuilder(
      animation: anim,
      builder: (c, w) => Opacity(
        opacity: anim.value,
        child: Transform.translate(offset: Offset(fromX * (1 - anim.value), 0), child: w),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned(
                    top: 24,
                    left: 8,
                    child: slideIn(Image.asset("assets/images/chair1.png", width: width * 0.5), -60, 0),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 16,
                    child: slideIn(Image.asset("assets/images/table2.png", width: width * 0.52), 60, 0.2),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(fontFamily: "Inter", fontSize: 40, height: 1.15, color: AppColors.black),
                      children: [
                        TextSpan(text: "Top ", style: TextStyle(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                        TextSpan(text: "Design\n", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF3A3A3A))),
                        TextSpan(text: "Smart ", style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF555555))),
                        TextSpan(text: "Craft", style: TextStyle(fontWeight: FontWeight.w800, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("See your space come to life", style: TextStyle(fontSize: 18, color: AppColors.neutral)),
                  const SizedBox(height: 32),
                  AppButton(label: "Let's Start", onPressed: () => Navigator.pushNamed(context, "/login")),
                  const SizedBox(height: 14),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/signup"),
                      child: const Text.rich(
                        TextSpan(
                          text: "New here? ",
                          style: TextStyle(color: AppColors.muted),
                          children: [
                            TextSpan(text: "Create an account", style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
