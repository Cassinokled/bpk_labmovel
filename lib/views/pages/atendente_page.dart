import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import 'registros_emprestimos_page.dart';

class AtendentePage extends StatelessWidget {
  final String? user;

  const AtendentePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    // Pegando tamanho da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        title: const Text(
          'Tela do Atendente',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 86, 22, 36),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05, // margem lateral proporcional
            vertical: screenHeight * 0.03, // margem vertical proporcional
          ),
          child: Column(
            children: [
              SizedBox(height: screenHeight * 0.05),

              // Logo centralizada e responsiva
              SizedBox(
                height: screenHeight * 0.15,
                child: const Center(child: AppLogo()),
              ),

              SizedBox(height: screenHeight * 0.05),

              // Título acima dos botões
              const Text(
                'Escolha o bloco:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Botões principais
              _buildBlocoButton(context, 'Bloco Verde Musgo', screenWidth),
              _buildBlocoButton(context, 'Bloco Vermelho', screenWidth),
              _buildBlocoButton(context, 'Charles Darwin', screenWidth),
              _buildBlocoButton(context, 'Kled', screenWidth),

              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }

  // Botão responsivo
  Widget _buildBlocoButton(
    BuildContext context,
    String bloco,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 86, 22, 36),
          minimumSize: Size(screenWidth * 0.9, 50), // largura proporcional
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrosEmprestimosPage(nomeBloco: bloco),
            ),
          );
        },

        child: Text(
          bloco,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
