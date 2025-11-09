import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../models/user_model.dart';
import '../../models/equipamento.dart';
import '../../services/emprestimo_service.dart';
import '../../services/user_service.dart';
import '../../services/equipamento_service.dart';
import '../../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/emprestimo/user_info_card.dart';
import '../widgets/emprestimo/equipamento_card_widget.dart';
import 'atendente_home_page.dart';

// pagina de detalhes do emprestimo e confirmar devolucao
class ConfirmarDevolucaoPage extends StatefulWidget {
  final EmprestimoModel emprestimo;

  const ConfirmarDevolucaoPage({super.key, required this.emprestimo});

  @override
  State<ConfirmarDevolucaoPage> createState() => _ConfirmarDevolucaoPageState();
}

class _ConfirmarDevolucaoPageState extends State<ConfirmarDevolucaoPage> {
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

  Future<void> _confirmarDevolucao() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      final atendenteId = _authService.currentUser?.uid;
      if (atendenteId == null) {
        throw Exception('Usuário não autenticado');
      }

      await _emprestimoService.devolverEmprestimo(
        widget.emprestimo.id!,
        atendenteId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Devolução confirmada com sucesso!')),
              ],
            ),
            backgroundColor: Colors.green,
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
                Expanded(child: Text('Erro ao confirmar devolução: $e')),
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

            // Título
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Confirmar Devolução',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
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

            if (!_isLoading && _error == null) _buildActionButtons(),
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
          CircularProgressIndicator(color: Color.fromARGB(255, 86, 22, 36)),
          SizedBox(height: 20),
          Text(
            'Carregando informações...',
            style: TextStyle(
              fontSize: 16,
              color: Color.fromARGB(255, 86, 22, 36),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 20),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _carregarDados,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 86, 22, 36),
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
          UserInfoCard(usuario: _usuario),
          const SizedBox(height: 24),

          _buildInfoCard(),
          const SizedBox(height: 24),

          _buildEquipamentosSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final emprestadoEm =
        widget.emprestimo.confirmedoEm ?? widget.emprestimo.criadoEm;
    final prazo = widget.emprestimo.prazoLimiteDevolucao;
    final isAtrasado = widget.emprestimo.isAtrasadoAtual;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.calendar_today,
            'Emprestado em',
            _formatarDataCompleta(emprestadoEm),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAtrasado
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isAtrasado ? Colors.red : Colors.orange,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isAtrasado ? Icons.warning : Icons.schedule,
                  color: isAtrasado ? Colors.red : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAtrasado ? 'PRAZO VENCIDO!' : 'Prazo de devolução',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isAtrasado ? Colors.red : Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Até ${prazo.day.toString().padLeft(2, '0')}/${prazo.month.toString().padLeft(2, '0')} às 22:30',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isAtrasado ? Colors.red : Colors.orange[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isAtrasado) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este empréstimo será marcado como atrasado',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color.fromARGB(255, 86, 22, 36), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ],
          ),
        ),
      ],
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
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 86, 22, 36),
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
          // Botão Cancelar
          Expanded(
            child: ElevatedButton(
              onPressed: _isConfirming ? null : () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.grey[300],
                foregroundColor: Colors.grey[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.close, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cancelar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirmarDevolucao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.green,
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
                        Icon(Icons.assignment_turned_in, size: 20),
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

  String _formatarDataCompleta(DateTime data) {
    final meses = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    return '${data.day} ${meses[data.month - 1]} ${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}
