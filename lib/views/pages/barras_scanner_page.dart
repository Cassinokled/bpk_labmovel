import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/barcode_display.dart';
import '../widgets/navbar_user.dart';
import 'equipamento_conf_page.dart';

class BarrasScannerPage extends StatefulWidget {
  const BarrasScannerPage({super.key});

  @override
  State<BarrasScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarrasScannerPage> {
  String _scannedCode = '';
  bool _hasScanned = false;
  late Function() _stopScanner;

  void _onBarcodeScanned(String code) {
    if (!_hasScanned && mounted) {
      setState(() {
        _scannedCode = code;
        _hasScanned = true;
      });

      // verifica o equipamento no banco antes de prosseguir
      _verificarEquipamento(code);
    }
  }

  Future<void> _verificarEquipamento(String codigo) async {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EquipamentoConfPage(bookCode: codigo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(child: AppLogo()),
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
                BarcodeScanner(
                  onBarcodeScanned: _onBarcodeScanned,
                  onScannerCreated: (stop) {
                    _stopScanner = stop;
                  },
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
      bottomNavigationBar: NavBarUser(
        selectedIndex: 2,
        onBackFromScanner: () {
          if (mounted) {
            _stopScanner();
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
