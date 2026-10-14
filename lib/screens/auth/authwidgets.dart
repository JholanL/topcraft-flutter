import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

// error / success box of the auth screens (AuthMessage of authTheme.jsx)
class AuthMessage extends StatelessWidget {
  final String text;
  final bool success;
  const AuthMessage(this.text, {super.key, this.success = false});

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) return const SizedBox.shrink();
    Color bg = success ? const Color(0xFFEDF6F0) : const Color(0xFFFDF1EF);
    Color border = success ? const Color(0xFFCFE0D4) : const Color(0xFFF2CDC6);
    Color fg = success ? const Color(0xFF2C6A48) : const Color(0xFFB85442);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(success ? Icons.check_circle_outline : Icons.error_outline, color: fg, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class AuthLogo extends StatelessWidget {
  final double top;
  const AuthLogo({super.key, this.top = 32});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: 24),
      child: Center(child: Image.asset("assets/images/logo_black.png", width: 230)),
    );
  }
}

class AuthTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const AuthTitle(this.title, {super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500, color: AppColors.black)),
          if (subtitle != null) const SizedBox(height: 6),
          if (subtitle != null)
            Text(subtitle!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.muted)),
        ],
      ),
    );
  }
}
