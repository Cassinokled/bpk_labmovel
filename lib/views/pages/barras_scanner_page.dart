import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/barcode_display.dart';
import '../widgets/navbar.dart';
import 'equipamento_conf_page.dart';

class BarrasScannerPage extends StatefulWidget {
  const BarrasScannerPage({super.key});

  @override
  State<BarrasScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarrasScannerPage> {
  String _scannedCode = '';
  bool _hasScanned = false;

  void _onBarcodeScanned(String code) {
    if (!_hasScanned) {
      setState(() {
        _scannedCode = code;
        _hasScanned = true;
      });
      
      // pagina de confirmacao
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EquipamentoConfPage(bookCode: code),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(
            child: AppLogo(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(26.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'Scaneie o código de barras presente no equipamento:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 86, 22, 36),
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Scanner de código de barras
                BarcodeScanner(
                  onBarcodeScanned: _onBarcodeScanned,
                ),
                if (_scannedCode.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Código: $_scannedCode',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 2),
    );
  }
}
