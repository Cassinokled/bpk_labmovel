import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../widgets/app_logo.dart';
import '../widgets/qr_code_display.dart';
import '../widgets/circular_close_button.dart';

class QRCodePage extends StatefulWidget {
  final EmprestimoModel? emprestimo;
  
  const QRCodePage({super.key, this.emprestimo});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  String _qrData = '';
  late EmprestimoModel _emprestimo;

  @override
  void initState() {
    super.initState();
    _emprestimo = widget.emprestimo ?? EmprestimoModel.exemplo();
    _generateQRCode();
  }

  void _generateQRCode() {
    setState(() {
      _qrData = _emprestimo.toQrString();
    });
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
                    'Mostre esse QR Code à bibliotecária, e assim que ela aprovar, seu empréstimo será concluído!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Color.fromARGB(255, 86, 22, 36),
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // QR Code
                QRCodeDisplay(qrData: _qrData),
              ],
            ),
          ),
          const Spacer(),
          // Botão de voltar
          const Padding(
            padding: EdgeInsets.only(bottom: 26.0),
            child: Center(
              child: CircularCloseButton(),
            ),
          ),
        ],
      ),
    );
  }
}
