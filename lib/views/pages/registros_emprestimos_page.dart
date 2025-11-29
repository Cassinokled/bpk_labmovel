import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import '../widgets/emprestimos_lista_bloco.dart';
import 'atendente_page.dart';

class RegistrosEmprestimosPage extends StatelessWidget {
  final String nomeBloco;

  const RegistrosEmprestimosPage({super.key, required this.nomeBloco});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const SizedBox(height: 60),
          
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

          const SizedBox(height: 16),
          const Divider(
            color: Color.fromARGB(255, 86, 22, 36),
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          const SizedBox(height: 8),

          Expanded(
            child: SingleChildScrollView(
              child: EmprestimosListaBloco(bloco: nomeBloco),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 0),
    );
  }
}
