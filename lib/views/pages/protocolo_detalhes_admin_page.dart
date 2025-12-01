import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/solicitacao_relatorio_model.dart';
import '../../models/user_model.dart';
import '../../services/solicitacao_relatorio_service.dart';
import '../../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/emprestimo/user_info_card.dart';
import '../widgets/emprestimo/solicitation_info_badge.dart';
import '../../services/user_service.dart';

class ProtocoloDetalhesAdminPage extends StatefulWidget {
  final SolicitacaoRelatorioModel solicitacao;
  final UserModel? user;

  const ProtocoloDetalhesAdminPage({
    super.key,
    required this.solicitacao,
    this.user,
  });

  @override
  State<ProtocoloDetalhesAdminPage> createState() => _ProtocoloDetalhesAdminPageState();
}

class _ProtocoloDetalhesAdminPageState extends State<ProtocoloDetalhesAdminPage> {
  final SolicitacaoRelatorioService _solicitacaoService = SolicitacaoRelatorioService();
  final UserService _userService = UserService();
  bool _isProcessing = false;
  String? _adminName;

  @override
  void initState() {
    super.initState();
    _carregarDadosAdmin();
  }

  Future<void> _carregarDadosAdmin() async {
    if (widget.solicitacao.atendenteId != null) {
      try {
        final adminUser = await _userService.getUser(widget.solicitacao.atendenteId!);
        setState(() {
          _adminName = adminUser?.nomeCompleto ?? 'Admin desconhecido';
        });
      } catch (e) {
        setState(() {
          _adminName = 'Admin desconhecido';
        });
      }
    }
  }

  Future<void> _aprovarSolicitacao() async {
    setState(() => _isProcessing = true);

    try {
      final adminId = AuthService().currentUser?.uid ?? 'admin_desconhecido';
      await _solicitacaoService.aprovarSolicitacao(widget.solicitacao.id!, adminId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Protocolo aprovado com sucesso!')),
              ],
            ),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao aprovar protocolo: $e')),
        );
      }
    }
  }

  Future<void> _rejeitarSolicitacao() async {
    final TextEditingController motivoController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rejeitar Protocolo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Motivo da Solicitação:'),
            const SizedBox(height: 8),
            TextField(
              controller: motivoController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Digite o motivo da rejeição...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (motivoController.text.trim().isNotEmpty) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Rejeitar'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      setState(() => _isProcessing = true);

      try {
        final adminId = AuthService().currentUser?.uid ?? 'admin_desconhecido';
        await _solicitacaoService.rejeitarSolicitacao(
          widget.solicitacao.id!,
          motivoController.text.trim(),
          adminId,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.cancel, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Protocolo rejeitado')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao rejeitar protocolo: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const Expanded(
                    child: Center(child: AppLogo()),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                widget.solicitacao.titulo,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // conteudo principal
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // info do user
                    UserInfoCard(usuario: widget.user),
                    const SizedBox(height: 24),

                    // data
                    SolicitationInfoBadge(dateTime: widget.solicitacao.criadoEm),
                    const SizedBox(height: 24),

                    // info do admin (se processado)
                    if (!widget.solicitacao.isPendente) ...[
                      _buildAdminInfoSection(),
                      const SizedBox(height: 24),
                    ],

                    // motico rejeicao
                    if (widget.solicitacao.isRejeitado && widget.solicitacao.motivoRejeicao != null) ...[
                      _buildMotivoRejeicaoSection(),
                      const SizedBox(height: 24),
                    ],

                    // motivo solicitacao
                    _buildMotivoSection(),
                    const SizedBox(height: 24),

                    // periodo
                    _buildPeriodoSection(),

                    // arquivo
                    if (widget.solicitacao.comprovanteUrl != null) ...[
                      const SizedBox(height: 24),
                      _buildArquivoSection(),
                    ],

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            if (widget.solicitacao.isPendente) _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Período de Utilização',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Data de Início',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.solicitacao.dataInicio.day}/${widget.solicitacao.dataInicio.month}/${widget.solicitacao.dataInicio.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Separador
              Container(
                width: 1,
                height: 40,
                color: AppColors.primary.withOpacity(0.2),
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Data de Fim',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.solicitacao.dataFim.day}/${widget.solicitacao.dataFim.month}/${widget.solicitacao.dataFim.year}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoRejeicaoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Motivo da Rejeição',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Text(
            widget.solicitacao.motivoRejeicao!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.red.shade800,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Motivo da Solicitação',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Text(
            widget.solicitacao.motivo,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget _buildArquivoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Arquivo Anexado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.attach_file,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Comprovante anexado',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  // tem que implementar ainda a visualizacao dos arquivos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Funcionalidade de visualização em desenvolvimento')),
                  );
                },
                icon: Icon(
                  Icons.visibility,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdminInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Analista',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.person,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _adminName ?? 'Carregando...',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
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
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _rejeitarSolicitacao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isProcessing
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
                          'Rejeitar',
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
          Expanded(
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _aprovarSolicitacao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isProcessing
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
                          'Aprovar',
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