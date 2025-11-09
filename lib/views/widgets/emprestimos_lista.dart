import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import '../../services/auth_service.dart';
import 'emprestimo_card.dart';
import '../pages/emprestimo_detalhes_page.dart';

class EmprestimosLista extends StatelessWidget {
  const EmprestimosLista({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthService().currentUser?.uid;

    if (userId == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<EmprestimoModel>>(
      stream: EmprestimoService().monitorarEmprestimosAtivos(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Erro ao carregar empréstimos',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        final emprestimos = snapshot.data ?? [];

        if (emprestimos.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0),
              child: Text(
                'Empréstimos Ativos',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: emprestimos.length,
              itemBuilder: (context, index) {
                final emprestimo = emprestimos[index];
                return EmprestimoCard(
                  emprestimo: emprestimo,
                  numero: emprestimos.length - index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmprestimoDetalhesPage(
                          emprestimo: emprestimo,
                          numero: emprestimos.length - index,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      'CARRINHO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(color: Colors.grey[400], thickness: 1),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
