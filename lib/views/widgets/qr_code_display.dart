import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../utils/app_colors.dart';

class QRCodeDisplay extends StatelessWidget {
  final String qrData;
  final double size;
  final Color borderColor;
  final double borderWidth;

  const QRCodeDisplay({
    super.key,
    required this.qrData,
    this.size = 266.0,
    this.borderColor = AppColors.primary,
    this.borderWidth = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: QrImageView(
        data: qrData,
        version: QrVersions.auto,
        size: size,
        backgroundColor: AppColors.white,
      ),
    );
  }
}
