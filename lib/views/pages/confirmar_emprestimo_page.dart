import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../models/user_model.dart';
import '../../models/equipamento.dart';
import '../../services/emprestimo_service.dart';
import '../../services/user_service.dart';
import '../../services/equipamento_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/emprestimo/user_info_card.dart';
import '../widgets/emprestimo/solicitation_info_badge.dart';
import '../widgets/emprestimo/equipamento_card_widget.dart';
import 'atendente_home_page.dart';
import 'registros_emprestimos_page.dart';

// pagina pra exibir detalhes do emprestimo e confirmar
class ConfirmarEmprestimoPage extends StatefulWidget {
  final EmprestimoModel emprestimo;
  final String? nomeBloco;

  const ConfirmarEmprestimoPage({
    super.key,
    required this.emprestimo,
    this.nomeBloco,
  });

  @override
  State<ConfirmarEmprestimoPage> createState() => _ConfirmarEmprestimoPageState();
}

class _ConfirmarEmprestimoPageState extends State<ConfirmarEmprestimoPage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  final UserService _userService = UserService();
  final EquipamentoService _equipamentoService = EquipamentoService();
  final AuthService _authService = AuthService();

  UserModel? _usuario;
  List<Equipamento?> _equipamentos = [];
  bool _isLoading = true;
  bool _isConfirming = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  // carrega os dados do usuario e equipamentos
  Future<void> _carregarDados() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final usuario = await _userService.getUser(widget.emprestimo.userId);
      
      final equipamentos = await Future.wait(
        widget.emprestimo.codigosEquipamentos.map(
          (codigo) => _equipamentoService.buscarPorCodigo(codigo),
        ),
      );

      setState(() {
        _usuario = usuario;
        _equipamentos = equipamentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar dados: $e';
        _isLoading = false;
      });
    }
  }

  // confirma o emprestimo
  Future<void> _confirmarEmprestimo() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      final atendenteId = _authService.currentUser?.uid;
      if (atendenteId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _emprestimoService.confirmarEmprestimo(widget.emprestimo.id!, atendenteId);
      
      if (mounted) {
        // mensagem de sucesso
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Empréstimo confirmado com sucesso!')),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          if (widget.nomeBloco != null) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => RegistrosEmprestimosPage(nomeBloco: widget.nomeBloco!),
                settings: RouteSettings(arguments: {'nomeBloco': widget.nomeBloco}),
              ),
              (route) => false,
            );
          } else {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => AtendenteHomePage(user: _usuario),
              ),
              (route) => false,
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isConfirming = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao confirmar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // recusa o emprestimo
  Future<void> _recusarEmprestimo() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      await _emprestimoService.recusarEmprestimo(widget.emprestimo.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cancel, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Empréstimo recusado')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => AtendenteHomePage(user: _usuario),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      setState(() {
        _isConfirming = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao recusar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: AppLogo(),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Confirmar Empréstimo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            // Conteúdo
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),

            if (!_isLoading && _error == null)
              _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SizedBox(height: 20),
          Text(
            'Carregando informações...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Informações do usuário
          // informações do user
          UserInfoCard(usuario: _usuario),
          const SizedBox(height: 24),

          SolicitationInfoBadge(dateTime: widget.emprestimo.criadoEm),
          const SizedBox(height: 32),

          // equipamentos
          _buildEquipamentosSection(),
          const SizedBox(height: 100), // Espaço para os botões
        ],
      ),
    );
  }

  Widget _buildEquipamentosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Equipamentos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_equipamentos.length} ${_equipamentos.length == 1 ? 'item' : 'itens'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._equipamentos.asMap().entries.map((entry) {
          final index = entry.key;
          final equipamento = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: EquipamentoCardWidget(
              equipamento: equipamento,
              numero: index + 1,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botão Recusar
          Expanded(
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _recusarEmprestimo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Recusar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // Botão Confirmar
          Expanded(
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirmarEmprestimo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isConfirming
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Confirmar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
