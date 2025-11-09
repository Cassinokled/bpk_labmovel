import 'package:flutter/material.dart';
import '../../providers/carrinho_emprestimo_provider.dart';
import 'equipamento_excluir_card.dart';

class HomeEquipamentosList extends StatelessWidget {
  final CarrinhoEmprestimo carrinho;

  const HomeEquipamentosList({
    super.key,
    required this.carrinho,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: carrinho.quantidade,
        itemBuilder: (context, index) {
          final equipamento = carrinho.equipamentos[index];
          return EquipamentoExcluirCard(
            equipamento: equipamento,
            onDismissed: () {
              carrinho.removerEquipamento(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${equipamento.displayName} removido'),
                  backgroundColor: const Color.fromARGB(255, 86, 22, 36),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
