import 'package:flutter/material.dart';
import '../../models/equipamento.dart';

class EquipamentoCard extends StatelessWidget {
  final Equipamento equipamento;
  final VoidCallback? onRemove;

  const EquipamentoCard({super.key, required this.equipamento, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8D5D8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromARGB(255, 86, 22, 36),
          width: 3,
        ),
      ),
      child: Row(
        children: [
          // Barra lateral
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 86, 22, 36),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  equipamento.displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 86, 22, 36),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'CÓD: ${equipamento.codigo}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                Text(
                  'Bloco: ${equipamento.bloco}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
