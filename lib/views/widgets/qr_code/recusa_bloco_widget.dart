import 'package:flutter/material.dart';
import '../../../utils/app_colors.dart';
import '../../../models/emprestimo_model.dart';
import '../app_logo.dart';

// widget para exibir recusa de emprestimo por bloco
class RecusaBlocoWidget extends StatelessWidget {
  final EmprestimoModel? emprestimo;

  const RecusaBlocoWidget({super.key, this.emprestimo});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 60),
        const Center(child: AppLogo()),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cancel, color: AppColors.error, size: 80),
                const SizedBox(height: 20),
                const Text(
                  'Empréstimo não aprovado',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Não foi possível realizar o empréstimo.\n Os equipamentos pertencem a outro bloco!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Center(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
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