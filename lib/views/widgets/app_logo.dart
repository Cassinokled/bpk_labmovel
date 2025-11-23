import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;

  const AppLogo({super.key, this.width = 161, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppColors.logoPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
