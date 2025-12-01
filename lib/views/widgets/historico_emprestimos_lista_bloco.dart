import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../../models/emprestimo_model.dart';
import '../../services/emprestimo_service.dart';
import 'emprestimo_card.dart';
import '../pages/emprestimo_detalhes_page.dart';

class HistoricoEmprestimosListaBloco extends StatelessWidget {
  final String bloco;
  final DateTime? startDate;
  final DateTime? endDate;

  const HistoricoEmprestimosListaBloco({
    super.key,
    required this.bloco,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<EmprestimoModel>>(
      stream: EmprestimoService().monitorarTodosEmprestimosPorBlocoSemFiltro(bloco),
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
                    'Erro ao carregar histórico',
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

        // filtra por data
        final emprestimosFiltrados = emprestimos.where((emprestimo) {
          final date = emprestimo.criadoEm;
          
          if (startDate != null || endDate != null) {
            if (startDate != null && date.isBefore(startDate!)) return false;
            if (endDate != null && date.isAfter(endDate!.add(const Duration(days: 1)))) return false;
            return true;
          }
          
          final hoje = DateTime.now();
          final inicioDia = DateTime(hoje.year, hoje.month, hoje.day);
          final fimDia = inicioDia.add(const Duration(days: 1));
          return date.isAfter(inicioDia.subtract(const Duration(seconds: 1))) &&
                 date.isBefore(fimDia);
        }).toList();

        if (emprestimosFiltrados.isEmpty) {
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
                      'Nenhum empréstimo\nregistrado ainda...',
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

        // agrupa emprestimos por status ('-')
        final ativos = emprestimosFiltrados.where((e) => e.isAtivo).toList();
        final devolvidos = emprestimosFiltrados.where((e) => e.isDevolvido).toList();
        final recusados = emprestimosFiltrados.where((e) => e.isRecusado).toList();

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (ativos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0, top: 16.0),
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
                  itemCount: ativos.length,
                  itemBuilder: (context, index) {
                    final emprestimo = ativos[index];
                    return EmprestimoCard(
                      emprestimo: emprestimo,
                      numero: ativos.length - index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmprestimoDetalhesPage(
                              emprestimo: emprestimo,
                              numero: ativos.length - index,
                              isAtendente: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              if (devolvidos.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0, top: 16.0),
                  child: Text(
                    'Empréstimos Devolvidos',
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
                  itemCount: devolvidos.length,
                  itemBuilder: (context, index) {
                    final emprestimo = devolvidos[index];
                    return EmprestimoCard(
                      emprestimo: emprestimo,
                      numero: devolvidos.length - index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmprestimoDetalhesPage(
                              emprestimo: emprestimo,
                              numero: devolvidos.length - index,
                              isAtendente: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
              if (recusados.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 4.0, top: 16.0),
                  child: Text(
                    'Empréstimos Recusados',
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
                  itemCount: recusados.length,
                  itemBuilder: (context, index) {
                    final emprestimo = recusados[index];
                    return EmprestimoCard(
                      emprestimo: emprestimo,
                      numero: recusados.length - index,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmprestimoDetalhesPage(
                              emprestimo: emprestimo,
                              numero: recusados.length - index,
                              isAtendente: true,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}