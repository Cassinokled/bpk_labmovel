import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import '../widgets/navbar.dart';

class RegistrosEmprestimosPage extends StatelessWidget {
  final String nomeBloco;

  const RegistrosEmprestimosPage ({super.key, required this.nomeBloco});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 86, 22, 36),
        title: Text(nomeBloco),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(child: AppLogo()),

          const SizedBox(height: 40),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Parece que ainda não há nenhum item aqui.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
