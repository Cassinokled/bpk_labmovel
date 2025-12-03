import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class CircularCloseButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;
  final Color backgroundColor;
  final Color iconColor;
  final double iconSize;

  const CircularCloseButton({
    super.key,
    this.onPressed,
    this.size = 62,
    this.backgroundColor = AppColors.primary,
    this.iconColor = AppColors.white,
    this.iconSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(Icons.close, color: iconColor, size: iconSize),
        onPressed: onPressed ?? () => Navigator.pop(context),
      ),
    );
  }
}
