import 'package:flutter/material.dart';

// constantes de cores do aplicativo
class AppColors {
  // cor principal
  static const Color primary = Color.fromARGB(255, 86, 22, 36);
  static const Color background = Color(0xFFF8F9F5);
  
  // cores de status
  static const Color success = Colors.green;
  static const Color error = Colors.red;
  static const Color info = Colors.blue;
  static const Color warning = Colors.orange;
  
  // opacidades
  static Color primaryLight = primary.withOpacity(0.1);
  static Color primaryMedium = primary.withOpacity(0.5);
}
