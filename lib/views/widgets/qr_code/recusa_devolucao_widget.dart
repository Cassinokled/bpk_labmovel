import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/emprestimo_model.dart';

// widget para exibir recusa de devolucao por bloco
class RecusaDevolucaoWidget extends StatelessWidget {
  final VoidCallback? onOk;
  final EmprestimoModel? emprestimo;

  const RecusaDevolucaoWidget({super.key, this.onOk, this.emprestimo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel, color: AppColors.error, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Devolução não aprovada',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Não foi possível realizar a devolução.\n Os equipamentos pertencem a outro bloco!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Center(
            child: ElevatedButton(
              onPressed: () {
                onOk?.call();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
              ),
              child: const Text(
                'OK',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}