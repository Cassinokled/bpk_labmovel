import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../models/equipamento.dart';
import '../../services/equipamento_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar.dart';

class EmprestimoDetalhesPage extends StatefulWidget {
  final EmprestimoModel emprestimo;
  final int numero;

  const EmprestimoDetalhesPage({
    super.key,
    required this.emprestimo,
    required this.numero,
  });

  @override
  State<EmprestimoDetalhesPage> createState() => _EmprestimoDetalhesPageState();
}

class _EmprestimoDetalhesPageState extends State<EmprestimoDetalhesPage> {
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
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          SizedBox(width: 8),
          Text(
            'Ativo',
            style: TextStyle(
              color: Colors.green,
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
    final prazo = widget.emprestimo.prazoLimiteDevolucao;
    final isAtrasado = widget.emprestimo.isDevolvido 
        ? widget.emprestimo.atrasado 
        : widget.emprestimo.isAtrasadoAtual;
    
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
            _formatarDataCompleta(widget.emprestimo.criadoEm),
          ),
          if (widget.emprestimo.confirmedoEm != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle_outline,
              'Confirmado em',
              _formatarDataCompleta(widget.emprestimo.confirmedoEm!),
            ),
          ],
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
                      if (!isAtrasado) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatarTempoRestante(widget.emprestimo.tempoRestante),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
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
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return '${data.day} ${meses[data.month - 1]} ${data.year} às ${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }

  String _formatarTempoRestante(Duration tempo) {
    if (tempo.inHours > 0) {
      final horas = tempo.inHours;
      final minutos = tempo.inMinutes % 60;
      return '$horas hora${horas > 1 ? 's' : ''} e $minutos min restantes';
    } else if (tempo.inMinutes > 0) {
      return '${tempo.inMinutes} minutos restantes';
    } else {
      return 'Menos de 1 minuto';
    }
  }
}
