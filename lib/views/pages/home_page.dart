import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emprestimo_model.dart';
import '../../providers/carrinho_emprestimo_provider.dart';
import '../widgets/app_logo.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_equipamentos_list.dart';
import '../widgets/navbar.dart';
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
    final emprestimo = _criarEmprestimo(carrinho);
    _navegarParaQRCode(context, emprestimo, carrinho);
  }

  EmprestimoModel _criarEmprestimo(CarrinhoEmprestimo carrinho) {
    // Emprestimo com dados do carrinho
    final now = DateTime.now();
    
    return EmprestimoModel(
      ra: '000001', // depois tem que fazer para obter o ra do usuário logado
      nome: 'user_name', // depois tem que fazer para obter o nome do usuário logado
      itens: _converterEquipamentosParaItens(carrinho.equipamentos),
      data: _formatarData(now),
      horario: _formatarHorario(now),
    );
  }

  List<ItemEmprestimo> _converterEquipamentosParaItens(List equipamentos) {
    return equipamentos
        .map((e) => ItemEmprestimo(
              cod: e.codigo,
              descricao: e.nome,
            ))
        .toList();
  }

  String _formatarData(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.year}';
  }

  String _formatarHorario(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
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
