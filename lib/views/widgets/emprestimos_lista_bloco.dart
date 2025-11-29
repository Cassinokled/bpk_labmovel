import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import 'emprestimo_card.dart';
import '../pages/emprestimo_detalhes_page.dart';

class EmprestimosListaBloco extends StatelessWidget {
  final String bloco;

  const EmprestimosListaBloco({super.key, required this.bloco});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EmprestimoModel>>(
      stream: EmprestimoService().monitorarEmprestimosAtivosPorBloco(bloco),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Erro ao carregar empréstimos',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final emprestimos = snapshot.data ?? [];

        if (emprestimos.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/pics/home-none.svg',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                    colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Parece que ainda não tem\nnenhum item aqui...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.primaryMedium,
                        fontFamily: 'Avignon',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
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
                  fontWeight: FontWeight.w400,
                  color: AppColors.primary,
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
                          isAtendente: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}