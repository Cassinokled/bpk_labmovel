import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../widgets/app_logo.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_equipamentos_list.dart';
import '../widgets/home_action_buttons.dart';
import '../../providers/carrinho_emprestimo_provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),
          const Center(
            child: AppLogo(),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Consumer<CarrinhoEmprestimo>(
              builder: (context, carrinho, child) {
                if (!carrinho.temItens) {
                  return const HomeEmptyState();
                }

                return Column(
                  children: [
                    Expanded(
                      child: HomeEquipamentosList(carrinho: carrinho),
                    ),
                    HomeActionButtons(
                      onCancelar: () => _showCancelDialog(context, carrinho),
                      onConcluir: () => _showConcluirDialog(context, carrinho),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  void _showCancelDialog(BuildContext context, CarrinhoEmprestimo carrinho) {
    carrinho.limparCarrinho();
  }

  void _showConcluirDialog(BuildContext context, CarrinhoEmprestimo carrinho) {
    carrinho.limparCarrinho();
  }
}
