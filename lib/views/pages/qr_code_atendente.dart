import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../widgets/navbar.dart';
import 'confirmar_emprestimo_page.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final EmprestimoService _emprestimoService = EmprestimoService();
  QRViewController? controller;
  String? qrText;
  bool isScanning = true;
  bool _isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    controller?.pauseCamera();
    controller?.resumeCamera();
  }

  // processa o qr code escaneado
  Future<void> _processQRCode(String qrCode) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // decodifica o qr code
      final emprestimoQR = EmprestimoModel.fromQrString(qrCode);
      
      if (emprestimoQR.id == null) {
        _showError('QR Code inválido');
        _resetScanner();
        return;
      }

      // busca os detalhes completos do emprestimo
      final emprestimo = await _emprestimoService.buscarEmprestimo(emprestimoQR.id!);
      
      if (emprestimo == null) {
        _showError('Empréstimo não encontrado');
        _resetScanner();
        return;
      }

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

      // pausa a camera antes de navegar
      controller?.pauseCamera();

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
    } catch (e) {
      _showError('Erro ao processar QR Code: $e');
      _resetScanner();
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  // reseta o scanner pra permitir nova leitura
  void _resetScanner() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isScanning = true;
          qrText = null;
        });
        controller?.resumeCamera();
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
                              if (isScanning && scanData.code != null && !_isProcessing) {
                                setState(() {
                                  qrText = scanData.code;
                                  isScanning = false;
                                });
                                // processa o qr code lido
                                _processQRCode(scanData.code!);
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
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Processando QR Code...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.deepPurple,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ] else if (qrText != null && !isScanning) ...[
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: Colors.deepPurple,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'QR Code detectado!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
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
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: 2,
        isAtendente: true,
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