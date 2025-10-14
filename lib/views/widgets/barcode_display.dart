import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeScanned;

  const BarcodeScanner({
    super.key,
    required this.onBarcodeScanned,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  final MobileScannerController controller = MobileScannerController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 86, 22, 36),
          width: 11,
        ),
      ),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: 300,
        height: 300,
        child: MobileScanner(
          controller: controller,
          onDetect: (BarcodeCapture capture) {
            final List<Barcode> barcodes = capture.barcodes;
            for (final barcode in barcodes) {
              if (barcode.rawValue != null) {
                widget.onBarcodeScanned(barcode.rawValue!);
                break;
              }
            }
          },
        ),
      ),
    );
  }
}
