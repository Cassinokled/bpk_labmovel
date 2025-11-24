import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../pages/perfil_atendente_page.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/historico_atendente_page.dart';
import '../pages/relatorio_atendente_page.dart';
import '../pages/registros_emprestimos_page.dart';
import 'circular_close_button.dart';

class NavBarAtendente extends StatefulWidget {
  final int selectedIndex;
  final VoidCallback? onBackFromScanner;

  const NavBarAtendente({
    super.key,
    this.selectedIndex = 0,
    this.onBackFromScanner,
  });


  @override
  State<NavBarAtendente> createState() => _NavBarAtendenteState();
}

class _NavBarAtendenteState extends State<NavBarAtendente> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  final List<Map<String, String>> _navItems = [
    {
      'inactive': 'assets/pics/buttons/Vector.svg',
      'active': 'assets/pics/buttons/ativos/a_Vector.svg',
    },
    {
      'inactive': 'assets/pics/buttons/Vector-1.svg',
      'active': 'assets/pics/buttons/ativos/a_Vector-1.svg',
    },
    {
      'inactive': 'assets/pics/buttons/Adicionar.svg',
      'active': 'assets/pics/buttons/ativos/a_Adicionar.svg',
    },
    {
      'inactive': 'assets/pics/buttons/Group.svg',
      'active': 'assets/pics/buttons/ativos/a_Group.svg',
    },
    {
      'inactive': 'assets/pics/buttons/Vector-2.svg',
      'active': 'assets/pics/buttons/ativos/a_Vector-2.svg',
    },
  ];

  void _onItemTapped(int index) {
    // botao home (index 0) - navega para home do atendente
    if (index == 0) {
      if (widget.selectedIndex == 0) {
        return; // ja esta na home, nao faz nada
      }
      // pega o nome do bloco da rota atual se disponivel
      final route = ModalRoute.of(context);
      String? nomeBloco;
      if (route?.settings.arguments is Map) {
        nomeBloco = (route!.settings.arguments as Map)['nomeBloco'] as String?;
      }
      
      // se nao tiver o bloco tenta pegar do contexto navegando ate encontrar
      if (nomeBloco == null) {
        // volta ate encontrar a RegistrosEmprestimosPage ou primeira rota
        Navigator.of(context).popUntil((route) {
          // verifica se encontrou a pagina de registros
          if (route.settings.arguments is Map) {
            final args = route.settings.arguments as Map;
            if (args.containsKey('nomeBloco')) {
              nomeBloco = args['nomeBloco'] as String?;
              return true;
            }
          }
          // se eh a primeira rota ou pagina de registros para
          return route.isFirst || route.settings.name == '/registros';
        });
      } else {
        // se temos o bloco navega para home
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RegistrosEmprestimosPage(nomeBloco: nomeBloco!),
            settings: RouteSettings(arguments: {'nomeBloco': nomeBloco}),
          ),
          (route) => route.isFirst,
        );
      }
      return;
    }

    // botao "+" - scanner de qr code para atendentes
    if (index == 2) {
      // se ja esta na pagina do scanner/confirmacao volta home
      if (_selectedIndex == 2) {
        widget.onBackFromScanner?.call();
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const QRScannerPage()),
      );
      return;
    }

    // historico (index 1) - para atendentes
    if (index == 1) {
      if (widget.selectedIndex == 1) {
        return; // ja esta no historico
      }
      // navega para o historico
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoricoAtendentePage()),
      );
      return;
    }

    // relatorios (index 3) - para atendentes
    if (index == 3) {
      if (widget.selectedIndex == 3) {
        return; // ja esta nos relatorios
      }
      // navega para os relatorios
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RelatorioAtendentePage()),
      );
      return;
    }

    // perfil do atendente
    if (index == 4) {
      if (widget.selectedIndex == 4) {
        return; // ja esta no perfil
      }
      // navega para o perfil
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilAtendentePage()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 90,
      margin: EdgeInsets.only(bottom: 26 + bottomPadding),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final isAddButton = index == 2;
          final isSelected = isAddButton
              ? _selectedIndex == 2
              : _selectedIndex == index;
          final item = _navItems[index];
          final iconSize = isAddButton ? 62.0 : 25.0;

          // mostra o X para qr code
          if (index == 2 && _selectedIndex == 2) {
            return GestureDetector(
              onTap: () => _onItemTapped(index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CircularCloseButton(
                      size: 62,
                      backgroundColor: AppColors.primary,
                      iconColor: AppColors.textWhite,
                      iconSize: 28,
                      onPressed:
                          widget.onBackFromScanner ?? () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          }

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Colors.transparent,
                  child: SvgPicture.asset(
                    isSelected ? item['active']! : item['inactive']!,
                    width: iconSize,
                    height: iconSize,
                  ),
                ),
                if (isSelected && !isAddButton)
                  Container(
                    width: 15,
                    height: 2,
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 1,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
