import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import '../../providers/bloco_provider.dart';
import '../../services/emprestimo_service.dart';
import '../../models/emprestimo_model.dart';
import 'package:provider/provider.dart';
import '../widgets/relatorio_card_widget.dart';
import '../../services/relatorio_data_service.dart';
import '../../services/relatorio_pdf_service.dart';

class RelatorioAtendentePage extends StatefulWidget {
  const RelatorioAtendentePage({super.key});

  @override
  State<RelatorioAtendentePage> createState() => _RelatorioAtendentePageState();
}

class _RelatorioAtendentePageState extends State<RelatorioAtendentePage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  final RelatorioDataService _relatorioDataService = RelatorioDataService();
  final RelatorioPdfService _relatorioPdfService = RelatorioPdfService();
  int _emprestimosRealizados = 0;
  int _emprestimosDevolvidos = 0;
  int _emprestimosAtrasadosDevolvidos = 0;
  int _emprestimosAtrasados = 0;
  List<EmprestimoModel> _emprestimosRealizadosLista = [];
  List<EmprestimoModel> _emprestimosDevolvidosLista = [];
  List<EmprestimoModel> _emprestimosAtrasadosDevolvidosLista = [];
  List<EmprestimoModel> _emprestimosAtrasadosLista = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarRelatorio();
  }

  Future<void> _carregarRelatorio() async {
    final blocoProvider = context.read<BlocoProvider>();
    final bloco = blocoProvider.blocoSelecionado?.nome;

    if (bloco == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final realizadosLista = await _emprestimoService.listarEmprestimosRealizadosHoje(bloco);
      final devolvidosLista = await _emprestimoService.listarEmprestimosDevolvidosHoje(bloco);
      final atrasadosDevolvidosLista = await _emprestimoService.listarEmprestimosAtrasadosDevolvidosHoje(bloco);
      final atrasadosLista = await _emprestimoService.listarEmprestimosAtrasadosAtivos(bloco);

      setState(() {
        _emprestimosRealizadosLista = realizadosLista;
        _emprestimosDevolvidosLista = devolvidosLista;
        _emprestimosAtrasadosDevolvidosLista = atrasadosDevolvidosLista;
        _emprestimosAtrasadosLista = atrasadosLista;
        _emprestimosRealizados = realizadosLista.length;
        _emprestimosDevolvidos = devolvidosLista.length;
        _emprestimosAtrasadosDevolvidos = atrasadosDevolvidosLista.length;
        _emprestimosAtrasados = atrasadosLista.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar relatório: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final blocoProvider = context.watch<BlocoProvider>();
    final bloco = blocoProvider.blocoSelecionado;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: AppLogo()),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Relatório Diário',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ),

            const SizedBox(height: 16),

            if (bloco != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Bloco: ${bloco.nome}',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // conteudo
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : bloco == null
                      ? const Center(
                          child: Text('Selecione um bloco para ver o relatório'),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              // card emprestimos realizados
                              RelatorioCardWidget(
                                titulo: 'Empréstimos Realizados',
                                valor: _emprestimosRealizados,
                                icone: Icons.assignment_turned_in,
                                cor: AppColors.success,
                              ),

                              const SizedBox(height: 16),

                              // card devolvidos
                              RelatorioCardWidget(
                                titulo: 'Empréstimos Devolvidos',
                                valor: _emprestimosDevolvidos,
                                icone: Icons.assignment_return,
                                cor: AppColors.info,
                              ),

                              const SizedBox(height: 16),

                              // card atrasados devolvidos hoje
                              RelatorioCardWidget(
                                titulo: 'Empréstimos Atrasados Devolvidos Hoje',
                                valor: _emprestimosAtrasadosDevolvidos,
                                icone: Icons.warning_amber,
                                cor: AppColors.warning,
                              ),

                              const SizedBox(height: 16),

                              // aviso se houver atrasados
                              if (_emprestimosAtrasados > 0)
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.errorLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning, color: AppColors.error),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Há $_emprestimosAtrasados empréstimos atrasados. Considere notificar os superiores.',
                                          style: const TextStyle(color: AppColors.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
            ),

            // botao gerar relatorio em pdf
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton.icon(
                onPressed: _gerarRelatorio,
                icon: const Icon(Icons.print),
                label: const Text('Gerar Relatório'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 3),
    );
  }



/// faz os tratamentos para a geracao do pdf

  void _gerarRelatorio() async {
    final bloco = context.read<BlocoProvider>().blocoSelecionado;

    Map<String, String> userNames = {};
    Map<String, String> equipamentosFormatted = {};

    Set<String> allUserIds = {};
    Set<String> allEquipamentoCodigos = {};

    for (var lista in [_emprestimosRealizadosLista, _emprestimosDevolvidosLista, _emprestimosAtrasadosDevolvidosLista, _emprestimosAtrasadosLista]) {
      for (var emprestimo in lista) {
        allUserIds.add(emprestimo.userId);
        allEquipamentoCodigos.addAll(emprestimo.codigosEquipamentos);
      }
    }

    userNames = await _relatorioDataService.getUserNames(allUserIds);

    equipamentosFormatted = await _relatorioDataService.getEquipamentosFormattedMap(allEquipamentoCodigos);

    // gera o pdf aqui
    await _relatorioPdfService.gerarRelatorio(
      bloco: bloco,
      emprestimosRealizados: _emprestimosRealizados,
      emprestimosDevolvidos: _emprestimosDevolvidos,
      emprestimosAtrasadosDevolvidos: _emprestimosAtrasadosDevolvidos,
      emprestimosAtrasados: _emprestimosAtrasados,
      emprestimosRealizadosLista: _emprestimosRealizadosLista,
      emprestimosDevolvidosLista: _emprestimosDevolvidosLista,
      emprestimosAtrasadosDevolvidosLista: _emprestimosAtrasadosDevolvidosLista,
      emprestimosAtrasadosLista: _emprestimosAtrasadosLista,
      userNames: userNames,
      equipamentosFormatted: equipamentosFormatted,
    );
  }
}
