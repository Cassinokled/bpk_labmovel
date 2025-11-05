import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  final Function(String) onBarcodeScanned;
  final Function(Function())? onScannerCreated;

  const BarcodeScanner({
    super.key,
    required this.onBarcodeScanned,
    this.onScannerCreated,
  });

  @override
  State<BarcodeScanner> createState() => _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  late final MobileScannerController controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController(
      formats: [
        BarcodeFormat.code128,
        BarcodeFormat.ean13,
        BarcodeFormat.ean8,
        BarcodeFormat.upcA,
        BarcodeFormat.upcE,
      ],
    );

    // Envia função para parar o scanner
    widget.onScannerCreated?.call(() => controller.stop());
  }

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
      child: SizedBox( // REMOVA O const AQUI
        width: 300,
        height: 300,
        child: MobileScanner(
          controller: controller,
          onDetect: (capture) {
            final barcode = capture.barcodes.first;
            if (barcode.rawValue != null) {
              widget.onBarcodeScanned(barcode.rawValue!);
            }
          },
        ),
      ),
    );
  }
}