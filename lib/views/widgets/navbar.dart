import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/perfil_page.dart';
import '../pages/barras_scanner_page.dart';
import '../pages/qr_scanner_page.dart';

class NavBar extends StatefulWidget {
  final int selectedIndex;
  final bool isAtendente;
  
  const NavBar({
    super.key,
    this.selectedIndex = 0,
    this.isAtendente = false,
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
    // botao "+" - scanner (barras pra usuario, qr pra atendente)
    if (index == 2) {
      // se ja esta na pagina do scanner/confirmacao voltahome
      if (_selectedIndex == 2) {
        Navigator.pop(context);
      } else {
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
      }
      return;
    }
    
    // perfil do usuario
    if (index == 4) {
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
    return Container(
      height: 90,
      margin: const EdgeInsets.only(bottom: 26),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_navItems.length, (index) {
          final isAddButton = index == 2;
          final isSelected = isAddButton ? _selectedIndex == 2 : _selectedIndex == index;
          final item = _navItems[index];
          
          final iconSize = isAddButton ? 62.0 : 25.0;

          return GestureDetector(
            onTap: () => _onItemTapped(index),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.transparent,
              child: SvgPicture.asset(
                isSelected ? item['active']! : item['inactive']!,
                width: iconSize,
                height: iconSize,
              ),
            ),
          );
        }),
      ),
    );
  }
}
