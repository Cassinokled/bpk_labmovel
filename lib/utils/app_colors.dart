import 'package:flutter/material.dart';

// cores do aplicativo
class AppColors {
  // cor principal
  static const Color primary = Color.fromARGB(255, 86, 22, 36);
  static const Color background = Color(0xFFF8F9F5);

  // cores de status
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;
  static const Color warning = Colors.orange;

  // opacidades da cor principal
  static const Color primaryLight = Color.fromARGB(26, 86, 22, 36); // 0.1 opacity
  static const Color primaryMedium = Color.fromARGB(128, 86, 22, 36); // 0.5 opacity
  static const Color primaryLightBackground = Color(0xFFE8D5D8); // light background for cards
  static const Color primarySemiTransparent = Color(0x80561624); // 0.5 opacity

  // cores de status com opacidade
  static const Color successLight = Color.fromARGB(26, 76, 175, 80); // green 0.1
  static const Color errorLight = Color.fromARGB(26, 244, 67, 54); // red 0.1
  static const Color warningLight = Color.fromARGB(26, 255, 152, 0); // orange 0.1

  // cores de texto
  static const Color textPrimary = Colors.black87;
  static const Color textSecondary = Color(0xFF757575); // Colors.grey[600]
  static const Color textWhite = Colors.white;

  // outras cores
  static const Color divider = Color(0xFFBDBDBD); // Colors.grey[400]
  static const Color cardBackground = Color(0xFFEDEDED); // light grey background
  static const Color black = Colors.black;
  static const Color shadow = Color.fromARGB(13, 0, 0, 0); // black 0.05
  static const Color shadowDark = Color.fromARGB(128, 0, 0, 0); // black 0.5
  static const Color transparent = Colors.transparent;
  static const Color grey = Colors.grey;
  static const Color white = Colors.white;
  static const Color shadowMedium = Color.fromARGB(38, 0, 0, 0); // black 0.15

  // logo path
  static const String logoPath = 'assets/pics/logos/logo_bpk.png';
}
