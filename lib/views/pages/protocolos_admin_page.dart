import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/solicitacao_relatorio_service.dart';
import '../../models/solicitacao_relatorio_model.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import 'protocolo_detalhes_admin_page.dart';

class ProtocolosAdminPage extends StatefulWidget {
  const ProtocolosAdminPage({super.key});

  @override
  State<ProtocolosAdminPage> createState() => _ProtocolosAdminPageState();
}

class _ProtocolosAdminPageState extends State<ProtocolosAdminPage> {
  final SolicitacaoRelatorioService _solicitacaoService = SolicitacaoRelatorioService();
  final UserService _userService = UserService();

  List<SolicitacaoRelatorioModel> _solicitacoes = [];
  Map<String, UserModel> _usersCache = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    setState(() => _isLoading = true);

    try {
      final solicitacoes = await _solicitacaoService.buscarTodasSolicitacoes();

      final userIds = solicitacoes.map((s) => s.userId).toSet();
      final usersMap = await _userService.getUsersMap(userIds);

      setState(() {
        _solicitacoes = solicitacoes;
        _usersCache = usersMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar protocolos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Text(
            'Validação de Protocolos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),

        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _solicitacoes.isEmpty
                  ? _buildEmptyState()
                  : _buildSolicitacoesList(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_turned_in,
              size: 64,
              color: AppColors.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhum protocolo pendente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Nenhum protocolo encontrado.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolicitacoesList() {
    return RefreshIndicator(
      onRefresh: _carregarSolicitacoes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _solicitacoes.length,
        itemBuilder: (context, index) {
          final solicitacao = _solicitacoes[index];
          final user = _usersCache[solicitacao.userId];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => _mostrarDetalhesSolicitacao(solicitacao, user),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            solicitacao.titulo,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(solicitacao),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          user?.nomeCompleto ?? 'Usuário desconhecido',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          '${solicitacao.dataInicio.day}/${solicitacao.dataInicio.month}/${solicitacao.dataInicio.year} - '
                          '${solicitacao.dataFim.day}/${solicitacao.dataFim.month}/${solicitacao.dataFim.year}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Toque para ver detalhes',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(SolicitacaoRelatorioModel solicitacao) {
    Color backgroundColor;
    Color textColor;
    String statusText;
    IconData icon;

    if (solicitacao.isPendente) {
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
      statusText = 'Pendente';
      icon = Icons.hourglass_empty;
    } else if (solicitacao.isAprovado) {
      backgroundColor = AppColors.success.withOpacity(0.1);
      textColor = AppColors.success;
      statusText = 'Aprovado';
      icon = Icons.check_circle;
    } else {
      backgroundColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
      statusText = 'Rejeitado';
      icon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: textColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarDetalhesSolicitacao(SolicitacaoRelatorioModel solicitacao, UserModel? user) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => ProtocoloDetalhesAdminPage(
          solicitacao: solicitacao,
          user: user,
        ),
      ),
    );

    if (result == true) {
      _carregarSolicitacoes(); 
    }
  }
}