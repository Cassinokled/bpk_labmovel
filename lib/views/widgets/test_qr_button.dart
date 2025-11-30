import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_colors.dart';
import '../pages/qr_code_page.dart';

class TestQRButton extends StatelessWidget {
  const TestQRButton({super.key});

  void _handleTestQRCode(BuildContext context) {
    // Obtém o userId do usuário logado
    final userId = AuthService().currentUser?.uid ?? 'user_test_123';
    
    // Cria um empréstimo de teste com userId e lista de códigos
    final emprestimoTeste = EmprestimoModel(
      userId: userId,
      codigosEquipamentos: ['5815'],
    );

    // Navega para a página do QR Code
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodePage(emprestimo: emprestimoTeste),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleTestQRCode(context),
      icon: const Icon(Icons.qr_code),
      label: const Text('Teste: Gerar QR Code (5815)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
