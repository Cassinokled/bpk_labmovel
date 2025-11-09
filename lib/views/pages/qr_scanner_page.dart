import 'package:flutter/material.dart';
import 'dart:convert';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/qr_code_scanner.dart';
import '../widgets/navbar.dart';
import 'confirmar_emprestimo_page.dart';
import 'confirmar_devolucao_page.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  String _scannedCode = '';
  bool _hasScanned = false;
  bool _isProcessing = false;

  void _onQRCodeScanned(String code) {
    if (!_hasScanned && !_isProcessing) {
      setState(() {
        _scannedCode = code;
        _hasScanned = true;
      });

      _processQRCode(code);
    }
  }

  // processa o qr code escaneado
  Future<void> _processQRCode(String qrCode) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // tenta decodificar o json do qr code
      final Map<String, dynamic> qrData = jsonDecode(qrCode);
      final tipo = qrData['tipo'] as String?;
      final emprestimoId = qrData['emprestimoId'] as String?;

      if (emprestimoId == null) {
        _showError('QR Code inválido');
        _resetScanner();
        return;
      }

      // busca os detalhes completos do emprestimo
      final emprestimo = await _emprestimoService.buscarEmprestimo(
        emprestimoId,
      );

      if (emprestimo == null) {
        _showError('Empréstimo não encontrado');
        _resetScanner();
        return;
      }

      // verifica se é QR de devolução
      if (tipo == 'devolucao') {
        await _processarDevolucao(emprestimo);
      } else {
        // é QR de empréstimo normal
        await _processarEmprestimo(emprestimo);
      }
    } catch (e) {
      _showError('Erro ao processar QR Code: $e');
      _resetScanner();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // processa qr de emprestimo
  Future<void> _processarEmprestimo(EmprestimoModel emprestimo) async {
    if (emprestimo.isConfirmado) {
      _showError('Este empréstimo já foi confirmado');
      _resetScanner();
      return;
    }

    if (emprestimo.isRecusado) {
      _showError('Este empréstimo já foi recusado');
      _resetScanner();
      return;
    }

    // navega pra pagina de confirmacao
    if (mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmarEmprestimoPage(emprestimo: emprestimo),
        ),
      );

      // se confirmou com sucesso, mostra mensagem e reseta scanner
      if (result == true) {
        _showSuccess('Empréstimo confirmado!');
      }

      _resetScanner();
    }
  }

  // processa qr de devolucao
  Future<void> _processarDevolucao(EmprestimoModel emprestimo) async {
    if (!emprestimo.isAtivo) {
      _showError('Este empréstimo não está ativo');
      _resetScanner();
      return;
    }

    if (emprestimo.isDevolvido) {
      _showError('Este empréstimo já foi devolvido');
      _resetScanner();
      return;
    }

    // navega pra pagina de confirmacao de devolucao
    if (mounted) {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmarDevolucaoPage(emprestimo: emprestimo),
        ),
      );

      // se confirmou com sucesso, mostra mensagem e reseta scanner
      if (result == true) {
        _showSuccess('Devolução confirmada!');
      }

      _resetScanner();
    }
  }

  // reseta o scanner pra permitir nova leitura
  void _resetScanner() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _hasScanned = false;
          _scannedCode = '';
        });
      }
    });
  }

  // mostra mensagem de erro
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // mostra mensagem de sucesso
  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
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
                    'Escaneie o QR Code do empréstimo:',
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
                // Scanner de QR Code
                QRCodeScanner(onQRCodeScanned: _onQRCodeScanned),
                const SizedBox(height: 20),
                // Status do scanner
                if (_isProcessing) ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color.fromARGB(255, 86, 22, 36),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Processando QR Code...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 86, 22, 36),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ] else if (_scannedCode.isNotEmpty && _hasScanned) ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_scanner,
                        color: Color.fromARGB(255, 86, 22, 36),
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'QR Code detectado!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 86, 22, 36),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Aguardando QR Code...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 2, isAtendente: true),
    );
  }
}
