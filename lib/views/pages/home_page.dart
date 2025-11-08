import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emprestimo_model.dart';
import '../../providers/carrinho_emprestimo_provider.dart';
import '../../services/auth_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_equipamentos_list.dart';
import '../widgets/navbar.dart';
import '../widgets/test_qr_button.dart';
import 'qr_code_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        SizedBox(height: 60),
        Center(child: AppLogo()),
        SizedBox(height: 20),
        // botao de teste pra gerar qr code
        TestQRButton(),
        SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<CarrinhoEmprestimo>(
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
              onCancelar: () => _handleCancelar(carrinho),
              onConcluir: () => _handleConcluir(context, carrinho),
            ),
          ],
        );
      },
    );
  }

  void _handleCancelar(CarrinhoEmprestimo carrinho) {
    carrinho.limparCarrinho();
  }

  void _handleConcluir(BuildContext context, CarrinhoEmprestimo carrinho) {
    // obtem o id do usuario logado
    final userId = AuthService().currentUser?.uid;
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro: Usuário não identificado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // gera o emprestimo com userid e codigos de barras
    final emprestimo = carrinho.gerarEmprestimo(userId);
    _navegarParaQRCode(context, emprestimo, carrinho);
  }

  void _navegarParaQRCode(
    BuildContext context,
    EmprestimoModel emprestimo,
    CarrinhoEmprestimo carrinho,
  ) {
    // qr_code_page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRCodePage(emprestimo: emprestimo),
      ),
    ).then((_) {
      carrinho.limparCarrinho();
    });
  }
}
