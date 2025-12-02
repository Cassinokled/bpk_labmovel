import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../utils/app_colors.dart';
import '../../models/solicitacao_relatorio_model.dart';
import '../../services/solicitacao_relatorio_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_user.dart';
import 'package:open_filex/open_filex.dart';

class SolicitacaoRelatorioDetalhesPage extends StatefulWidget {
  final SolicitacaoRelatorioModel solicitacao;
  final int numero;

  const SolicitacaoRelatorioDetalhesPage({
    super.key,
    required this.solicitacao,
    required this.numero,
  });

  @override
  State<SolicitacaoRelatorioDetalhesPage> createState() => _SolicitacaoRelatorioDetalhesPageState();
}

class _SolicitacaoRelatorioDetalhesPageState extends State<SolicitacaoRelatorioDetalhesPage> {
  final SolicitacaoRelatorioService _solicitacaoService = SolicitacaoRelatorioService();

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

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Text(
                    widget.solicitacao.titulo,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildStatusBadge(),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoCard(constraints.maxHeight),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarUser(selectedIndex: 3),
    );
  }

  Widget _buildStatusBadge() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (widget.solicitacao.isPendente) {
      statusColor = Colors.orange;
      statusText = 'Pendente';
      statusIcon = Icons.hourglass_empty;
    } else if (widget.solicitacao.isAprovado) {
      statusColor = Colors.green;
      statusText = 'Aprovado';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = Colors.red;
      statusText = 'Rejeitado';
      statusIcon = Icons.cancel;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(double availableHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      
        if (widget.solicitacao.isRejeitado && widget.solicitacao.motivoRejeicao != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Motivo da Rejeição',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    widget.solicitacao.motivoRejeicao!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Motivo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.solicitacao.motivo,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Período',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Emprestimo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.solicitacao.dataInicio.day}/${widget.solicitacao.dataInicio.month}/${widget.solicitacao.dataInicio.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: Colors.grey.withValues(alpha: 0.3),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Devolução',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.solicitacao.dataFim.day}/${widget.solicitacao.dataFim.month}/${widget.solicitacao.dataFim.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data de Solicitação',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.solicitacao.criadoEm.day}/${widget.solicitacao.criadoEm.month}/${widget.solicitacao.criadoEm.year} às ${widget.solicitacao.criadoEm.hour.toString().padLeft(2, '0')}:${widget.solicitacao.criadoEm.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),

        if (widget.solicitacao.comprovanteUrl != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 16),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Arquivo Anexado',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _launchURL(widget.solicitacao.comprovanteUrl!),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _getFileName(widget.solicitacao.comprovanteUrl!),
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

      ],
    );
  }

  String _getFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final parts = path.split('/');
      final oIndex = parts.indexOf('o');
      if (oIndex != -1 && oIndex + 1 < parts.length) {
        final encodedPath = parts[oIndex + 1]; 
        final decodedPath = Uri.decodeComponent(encodedPath);
        return decodedPath.split('/').last;
      }
      return 'Arquivo anexado';
    } catch (e) {
      return 'Arquivo anexado'; 
    }
  }

  Future<void> _launchURL(String arquivoId) async {
    try {
      // loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                ),
                SizedBox(width: 16),
                Text('Abrindo arquivo...'),
              ],
            ),
            duration: Duration(seconds: 30),
          ),
        );
      }

      // buscando no firestore
      final arquivo = await _solicitacaoService.buscarArquivo(arquivoId);
      
      if (arquivo == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Arquivo não encontrado')),
          );
        }
        return;
      }

      // decodificando base64
      final bytes = base64Decode(arquivo['base64Data'] as String);
      final fileName = arquivo['fileName'] as String;
      
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      
      // salva
      await file.writeAsBytes(bytes);

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }

      // tenta abrir
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao abrir arquivo: ${result.message}\nArquivo salvo em: $filePath'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir arquivo: $e')),
        );
      }
    }
  }
}
