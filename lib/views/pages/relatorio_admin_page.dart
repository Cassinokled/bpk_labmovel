import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/emprestimo_service.dart';
import '../../models/emprestimo_model.dart';
import '../../services/bloco_service.dart';
import '../../models/bloco_model.dart';
import '../widgets/relatorio_card_widget.dart';
import '../../services/relatorio_data_service.dart';
import '../../services/relatorio_pdf_service.dart';

class RelatorioAdminPage extends StatefulWidget {
  const RelatorioAdminPage({super.key});

  @override
  State<RelatorioAdminPage> createState() => _RelatorioAdminPageState();
}

class _RelatorioAdminPageState extends State<RelatorioAdminPage> {
  final EmprestimoService _emprestimoService = EmprestimoService();
  final BlocoService _blocoService = BlocoService();
  final RelatorioDataService _relatorioDataService = RelatorioDataService();
  final RelatorioPdfService _relatorioPdfService = RelatorioPdfService();

  List<Bloco> _blocos = [];
  String? _blocoSelecionado;
  DateTime? _dataSelecionada;
  
  // seletor de periodo
  String _tipoPeriodo = 'Dia';
  int? _mesSelecionado;
  int? _semestreSelecionado;
  int? _anoSelecionado;

  // dados do relatorio
  int _emprestimosRealizados = 0;
  int _emprestimosDevolvidos = 0;
  int _emprestimosAtrasadosDevolvidos = 0;
  int _emprestimosAtrasados = 0;
  List<EmprestimoModel> _emprestimosRealizadosLista = [];
  List<EmprestimoModel> _emprestimosDevolvidosLista = [];
  List<EmprestimoModel> _emprestimosAtrasadosDevolvidosLista = [];
  List<EmprestimoModel> _emprestimosAtrasadosLista = [];
  bool _isLoading = true;

  // cache para nao ter busca duplicada no banco
  String? _ultimaBuscaChave;

  @override
  void initState() {
    super.initState();
    _loadBlocos();
  }

  Future<void> _loadBlocos() async {
    try {
      final blocos = await _blocoService.buscarTodos();
      setState(() {
        _blocos = blocos;
        _blocoSelecionado = 'Todos';
        _dataSelecionada = DateTime.now();
        _isLoading = false;
      });
      if (_blocoSelecionado != null) {
        _carregarRelatorio();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _getTituloRelatorio() {
    switch (_tipoPeriodo) {
      case 'Dia':
        if (_dataSelecionada == null) return 'Selecione um período';
        return 'Relatório de ${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}';

      case 'Mês':
        if (_mesSelecionado == null || _anoSelecionado == null) return 'Selecione um período';
        final nomesMeses = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
        return 'Relatório de ${nomesMeses[_mesSelecionado! - 1]} de $_anoSelecionado';

      case 'Semestre':
        if (_semestreSelecionado == null || _anoSelecionado == null) return 'Selecione um período';
        return 'Relatório do $_semestreSelecionadoº Semestre de $_anoSelecionado';

      case 'Ano':
        if (_anoSelecionado == null) return 'Selecione um período';
        return 'Relatório do Ano $_anoSelecionado';

      default:
        return 'Relatório';
    }
  }

  (DateTime, DateTime)? _calcularIntervaloData() {
    switch (_tipoPeriodo) {
      case 'Dia':
        if (_dataSelecionada == null) return null;
        final inicio = DateTime(_dataSelecionada!.year, _dataSelecionada!.month, _dataSelecionada!.day);
        final fim = inicio.add(const Duration(days: 1));
        return (inicio, fim);

      case 'Mês':
        if (_mesSelecionado == null || _anoSelecionado == null) return null;
        final inicio = DateTime(_anoSelecionado!, _mesSelecionado!, 1);
        final fim = DateTime(_anoSelecionado!, _mesSelecionado! + 1, 1);
        return (inicio, fim);

      case 'Semestre':
        if (_semestreSelecionado == null || _anoSelecionado == null) return null;
        final inicio = _semestreSelecionado == 1
            ? DateTime(_anoSelecionado!, 1, 1)
            : DateTime(_anoSelecionado!, 7, 1);
        final fim = _semestreSelecionado == 1
            ? DateTime(_anoSelecionado!, 7, 1)
            : DateTime(_anoSelecionado! + 1, 1, 1);
        return (inicio, fim);

      case 'Ano':
        if (_anoSelecionado == null) return null;
        final inicio = DateTime(_anoSelecionado!, 1, 1);
        final fim = DateTime(_anoSelecionado! + 1, 1, 1);
        return (inicio, fim);

      default:
        return null;
    }
  }

  Future<void> _carregarRelatorio() async {
    if (_blocoSelecionado == null) return;

    final intervalo = _calcularIntervaloData();
    if (intervalo == null) return;

    final (dataInicio, dataFim) = intervalo;
    final chaveBusca = '$_blocoSelecionado-$_tipoPeriodo-${dataInicio.millisecondsSinceEpoch}-${dataFim.millisecondsSinceEpoch}';
    
    if (chaveBusca == _ultimaBuscaChave) return;

    setState(() => _isLoading = true);

    try {
      final realizadosLista = await _emprestimoService.listarEmprestimosRealizadosPorIntervalo(_blocoSelecionado!, dataInicio, dataFim);
      final devolvidosLista = await _emprestimoService.listarEmprestimosDevolvidosPorIntervalo(_blocoSelecionado!, dataInicio, dataFim);
      final atrasadosDevolvidosLista = await _emprestimoService.listarEmprestimosAtrasadosDevolvidosPorIntervalo(_blocoSelecionado!, dataInicio, dataFim);
      
      final atrasadosLista = await _emprestimoService.listarEmprestimosAtrasadosAtivosNaData(_blocoSelecionado!, dataFim.subtract(const Duration(days: 1)));

      setState(() {
        _emprestimosRealizadosLista = realizadosLista;
        _emprestimosDevolvidosLista = devolvidosLista;
        _emprestimosAtrasadosDevolvidosLista = atrasadosDevolvidosLista;
        _emprestimosAtrasadosLista = atrasadosLista;
        _emprestimosRealizados = realizadosLista.length;
        _emprestimosDevolvidos = devolvidosLista.length;
        _emprestimosAtrasadosDevolvidos = atrasadosDevolvidosLista.length;
        _emprestimosAtrasados = atrasadosLista.length;
        _ultimaBuscaChave = chaveBusca; // Atualizar cache
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

  Widget _buildSeletorPeriodo() {
    switch (_tipoPeriodo) {
      case 'Dia':
        return ElevatedButton.icon(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _dataSelecionada ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _dataSelecionada = picked;
              });
              _carregarRelatorio();
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(
            _dataSelecionada != null
                ? '${_dataSelecionada!.day}/${_dataSelecionada!.month}/${_dataSelecionada!.year}'
                : 'Selecionar',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            minimumSize: const Size(double.infinity, 48),
          ),
        );

      case 'Mês':
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _mesSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Mês',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(12, (index) {
                  final mes = index + 1;
                  final nomesMeses = ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'];
                  return DropdownMenuItem(
                    value: mes,
                    child: Text(nomesMeses[index]),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _mesSelecionado = value;
                  });
                  _carregarRelatorio();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _anoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(10, (index) {
                  final ano = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: ano,
                    child: Text(ano.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _anoSelecionado = value;
                  });
                  _carregarRelatorio();
                },
              ),
            ),
          ],
        );

      case 'Semestre':
        return Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _semestreSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Semestre',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1º')),
                  DropdownMenuItem(value: 2, child: Text('2º')),
                ],
                onChanged: (value) {
                  setState(() {
                    _semestreSelecionado = value;
                  });
                  _carregarRelatorio();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _anoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  border: OutlineInputBorder(),
                ),
                items: List.generate(10, (index) {
                  final ano = DateTime.now().year - index;
                  return DropdownMenuItem(
                    value: ano,
                    child: Text(ano.toString()),
                  );
                }),
                onChanged: (value) {
                  setState(() {
                    _anoSelecionado = value;
                  });
                  _carregarRelatorio();
                },
              ),
            ),
          ],
        );

      case 'Ano':
        return DropdownButtonFormField<int>(
          value: _anoSelecionado,
          decoration: const InputDecoration(
            labelText: 'Selecionar Ano',
            border: OutlineInputBorder(),
          ),
          items: List.generate(10, (index) {
            final ano = DateTime.now().year - index;
            return DropdownMenuItem(
              value: ano,
              child: Text(ano.toString()),
            );
          }),
          onChanged: (value) {
            setState(() {
              _anoSelecionado = value;
            });
            _carregarRelatorio();
          },
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _blocoSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Selecionar Bloco',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'Todos',
                    child: Text('Todos os Blocos'),
                  ),
                  ..._blocos.map((bloco) {
                    return DropdownMenuItem<String>(
                      value: bloco.nome,
                      child: Text(bloco.nome.split(' - ').first),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _blocoSelecionado = value;
                  });
                  _carregarRelatorio();
                },
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _tipoPeriodo,
                      decoration: const InputDecoration(
                        labelText: 'Período',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Dia', child: Text('Dia')),
                        DropdownMenuItem(value: 'Mês', child: Text('Mês')),
                        DropdownMenuItem(value: 'Semestre', child: Text('Semestre')),
                        DropdownMenuItem(value: 'Ano', child: Text('Ano')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _tipoPeriodo = value!;
                          if (_tipoPeriodo == 'Mês' && _mesSelecionado == null) {
                            _mesSelecionado = DateTime.now().month;
                            _anoSelecionado = DateTime.now().year;
                          } else if (_tipoPeriodo == 'Semestre' && _semestreSelecionado == null) {
                            _semestreSelecionado = DateTime.now().month <= 6 ? 1 : 2;
                            _anoSelecionado = DateTime.now().year;
                          } else if (_tipoPeriodo == 'Ano' && _anoSelecionado == null) {
                            _anoSelecionado = DateTime.now().year;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildSeletorPeriodo(),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        Expanded(
          child: _isLoading
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Carregando relatório...',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : _blocoSelecionado == null
                  ? const Center(
                      child: Text('Selecione um bloco para ver o relatório'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            _getTituloRelatorio(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 16),

                          RelatorioCardWidget(
                            titulo: 'Empréstimos Realizados',
                            valor: _emprestimosRealizados,
                            icone: Icons.assignment_turned_in,
                            cor: AppColors.success,
                          ),

                          const SizedBox(height: 16),

                          RelatorioCardWidget(
                            titulo: 'Empréstimos Devolvidos',
                            valor: _emprestimosDevolvidos,
                            icone: Icons.assignment_return,
                            cor: AppColors.info,
                          ),

                          const SizedBox(height: 16),

                          RelatorioCardWidget(
                            titulo: 'Empréstimos Atrasados Devolvidos',
                            valor: _emprestimosAtrasadosDevolvidos,
                            icone: Icons.warning_amber,
                            cor: AppColors.warning,
                          ),

                          const SizedBox(height: 16),

                          RelatorioCardWidget(
                            titulo: 'Empréstimos Atrasados Ativos',
                            valor: _emprestimosAtrasados,
                            icone: Icons.error,
                            cor: AppColors.error,
                          ),

                          const SizedBox(height: 24),

                          // Botão gerar relatório
                          ElevatedButton.icon(
                            onPressed: _gerarRelatorio,
                            icon: const Icon(Icons.print),
                            label: const Text('Gerar Relatório PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textWhite,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  void _gerarRelatorio() async {
    if (_blocoSelecionado == null) return;

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

    Bloco? blocoParaPdf;
    if (_blocoSelecionado == 'Todos') {
      blocoParaPdf = Bloco(id: 'todos', nome: 'Todos os Blocos');
    } else {
      blocoParaPdf = _blocos.firstWhere((b) => b.nome == _blocoSelecionado);
    }

    await _relatorioPdfService.gerarRelatorio(
      bloco: blocoParaPdf,
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
      tituloRelatorio: _getTituloRelatorio(),
      tipoPeriodo: _tipoPeriodo,
    );
  }
}