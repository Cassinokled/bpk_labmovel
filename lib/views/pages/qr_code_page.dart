import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
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
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  String _qrData = '';
  EmprestimoModel? _emprestimo;
  StreamSubscription? _emprestimoSubscription;
  bool _isLoading = true;
  String? _error;
  String? _errorTitle;

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

      // verificar se o usuario tem pendencias
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUser(currentUser.uid);
        if (userData != null && userData.comPendencias) {
          // mostrar a data do atraso
          final emprestimosAtrasados = await _getEmprestimosAtrasados(currentUser.uid);
          final dataAtraso = emprestimosAtrasados.isNotEmpty 
            ? emprestimosAtrasados.first.confirmedoEm 
            : null;
          
          final dataFormatada = dataAtraso != null 
            ? '${dataAtraso.day.toString().padLeft(2, '0')}/${dataAtraso.month.toString().padLeft(2, '0')}/${dataAtraso.year}'
            : 'data desconhecida';

          //repensar nesse texto aqui tambem
          setState(() {
            _errorTitle = 'Você possui uma pendência com o empréstimo do dia $dataFormatada.';
            _error = 'Converse com a contabilidade e resolva a pendência antes de solicitar novos empréstimos.';
            _isLoading = false;
          });
          return;
        }
      }

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

  // busca emprestimos atrasados
  Future<List<EmprestimoModel>> _getEmprestimosAtrasados(String userId) async {
    try {
      final todosEmprestimos = await _emprestimoService.listarEmprestimosPorUsuario(userId);
      
      final emprestimosAtrasados = todosEmprestimos
          .where((emprestimo) => 
            emprestimo.isConfirmado && 
            emprestimo.devolvido == null && 
            emprestimo.isAtrasadoAtual
          )
          .toList();

      emprestimosAtrasados.sort((a, b) => b.confirmedoEm!.compareTo(a.confirmedoEm!));

      return emprestimosAtrasados;
    } catch (e) {
      return [];
    }
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
          Padding(padding: const EdgeInsets.all(26.0), child: _buildContent()),
          const Spacer(),
          // botao de voltar (so mostra se estiver pendente)
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
      errorTitle: _errorTitle,
      errorBody: _error,
      emprestimo: _emprestimo,
      qrData: _qrData,
      onRetry: _initializeEmprestimo,
      onBack: _errorTitle != null ? () => Navigator.of(context).pop() : null,
    );
  }
}
