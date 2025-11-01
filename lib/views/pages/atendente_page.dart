import 'package:flutter/material.dart';
import '../widgets/app_logo.dart'; 
import '../widgets/navbar.dart';
import 'registros_emprestimos_page.dart';  

class AtendentePage extends StatelessWidget {
  const AtendentePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        title: const Text('Tela do Atendente'),
        backgroundColor: const Color.fromARGB(255, 86, 22, 36),
        centerTitle: true,
      ),

      // Corpo da tela
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // Logo centralizada
            const Center(child: AppLogo()),

            const SizedBox(height: 40),

            // Título acima dos botões
            const Text(
              'Escolha o bloco:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),

            const SizedBox(height: 20),

            // Botões principais
            _buildBlocoButton(context, 'Bloco Verde Musgo'),
            _buildBlocoButton(context, 'Bloco Vermelho'),
            _buildBlocoButton(context, 'Charles Darwin'),
            _buildBlocoButton(context, 'Kled'),

            const SizedBox(height: 60),
          ],
        ),
      ),

      // Barra inferior
      bottomNavigationBar: const NavBar(
        selectedIndex: 0, // ícone padrão selecionado
      ),
    );
  }

  // Widget auxiliar para criar cada botão
    Widget _buildBlocoButton(BuildContext context, String text) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 32),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegistrosEmprestimosPage(
                  nomeBloco: text,
                ),
              ),
            );
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: const Color.fromARGB(255, 86, 22, 36),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
