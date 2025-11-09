import 'package:flutter/material.dart';
import '../../models/equipamento.dart';

class EquipamentoExcluirCard extends StatelessWidget {
  final Equipamento equipamento;
  final VoidCallback onDismissed;

  const EquipamentoExcluirCard({
    super.key,
    required this.equipamento,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(equipamento.codigo),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) => onDismissed(),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF561624),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 32,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Barra lateral (nao consegui fazer o design bom, ta branco faço depois dnv)
            Container(
              width: 16,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEDEDED),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            // Informações do equipamento
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      equipamento.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color.fromARGB(255, 86, 22, 36),
                        fontFamily: 'Avignon',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CÓD: ${equipamento.codigo}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 86, 22, 36),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Bloco: ${equipamento.bloco}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 86, 22, 36),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
