import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/app_colors.dart';
import '../pages/perfil_page.dart';
import '../pages/barras_scanner_page.dart';
import '../pages/qr_scanner_page.dart';
import '../pages/historico_user_page.dart';
import 'circular_close_button.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;
  final bool isAtendente;
  final VoidCallback? onBackFromScanner;

  const NavBar({
    super.key,
    this.selectedIndex = 0,
    this.isAtendente = false,
    this.onBackFromScanner,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
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
    // botao home (index 0) - volta pra home removendo todas as rotas
    if (index == 0) {
      if (widget.selectedIndex == 0) {
        return; // ja esta na home
      }
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    // botao "+" - scanner (barras pra usuario, qr pra atendente)
    if (index == 2) {
      // se ja esta na pagina do scanner/confirmacao volta home
      if (_selectedIndex == 2) {
        widget.onBackFromScanner?.call();
        return;
      }

      // atendente: scanner de qr code
      // usuario: scanner de codigo de barras
      if (widget.isAtendente) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QRScannerPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BarrasScannerPage()),
        );
      }
      return;
    }

    // historico (index 1) - apenas para usuarios
    if (index == 1 && !widget.isAtendente) {
      if (widget.selectedIndex == 1) {
        return; // ja esta no historico
      }
      // volta pra home primeiro, depois vai pro historico
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HistoricoUserPage()),
      );
      return;
    }

    // perfil do usuario
    if (index == 4) {
      if (widget.selectedIndex == 4) {
        return; // ja esta no perfil
      }
      // volta pra home primeiro, depois vai pro perfil
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PerfilPage()),
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

          // MOSTRA O X PARA QR E CÓDIGO DE BARRAS
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
