import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Buttons of the system. "dark" is the black gradient button of the
// mobile-topcraft login/landing screens.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final String variant; // dark, brown, outline, light, danger
  final IconData? icon;
  final bool expand;
  final bool small;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = "dark",
    this.icon,
    this.expand = true,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor = Colors.white;
    Gradient? gradient;
    Color? color;
    BoxBorder? border;

    if (variant == "dark") {
      gradient = const LinearGradient(
        colors: [Color(0xFF736B6B), Color(0xFF000000), Color(0xFF000000), Color(0xFF736B6B)],
        stops: [0, 0.25, 0.75, 1],
      );
    } else if (variant == "brown") {
      color = AppColors.accent;
    } else if (variant == "danger") {
      color = AppColors.danger;
    } else if (variant == "light") {
      color = AppColors.accentSoft;
      textColor = AppColors.accent;
    } else {
      color = AppColors.surface;
      textColor = AppColors.text;
      border = Border.all(color: AppColors.field);
    }

    bool disabled = onPressed == null;
    double height = small ? 40 : 52;

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: small ? 16 : 19, color: textColor),
        if (icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontSize: small ? 13 : 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Container(
        height: height,
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          border: border,
          borderRadius: BorderRadius.circular(small ? 10 : 12),
          boxShadow: variant == "dark" && !disabled
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 4))]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(small ? 10 : 12),
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: small ? 10 : 20),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
