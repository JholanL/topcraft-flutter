import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

// Pill shaped text field with an eye button for passwords,
// same as the Sign In screen of mobile-topcraft.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? label;
  final IconData? icon;
  final bool password;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool pill;
  final ValueChanged<String>? onChanged;
  final String? prefixText;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.label,
    this.icon,
    this.password = false,
    this.keyboardType,
    this.maxLines = 1,
    this.pill = true,
    this.onChanged,
    this.prefixText,
  });

  @override
  State<AppTextField> createState() => AppTextFieldState();
}

class AppTextFieldState extends State<AppTextField> {
  bool hidden = true;

  @override
  Widget build(BuildContext context) {
    double radius = widget.pill && widget.maxLines == 1 ? 40 : 16;
    OutlineInputBorder border(Color color, [double width = 1.2]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: color, width: width),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 6),
            child: Text(
              widget.label!,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
            ),
          ),
        TextField(
          controller: widget.controller,
          obscureText: widget.password && hidden,
          keyboardType: widget.keyboardType,
          maxLines: widget.password ? 1 : widget.maxLines,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 15, color: AppColors.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.soft, fontSize: 15),
            prefixText: widget.prefixText,
            prefixIcon: widget.icon == null ? null : Icon(widget.icon, color: AppColors.soft, size: 20),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(horizontal: widget.icon == null ? 22 : 16, vertical: 16),
            enabledBorder: border(AppColors.field),
            focusedBorder: border(AppColors.accent, 1.6),
            border: border(AppColors.field),
            suffixIcon: widget.password
                ? IconButton(
                    onPressed: () => setState(() => hidden = !hidden),
                    icon: Icon(hidden ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.text),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
