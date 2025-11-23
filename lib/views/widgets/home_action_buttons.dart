import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onCancelar;
  final VoidCallback onConcluir;

  const HomeActionButtons({
    super.key,
    required this.onCancelar,
    required this.onConcluir,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.9;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onCancelar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cardBackground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                shadowColor: AppColors.shadowDark,
              ),
              child: const Text(
                'Cancelar empréstimo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onConcluir,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Concluir empréstimo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
