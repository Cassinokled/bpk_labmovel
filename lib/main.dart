import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'views/pages/home_page.dart';
import 'providers/carrinho_emprestimo_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CarrinhoEmprestimo(),
      child: MaterialApp(
        title: 'LabMovel',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          fontFamily: 'Avignon',
        ),
        home: const HomePage(),
      ),
    );
  }
}
