import 'package:flutter/material.dart';
import '../../../models/equipamento.dart';
import '../../../utils/app_colors.dart';

// widget reutilizavel pra exibir card de equipamento
class EquipamentoCardWidget extends StatelessWidget {
  final Equipamento? equipamento;
  final int numero;

  const EquipamentoCardWidget({
    super.key,
    required this.equipamento,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    final isLoaded = equipamento != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoaded ? AppColors.divider : AppColors.errorLight,
          width: 1.5,
        ),
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
          _buildNumberBadge(isLoaded),
          const SizedBox(width: 16),
          Expanded(
            child: isLoaded
                ? _buildEquipamentoInfo(equipamento!)
                : _buildEquipamentoNotFound(),
          ),
          _buildStatusIcon(isLoaded),
        ],
      ),
    );
  }

  Widget _buildNumberBadge(bool isLoaded) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isLoaded ? AppColors.primary : AppColors.error,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '$numero',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipamentoInfo(Equipamento equipamento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          equipamento.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.qr_code_2, 'Código: ${equipamento.codigo}'),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.location_on, 'Local: ${equipamento.bloco}'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.grey),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
      ],
    );
  }

  Widget _buildEquipamentoNotFound() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipamento não encontrado',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.error,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Verifique o código no banco de dados',
          style: TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(bool isLoaded) {
    return Icon(
      isLoaded ? Icons.check_circle : Icons.error,
      color: isLoaded ? AppColors.success : AppColors.error,
      size: 24,
    );
  }
}
