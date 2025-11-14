import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import 'atendente_page.dart';

class RegistrosEmprestimosPage extends StatelessWidget {
  final String nomeBloco;

  const RegistrosEmprestimosPage({super.key, required this.nomeBloco});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),
          
          // header seta e logo
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 86, 22, 36),
                  ),
                  tooltip: 'Voltar para seleção de bloco',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AtendentePage(),
                      ),
                    );
                  },
                ),
              ),
              const Expanded(child: Center(child: AppLogo())),
              const SizedBox(width: 56),
            ],
          ),

          const SizedBox(height: 40),
          
          // Nome do bloco
          Text(
            nomeBloco,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color.fromARGB(255, 86, 22, 36),
              fontFamily: 'Avignon',
            ),
          ),

          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/pics/home-none.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.contain,
                  ),                
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Parece que ainda não tem\nnenhum item aqui...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0x80561624),
                        fontFamily: 'Avignon',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  

                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 0),
    );
  }
}
