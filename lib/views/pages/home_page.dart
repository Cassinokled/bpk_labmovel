import 'package:flutter/material.dart';
import 'qr_code_page.dart';
import '../widgets/circular_close_button.dart';
import '../widgets/app_logo.dart';
import 'login_page.dart'; // Import correto, mesma pasta

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),

          const Center(
            child: AppLogo(),
          ),

          const Spacer(),

          // Botão principal: Concluir empréstimo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QRCodePage(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 86, 22, 36),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Concluir empréstimo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botão de voltar para o login
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(), // correto, sem const
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color.fromARGB(255, 86, 22, 36),
                side: const BorderSide(
                  color: Color.fromARGB(255, 86, 22, 36),
                  width: 2,
                ),
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Voltar para o Login',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Botão circular (fechar)
          Center(
            child: CircularCloseButton(
              backgroundColor: const Color.fromARGB(255, 86, 22, 36),
              onPressed: () {},
            ),
          ),

          const SizedBox(height: 26),
        ],
      ),
    );
  }
}
