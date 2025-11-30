import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/bloco_provider.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import '../widgets/historico_emprestimos_lista_bloco.dart';

class HistoricoAtendentePage extends StatelessWidget {
  const HistoricoAtendentePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blocoProvider = Provider.of<BlocoProvider>(context);
    final blocoSelecionado = blocoProvider.blocoSelecionado;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // header
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLogo()),
            ),

            // titulo
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Center(
                child: Text(
                  'Histórico de \nAtendimentos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 86, 22, 36),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // conteudo
            Expanded(
              child: blocoSelecionado != null
                  ? HistoricoEmprestimosListaBloco(bloco: blocoSelecionado.nome)
                  : const Center(
                      child: Text(
                        'Nenhum bloco selecionado',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 1),
    );
  }
}
