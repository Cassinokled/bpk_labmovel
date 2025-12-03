import 'package:flutter/material.dart';
import '../../models/solicitacao_relatorio_model.dart';
import '../../services/auth_service.dart';
import '../../services/solicitacao_relatorio_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_user.dart';
import '../../utils/app_colors.dart';
import 'solicitacao_relatorio.dart';
import 'solicitacao_relatorio_detalhes_page.dart';

class RelatorioUserPage extends StatefulWidget {
  const RelatorioUserPage({super.key});

  @override
  State<RelatorioUserPage> createState() => _RelatorioUserPageState();
}

class _RelatorioUserPageState extends State<RelatorioUserPage> {
  final AuthService _authService = AuthService();
  final SolicitacaoRelatorioService _solicitacaoService = SolicitacaoRelatorioService();

  List<SolicitacaoRelatorioModel> _solicitacoes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarSolicitacoes();
  }

  Future<void> _carregarSolicitacoes() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      final solicitacoes = await _solicitacaoService.buscarSolicitacoesPorUsuario(userId);

      setState(() {
        _solicitacoes = solicitacoes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erro ao carregar solicitações: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // header
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLogo()),
            ),

            const SizedBox(height: 20),

            //  solicitar novo protocolo
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 300,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SolicitacaoRelatorioPage(),
                      ),
                    ).then((_) => _carregarSolicitacoes());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Solicitar novo protocolo',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider),
            ),

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
      bottomNavigationBar: const NavBarUser(selectedIndex: 3),
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
            'Carregando solicitações...',
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
              onPressed: _carregarSolicitacoes,
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
    if (_solicitacoes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 100,
              color: AppColors.primary,
            ),
            const SizedBox(height: 20),
            const Text(
              'Sem protocolos \nsolicitados!',
              style: TextStyle(
                fontSize: 24,
                color: AppColors.primaryMedium,
                fontFamily: 'Avignon',
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarSolicitacoes,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _solicitacoes.length,
        itemBuilder: (context, index) {
          final solicitacao = _solicitacoes[index];
          return _buildSolicitacaoCard(solicitacao, index + 1);
        },
      ),
    );
  }

  Widget _buildSolicitacaoCard(SolicitacaoRelatorioModel solicitacao, int numero) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (solicitacao.isPendente) {
      statusColor = Colors.orange;
      statusText = 'Pendente';
      statusIcon = Icons.hourglass_empty;
    } else if (solicitacao.isAprovado) {
      statusColor = Colors.green;
      statusText = 'Aprovado';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusText = 'Rejeitado';
      statusIcon = Icons.cancel;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SolicitacaoRelatorioDetalhesPage(
              solicitacao: solicitacao,
              numero: numero,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(left: 0, right: 0, top: 4, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone da solicitação
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description_outlined,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Informações da solicitação
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    solicitacao.titulo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Solicitado em ${solicitacao.criadoEm.day.toString().padLeft(2, '0')}/${solicitacao.criadoEm.month.toString().padLeft(2, '0')}/${solicitacao.criadoEm.year}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        statusIcon,
                        size: 14,
                        color: statusColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
