import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/circular_close_button.dart';
import '../widgets/qr_code/qr_status_widget.dart';

class QRCodePage extends StatefulWidget {
  final EmprestimoModel? emprestimo;

  const QRCodePage({super.key, this.emprestimo});

  @override
  State<QRCodePage> createState() => _QRCodePageState();
}

class _QRCodePageState extends State<QRCodePage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  String _qrData = '';
  EmprestimoModel? _emprestimo;
  StreamSubscription? _emprestimoSubscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeEmprestimo();
  }

  @override
  void dispose() {
    _emprestimoSubscription?.cancel();
    super.dispose();
  }

  // inicializa o emprestimo: cria no firestore e monitora mudancas
  Future<void> _initializeEmprestimo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // cria o emprestimo no firestore
      final emprestimoInicial = widget.emprestimo ?? EmprestimoModel.exemplo();
      final emprestimoSalvo = await _emprestimoService.criarEmprestimo(
        emprestimoInicial,
      );

      setState(() {
        _emprestimo = emprestimoSalvo;
        _qrData = emprestimoSalvo.toQrString();
        _isLoading = false;
      });

      // monitora mudancas no emprestimo
      _monitorarEmprestimo(emprestimoSalvo.id!);
    } catch (e) {
      setState(() {
        _error = 'Erro ao gerar QR Code: $e';
        _isLoading = false;
      });
    }
  }

  // monitora o status do emprestimo em tempo real
  void _monitorarEmprestimo(String emprestimoId) {
    _emprestimoSubscription = _emprestimoService
        .monitorarEmprestimo(emprestimoId)
        .listen((emprestimoAtualizado) {
          if (emprestimoAtualizado == null) {
            return;
          }

          setState(() {
            _emprestimo = emprestimoAtualizado;
          });

          if (emprestimoAtualizado.isConfirmado) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pop();
                // mostra mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Empréstimo confirmado com sucesso!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            });
          }

          if (emprestimoAtualizado.isRecusado) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).pop();
                // mostra mensagem de recusa
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Empréstimo recusado pela atendente'),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 4),
                  ),
                );
              }
            });
          }
        });
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
          Padding(padding: const EdgeInsets.all(26.0), child: _buildContent()),
          const Spacer(),
          // Botão de voltar (só mostra se estiver pendente)
          if (_emprestimo?.isPendente == true)
            const Padding(
              padding: EdgeInsets.only(bottom: 26.0),
              child: Center(child: CircularCloseButton()),
            ),
          if (_emprestimo?.isPendente != true) const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return QRStatusWidget(
      isLoading: _isLoading,
      error: _error,
      emprestimo: _emprestimo,
      qrData: _qrData,
      onRetry: _initializeEmprestimo,
    );
  }
}
