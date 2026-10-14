import 'package:flutter/material.dart';

// Color palette taken from mobile-topcraft (MobileUI.jsx, authTheme.jsx and
// RoleTabBar.jsx) so the Flutter simulation looks like the real system.
class AppColors {
  static const Color bg = Color(0xFFF8F6F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFFAF8F5);
  static const Color text = Color(0xFF1F1A17);
  static const Color muted = Color(0xFF6F655E);
  static const Color soft = Color(0xFFA59A91);
  static const Color line = Color(0xFFEFE8E0);
  static const Color field = Color(0xFFCFCBC5);

  static const Color brand = Color(0xFF5C3A28);
  static const Color accent = Color(0xFF8B5A3C);
  static const Color accentSoft = Color(0xFFF3E9E1);
  static const Color gold = Color(0xFFD8B16D);
  static const Color title = Color(0xFFBC9554);
  static const Color tabActive = Color(0xFFE0A247);
  static const Color black = Color(0xFF111111);

  static const Color success = Color(0xFF2C4A3E);
  static const Color successBg = Color(0xFFD6E8DF);
  static const Color warning = Color(0xFFC4863A);
  static const Color warningBg = Color(0xFFFFF5E6);
  static const Color danger = Color(0xFFB85442);
  static const Color dangerBg = Color(0xFFFDECEA);
  static const Color info = Color(0xFF2B4C8C);
  static const Color infoBg = Color(0xFFE6EEFF);
  static const Color orange = Color(0xFFB85E1E);
  static const Color orangeBg = Color(0xFFFFE8D6);
  static const Color neutral = Color(0xFF8B7D70);
  static const Color neutralBg = Color(0xFFF0EBE5);

  // background and text color of a status pill, same mapping as STATUS_MAP
  static List<Color> status(String status) {
    switch (status) {
      case "Pending":
      case "Submitted":
      case "To Do":
        return [warningBg, warning];
      case "In Production":
      case "In Progress":
      case "Quoted":
        return [const Color(0xFFE8D7C3), accent];
      case "Quality Check":
        return [infoBg, info];
      case "Out for Delivery":
        return [orangeBg, orange];
      case "Completed":
      case "Approved":
      case "Done":
      case "Active":
        return [successBg, success];
      case "Rejected":
      case "Low Stock":
        return [dangerBg, danger];
      default:
        return [neutralBg, neutral];
    }
  }
}
