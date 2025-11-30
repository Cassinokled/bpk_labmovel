import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/circular_close_button.dart';
import '../widgets/qr_code/qr_status_widget.dart';

class QRCodeDevolucaoPage extends StatefulWidget {
  final EmprestimoModel emprestimo;

  const QRCodeDevolucaoPage({super.key, required this.emprestimo});

  @override
  State<QRCodeDevolucaoPage> createState() => _QRCodeDevolucaoPageState();
}

class _QRCodeDevolucaoPageState extends State<QRCodeDevolucaoPage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  String _qrData = '';
  EmprestimoModel? _emprestimo;
  StreamSubscription? _emprestimoSubscription;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeQRData();
    _monitorarEmprestimo();
  }

  @override
  void dispose() {
    _emprestimoSubscription?.cancel();
    super.dispose();
  }

  // inicializa os dados do qr code de devolucao
  void _initializeQRData() {
    setState(() {
      _emprestimo = widget.emprestimo;
      // gera qr code com tipo devolucao
      _qrData = jsonEncode({
        'tipo': 'devolucao',
        'emprestimoId': widget.emprestimo.id,
        'userId': widget.emprestimo.userId,
      });
    });
  }

  // monitora o status do emprestimo em tempo real
  void _monitorarEmprestimo() {
    _emprestimoSubscription = _emprestimoService
        .monitorarEmprestimo(widget.emprestimo.id!)
        .listen((emprestimoAtualizado) {
          if (emprestimoAtualizado == null) {
            return;
          }

          setState(() {
            _emprestimo = emprestimoAtualizado;
          });

          // se foi devolvido, mostra mensagem e volta pra home
          if (emprestimoAtualizado.isDevolvido) {
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
                // mostra mensagem de sucesso
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Devolução confirmada com sucesso!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 3),
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
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(child: AppLogo()),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(26.0),
              child: _buildContent(),
            ),
          ),
          // Botão de voltar
          if (_emprestimo?.isDevolvido != true && _emprestimo?.isBlocoCorreto != false)
            const Padding(
              padding: EdgeInsets.only(bottom: 26.0),
              child: Center(child: CircularCloseButton()),
            ),
          if (_emprestimo?.isDevolvido == true || _emprestimo?.isBlocoCorreto == false) const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildContent() {
    // cria um emprestimo fake só pra usar o widget de status
    // mas com status customizado pra devolucao
    return QRStatusWidget(
      isLoading: _isLoading,
      error: null,
      emprestimo: _emprestimo,
      qrData: _qrData,
      onRetry: () {},
      isDevolucao: true,
      onRecusaOk: _resetBlocoCorreto,
    );
  }

  // reseta o isBlocoCorreto para null
  void _resetBlocoCorreto() {
    if (_emprestimo != null) {
      _emprestimoService.atualizarEmprestimo(_emprestimo!.id!, {
        'isBlocoCorreto': null,
      });
    }
  }
}
