import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../widgets/navbar.dart';
import '../widgets/circular_close_button.dart';
import 'registros_emprestimos_page.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool isScanning = true;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 40),
              SizedBox(
                height: 80,
                child: Image.asset('assets/pics/logos/logo_bpk.png'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Scaneie o código QR do aluno:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
                  Expanded(
                    child: Center(
                      child: SizedBox(
                        width: size.width * 0.8,
                        height: size.width * 0.8,
                        child: QRView(
                          key: qrKey,
                          onQRViewCreated: (controller) {
                            this.controller = controller;
                            controller.scannedDataStream.listen((scanData) {
                              if (isScanning) {
                                setState(() {
                                  qrText = scanData.code;
                                  isScanning = false;
                                });
                              }
                            });
                          },
                          overlay: QrScannerOverlayShape(
                            borderColor: Colors.deepPurple,
                            borderRadius: 12,
                            borderLength: 30,
                            borderWidth: 5,
                            cutOutSize: size.width * 0.8,
                            overlayColor: Colors.black.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
              const SizedBox(height: 20),
              Text(
                qrText != null ? 'QR Code: $qrText' : '',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: 2,
        useQrScanner: true,
        onBackFromScanner: () {
          controller?.pauseCamera();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}