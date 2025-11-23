import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/equipamento.dart';

class EquipamentoCard extends StatelessWidget {
  final Equipamento equipamento;
  final VoidCallback? onRemove;

  const EquipamentoCard({super.key, required this.equipamento, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary,
          width: 3,
        ),
      ),
      child: Row(
        children: [
          // Barra lateral
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipamento.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CÓD: ${equipamento.codigo}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
                Text(
                  'Bloco: ${equipamento.bloco}',
                  style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
