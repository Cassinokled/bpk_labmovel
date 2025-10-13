import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/emprestimo_model.dart';

class QRCodePage extends StatefulWidget {
  const QRCodePage({super.key});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  String _qrData = '';
  late EmprestimoModel _emprestimo;

  @override
  void initState() {
    super.initState();
    // Carrega dados de exemplo (futuramente virá informações do leitor de barras e informações mais especificas do usuario)
    _emprestimo = EmprestimoModel.exemplo();
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
          // Logo centralizada
          Center(
            child: Image.asset(
              'assets/pics/logos/logo_bpk.png',
              width: 161,
              height: 45,
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          // Conteúdo principal
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
                      color: Color(0xFF5C2E3E),
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // QR Code
                Container(
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFF5C2E3E),
                      width: 11,
                    ),
                  ),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 266.0,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Botão de voltar
          Padding(
            padding: const EdgeInsets.only(bottom: 26.0),
            child: Center(
              child: Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF5C2E3E),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
