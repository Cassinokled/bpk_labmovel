import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../models/equipamento.dart';

class EquipamentoExcluirCard extends StatelessWidget {
  final Equipamento equipamento;
  final VoidCallback onDismissed;

  const EquipamentoExcluirCard({
    super.key,
    required this.equipamento,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(equipamento.codigo),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.delete, color: AppColors.textWhite, size: 32),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryLight,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Barra lateral (nao consegui fazer o design bom, ta branco faço depois dnv)
            Container(
              width: 16,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Informações do equipamento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipamento.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontFamily: 'Avignon',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CÓD: ${equipamento.codigo}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bloco: ${equipamento.bloco}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.primary,
                      ),
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
}
