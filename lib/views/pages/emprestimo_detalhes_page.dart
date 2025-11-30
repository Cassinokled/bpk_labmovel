import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/emprestimo_model.dart';
import '../../models/equipamento.dart';
import '../../models/user_model.dart';
import '../../services/equipamento_service.dart';
import '../../services/user_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_user.dart';
import '../widgets/navbar_atendente.dart';
import 'qr_code_devolucao_page.dart';

class EmprestimoDetalhesPage extends StatefulWidget {
  final EmprestimoModel emprestimo;
  final int numero;
  final bool isAtendente;

  const EmprestimoDetalhesPage({
    super.key,
    required this.emprestimo,
    required this.numero,
    this.isAtendente = false,
  });

  @override
  State<EmprestimoDetalhesPage> createState() => _EmprestimoDetalhesPageState();
}

class _EmprestimoDetalhesPageState extends State<EmprestimoDetalhesPage> {
  final EquipamentoService _equipamentoService = EquipamentoService();
  final UserService _userService = UserService();
  List<Equipamento?> _equipamentos = [];
  bool _isLoading = true;
  UserModel? _usuario;
  UserModel? _atendente;
  UserModel? _atendenteDevolucao;

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

      // busca usuario
      UserModel? usuario;
      try {
        usuario = await _userService.getUser(widget.emprestimo.userId);
      } catch (e) {
        // ignore
      }

      // busca atendente
      UserModel? atendente;
      if (widget.emprestimo.atendenteEmprestimoId != null) {
        try {
          atendente = await _userService.getUser(widget.emprestimo.atendenteEmprestimoId!);
        } catch (e) {
          // ignore
        }
      }

      // busca atendente de devolucao
      UserModel? atendenteDevolucao;
      if (widget.emprestimo.atendenteDevolucaoId != null) {
        try {
          atendenteDevolucao = await _userService.getUser(widget.emprestimo.atendenteDevolucaoId!);
        } catch (e) {
          // ignore
        }
      }

      setState(() {
        _equipamentos = equipamentos;
        _usuario = usuario;
        _atendente = atendente;
        _atendenteDevolucao = atendenteDevolucao;
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
      backgroundColor: AppColors.background,
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
                      color: AppColors.primary,
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
                      color: AppColors.primary,
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
      bottomNavigationBar: widget.isAtendente ? const NavBarAtendente() : const NavBarUser(),
    );
  }

  Widget _buildStatusBadge() {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    String statusText;

    if (widget.emprestimo.isDevolvido) {
      backgroundColor = widget.emprestimo.atrasado ? AppColors.errorLight : AppColors.successLight;
      borderColor = widget.emprestimo.atrasado ? AppColors.error : AppColors.success;
      textColor = widget.emprestimo.atrasado ? AppColors.error : AppColors.success;
      icon = widget.emprestimo.atrasado ? Icons.warning : Icons.check_circle;
      statusText = widget.emprestimo.atrasado ? 'Devolvido Atrasado' : 'Devolvido';
    } else if (widget.emprestimo.isRecusado) {
      backgroundColor = AppColors.errorLight;
      borderColor = AppColors.error;
      textColor = AppColors.error;
      icon = Icons.cancel;
      statusText = 'Recusado';
    } else {
      backgroundColor = AppColors.successLight;
      borderColor = AppColors.success;
      textColor = AppColors.success;
      icon = Icons.check_circle;
      statusText = 'Ativo';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: 8),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
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
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ..._equipamentos.asMap().entries.map((entry) {
            final index = entry.key;
            final equipamento = entry.value;
            return _buildEquipamentoItem(equipamento, index + 1);
          }),
          const SizedBox(height: 24),

          // botao de gerar qr para devolucao (apenas para usuario)
          if (!widget.isAtendente) _buildDevolucaoButton(),
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
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // quem esta com os equipamentos e quem realizou (so atendentes conseguem ver)
          if (widget.isAtendente) ...[
            if (_usuario != null)
              _buildInfoRow(
                Icons.person,
                'Equipamentos com',
                _usuario!.nomeCompleto,
              ),
            if (_usuario != null) const SizedBox(height: 12),

            if (_atendente != null)
              _buildInfoRow(
                Icons.admin_panel_settings,
                'Empréstimo realizado por',
                _atendente!.nomeCompleto,
              ),
            if (_atendente != null) const SizedBox(height: 12),

            if (_atendenteDevolucao != null)
              _buildInfoRow(
                Icons.admin_panel_settings,
                'Devolução realizada por',
                _atendenteDevolucao!.nomeCompleto,
              ),
            if (_atendenteDevolucao != null) const SizedBox(height: 12),
          ],

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
          if (widget.emprestimo.devolvidoEm != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.undo,
              'Devolvido em',
              _formatarDataCompleta(widget.emprestimo.devolvidoEm!),
            ),
          ],
          if (!widget.emprestimo.isDevolvido && !widget.emprestimo.isRecusado) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isAtrasado
                    ? AppColors.errorLight
                    : AppColors.warningLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isAtrasado ? AppColors.error : AppColors.warning,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isAtrasado ? Icons.warning : Icons.schedule,
                    color: isAtrasado ? AppColors.error : AppColors.warning,
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
                            color: isAtrasado ? AppColors.error : AppColors.warning,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Até ${prazo.day.toString().padLeft(2, '0')}/${prazo.month.toString().padLeft(2, '0')} às 22:30',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isAtrasado ? AppColors.error : AppColors.warning,
                          ),
                        ),
                        if (!isAtrasado) ...[
                          const SizedBox(height: 2),
                          Text(
                            _formatarTempoRestante(
                              widget.emprestimo.tempoRestante,
                            ),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
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
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
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
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: const TextStyle(
                  color: AppColors.textWhite,
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
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CÓD: ${equipamento?.codigo ?? '—'}',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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

  Widget _buildDevolucaoButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  QRCodeDevolucaoPage(emprestimo: widget.emprestimo),
            ),
          );
        },
        icon: const Icon(Icons.qr_code_2, size: 24),
        label: const Text(
          'Gerar QR para Devolução',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
        ),
      ),
    );
  }
}
