import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar_atendente.dart';
import '../widgets/historico_emprestimos_lista_bloco.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/bloco_service.dart';
import '../../models/user_model.dart';
import '../../models/bloco_model.dart';
import '../../providers/bloco_provider.dart';
import '../../utils/app_colors.dart';

class HistoricoAtendentePage extends StatefulWidget {
  const HistoricoAtendentePage({super.key});

  @override
  State<HistoricoAtendentePage> createState() => _HistoricoAtendentePageState();
}

class _HistoricoAtendentePageState extends State<HistoricoAtendentePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final BlocoService _blocoService = BlocoService();
  UserModel? _userData;
  bool _isLoading = true;
  List<Bloco> _blocos = [];
  String? _selectedBloco;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _userService.getUser(user.uid);
        final blocos = await _blocoService.buscarTodos();
        final blocoProvider = Provider.of<BlocoProvider>(context, listen: false);
        setState(() {
          _userData = userData;
          _blocos = blocos;
          _selectedBloco = blocoProvider.blocoSelecionado?.nome ?? (_blocos.isNotEmpty ? _blocos.first.nome : null);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearDateFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final blocoProvider = Provider.of<BlocoProvider>(context);
    final isAdmin = _userData?.isAdmin ?? false;

    if (isAdmin && _selectedBloco == null && _blocos.isNotEmpty) {
      _selectedBloco = blocoProvider.blocoSelecionado?.nome ?? _blocos.first.nome;
    }

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
              child: Text(
                'Histórico de Atendimentos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // filtros para admin
            if (isAdmin) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _selectedBloco,
                            decoration: const InputDecoration(
                              labelText: 'Bloco',
                              border: OutlineInputBorder(),
                            ),
                            items: _blocos.map((bloco) {
                              return DropdownMenuItem<String>(
                                value: bloco.nome,
                                child: Text(bloco.nome),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBloco = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectStartDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _startDate != null
                                  ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                                  : 'Data Inicial',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _selectEndDate,
                            icon: const Icon(Icons.calendar_today),
                            label: Text(
                              _endDate != null
                                  ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                                  : 'Data Final',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.white,
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_startDate != null || _endDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _clearDateFilters,
                          icon: const Icon(Icons.clear),
                          label: const Text('Limpar Filtros'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // conteudo
            Expanded(
              child: () {
                final blocoParaUsar = isAdmin ? _selectedBloco : Provider.of<BlocoProvider>(context).blocoSelecionado?.nome;
                return blocoParaUsar != null
                    ? HistoricoEmprestimosListaBloco(
                        bloco: blocoParaUsar,
                        startDate: isAdmin ? _startDate : null,
                        endDate: isAdmin ? _endDate : null,
                      )
                    : const Center(
                        child: Text(
                          'Nenhum bloco selecionado',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      );
              }(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBarAtendente(selectedIndex: 1),
    );
  }
}
