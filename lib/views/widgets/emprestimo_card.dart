import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../utils/app_colors.dart';

class EmprestimoCard extends StatelessWidget {
  final EmprestimoModel emprestimo;
  final int numero;
  final VoidCallback onTap;

  const EmprestimoCard({
    super.key,
    required this.emprestimo,
    required this.numero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numeroFormatado = numero.toString().padLeft(3, '0');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
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
                                  _formatarTituloEmprestimo(emprestimo, numeroFormatado),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${emprestimo.codigosEquipamentos.length} ${emprestimo.codigosEquipamentos.length == 1 ? 'equipamento' : 'equipamentos'}',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatarPrazo(emprestimo),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: _isAtrasado(emprestimo)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _isAtrasado(emprestimo)
                                  ? AppColors.error
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
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

  bool _isAtrasado(EmprestimoModel emprestimo) {
    if (emprestimo.isDevolvido || emprestimo.isRecusado) {
      return false;
    }
    return emprestimo.isAtrasadoAtual;
  }

  String _formatarPrazo(EmprestimoModel emprestimo) {
    if (emprestimo.isDevolvido) {
      if (emprestimo.atrasado) {
        return 'Devolvido ATRASADO em ${emprestimo.devolvidoEm!.day}/${emprestimo.devolvidoEm!.month}';
      } else {
        return 'Devolvido em ${emprestimo.devolvidoEm!.day}/${emprestimo.devolvidoEm!.month}';
      }
    }

    if (emprestimo.isRecusado) {
      return 'Recusado em ${emprestimo.confirmedoEm!.day}/${emprestimo.confirmedoEm!.month}';
    }

    if (_isAtrasado(emprestimo)) {
      return 'ATRASADO - Devolver até 22:30';
    }

    final tempoRestante = emprestimo.tempoRestante;

    if (tempoRestante.inHours > 0) {
      return 'Devolver até 22:30 (${tempoRestante.inHours}h restantes)';
    } else if (tempoRestante.inMinutes > 0) {
      return 'Devolver até 22:30 (${tempoRestante.inMinutes}min restantes)';
    } else {
      return 'Devolver até 22:30 (HOJE)';
    }
  }

  String _formatarTituloEmprestimo(EmprestimoModel emprestimo, String numeroFormatado) {
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
    return '$numeroFormatado - ${data.day} ${meses[data.month - 1]} ${data.year}';
  }

  Color _getStatusColor(EmprestimoModel emprestimo) {
    if (emprestimo.isPendente) {
      return AppColors.warning;
    } else if (emprestimo.isRecusado) {
      return AppColors.error;
    } else if (emprestimo.isDevolvido) {
      return AppColors.success;
    } else if (emprestimo.isAtivo) {
      return AppColors.primary;
    } else {
      return AppColors.grey;
    }
  }

  Widget _buildStatusBadge(EmprestimoModel emprestimo) {
    Color color;
    String text;

    if (emprestimo.isPendente) {
      color = AppColors.warning;
      text = 'Pendente';
    } else if (emprestimo.isRecusado) {
      color = AppColors.error;
      text = 'Recusado';
    } else if (emprestimo.isDevolvido) {
      color = AppColors.success;
      text = 'Devolvido';
    } else if (emprestimo.isAtivo) {
      color = AppColors.primary;
      text = 'Ativo';
    } else {
      color = AppColors.grey;
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
          color: AppColors.textWhite,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
