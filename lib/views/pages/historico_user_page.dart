import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../models/equipamento.dart';
import '../../services/auth_service.dart';
import '../../services/emprestimo_service.dart';
import '../../services/equipamento_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar.dart';

class HistoricoUserPage extends StatefulWidget {
  const HistoricoUserPage({super.key});

  @override
  State<HistoricoUserPage> createState() => _HistoricoUserPageState();
}

class _HistoricoUserPageState extends State<HistoricoUserPage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  final AuthService _authService = AuthService();

  List<EmprestimoModel> _emprestimos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final emprestimos = await _emprestimoService.listarEmprestimosPorUsuario(
        userId,
      );

      // filtra apenas ativos e devolvidos (exclui pendentes e recusados)
      final emprestimosFiltrados = emprestimos
          .where((e) => e.isAtivo || e.isDevolvido)
          .toList();

      setState(() {
        _emprestimos = emprestimosFiltrados;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar histórico: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: SafeArea(
        child: Column(
          children: [
            // header
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLogo()),
            ),

            // titulo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Histórico de Empréstimos',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // conteudo
            Expanded(
              child: _isLoading
                  ? _buildLoading()
                  : _error != null
                      ? _buildError()
                      : _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 1),
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
            'Carregando histórico...',
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
              onPressed: _carregarHistorico,
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
    if (_emprestimos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum empréstimo encontrado',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Seu histórico aparecerá aqui',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarHistorico,
      color: const Color.fromARGB(255, 86, 22, 36),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _emprestimos.length,
        itemBuilder: (context, index) {
          final emprestimo = _emprestimos[index];
          return _buildEmprestimoCard(emprestimo, index + 1);
        },
      ),
    );
  }

  Widget _buildEmprestimoCard(EmprestimoModel emprestimo, int numero) {
    return GestureDetector(
      onTap: () => _abrirDetalhes(emprestimo, numero),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Faixa de cor lateral
            Container(
              width: 6,
              height: 82,
              decoration: BoxDecoration(
                color: _getStatusColor(emprestimo),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Conteúdo
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusBadge(emprestimo),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatarTituloEmprestimo(emprestimo),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 86, 22, 36),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${emprestimo.codigosEquipamentos.length} ${emprestimo.codigosEquipamentos.length == 1 ? 'equipamento' : 'equipamentos'}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarDataCompleta(emprestimo.criadoEm),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: Color.fromARGB(255, 86, 22, 36),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(EmprestimoModel emprestimo) {
    if (emprestimo.isPendente) {
      return Colors.orange;
    } else if (emprestimo.isRecusado) {
      return Colors.red;
    } else if (emprestimo.isDevolvido) {
      return Colors.green;
    } else if (emprestimo.isAtivo) {
      return const Color.fromARGB(255, 86, 22, 36);
    } else {
      return Colors.grey;
    }
  }

  Widget _buildStatusBadge(EmprestimoModel emprestimo) {
    Color color;
    String text;

    if (emprestimo.isPendente) {
      color = Colors.orange;
      text = 'Pendente';
    } else if (emprestimo.isRecusado) {
      color = Colors.red;
      text = 'Recusado';
    } else if (emprestimo.isDevolvido) {
      color = Colors.green;
      text = 'Devolvido';
    } else if (emprestimo.isAtivo) {
      color = const Color.fromARGB(255, 86, 22, 36);
      text = 'Ativo';
    } else {
      color = Colors.grey;
      text = '?';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  void _abrirDetalhes(EmprestimoModel emprestimo, int numero) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoricoDetalhesPage(
          emprestimo: emprestimo,
          numero: numero,
        ),
      ),
    );
  }

  String _formatarTituloEmprestimo(EmprestimoModel emprestimo) {
    final data = emprestimo.criadoEm;
    final meses = [
      'Jan',
      'Fev',
      'Mar',
      'Abr',
      'Mai',
      'Jun',
      'Jul',
      'Ago',
      'Set',
      'Out',
      'Nov',
      'Dez',
    ];
    return '${data.day} ${meses[data.month - 1]} ${data.year}';
  }

  String _formatarDataCompleta(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}

// Página de detalhes do histórico
class HistoricoDetalhesPage extends StatefulWidget {
  final EmprestimoModel emprestimo;
  final int numero;

  const HistoricoDetalhesPage({
    super.key,
    required this.emprestimo,
    required this.numero,
  });

  @override
  State<HistoricoDetalhesPage> createState() => _HistoricoDetalhesPageState();
}

class _HistoricoDetalhesPageState extends State<HistoricoDetalhesPage> {
  final EquipamentoService _equipamentoService = EquipamentoService();
  List<Equipamento?> _equipamentos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarEquipamentos();
  }

  Future<void> _carregarEquipamentos() async {
    try {
      final equipamentos = await Future.wait(
        widget.emprestimo.codigosEquipamentos.map(
          (codigo) => _equipamentoService.buscarPorCodigo(codigo),
        ),
      );

      setState(() {
        _equipamentos = equipamentos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final numeroFormatado = widget.numero.toString().padLeft(3, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: SafeArea(
        child: Column(
          children: [
            // header com logo
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(child: Center(child: AppLogo())),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // titulo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    'Empréstimo $numeroFormatado',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // conteudo
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 1),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    if (widget.emprestimo.isPendente) {
      color = Colors.orange;
      text = 'Pendente';
      icon = Icons.pending;
    } else if (widget.emprestimo.isRecusado) {
      color = Colors.red;
      text = 'Recusado';
      icon = Icons.cancel;
    } else if (widget.emprestimo.isDevolvido) {
      color = Colors.green;
      text = 'Devolvido';
      icon = Icons.check_circle;
    } else if (widget.emprestimo.isAtivo) {
      color = Colors.blue;
      text = 'Ativo';
      icon = Icons.check_circle;
    } else {
      color = Colors.grey;
      text = 'Desconhecido';
      icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(),
          const SizedBox(height: 24),

          // lista de equipamentos
          const Text(
            'Equipamentos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 86, 22, 36),
            ),
          ),
          const SizedBox(height: 12),
          ..._equipamentos.asMap().entries.map((entry) {
            final index = entry.key;
            final equipamento = entry.value;
            return _buildEquipamentoItem(equipamento, index + 1);
          }),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
            'Solicitado em',
            _formatarDataCompleta(widget.emprestimo.criadoEm),
          ),
          if (widget.emprestimo.confirmedoEm != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle_outline,
              widget.emprestimo.isConfirmado ? 'Confirmado em' : 'Recusado em',
              _formatarDataCompleta(widget.emprestimo.confirmedoEm!),
            ),
          ],
          if (widget.emprestimo.devolvidoEm != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.assignment_turned_in,
              'Devolvido em',
              _formatarDataCompleta(widget.emprestimo.devolvidoEm!),
            ),
          ],
          if (widget.emprestimo.isConfirmado &&
              !widget.emprestimo.isDevolvido) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.emprestimo.isAtrasadoAtual
                    ? Colors.red.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: widget.emprestimo.isAtrasadoAtual
                      ? Colors.red
                      : Colors.orange,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    widget.emprestimo.isAtrasadoAtual
                        ? Icons.warning
                        : Icons.schedule,
                    color: widget.emprestimo.isAtrasadoAtual
                        ? Colors.red
                        : Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.emprestimo.isAtrasadoAtual
                              ? 'PRAZO VENCIDO!'
                              : 'Prazo de devolução',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.emprestimo.isAtrasadoAtual
                                ? Colors.red
                                : Colors.orange[800],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Até ${widget.emprestimo.prazoLimiteDevolucao.day.toString().padLeft(2, '0')}/${widget.emprestimo.prazoLimiteDevolucao.month.toString().padLeft(2, '0')} às 22:30',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.emprestimo.isAtrasadoAtual
                                ? Colors.red
                                : Colors.orange[900],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (widget.emprestimo.atrasado) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Este empréstimo foi devolvido com atraso',
                      style: TextStyle(
                        fontSize: 14,
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

  Widget _buildEquipamentoItem(Equipamento? equipamento, int numero) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Número
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 86, 22, 36),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // informacoes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipamento?.displayName ?? 'Equipamento',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 86, 22, 36),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CÓD: ${equipamento?.codigo ?? '—'}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
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
