import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double width;
  final double height;

  const AppLogo({super.key, this.width = 161, this.height = 45});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/pics/logos/logo_bpk.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}
