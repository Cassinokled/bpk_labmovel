import 'package:flutter/material.dart';
import '../../../models/equipamento.dart';

// widget reutilizavel pra exibir card de equipamento
class EquipamentoCardWidget extends StatelessWidget {
  final Equipamento? equipamento;
  final int numero;

  const EquipamentoCardWidget({
    super.key,
    required this.equipamento,
    required this.numero,
  });

  @override
  Widget build(BuildContext context) {
    final isLoaded = equipamento != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLoaded ? Colors.grey.shade200 : Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNumberBadge(isLoaded),
          const SizedBox(width: 16),
          Expanded(
            child: isLoaded
                ? _buildEquipamentoInfo(equipamento!)
                : _buildEquipamentoNotFound(),
          ),
          _buildStatusIcon(isLoaded),
        ],
      ),
    );
  }

  Widget _buildNumberBadge(bool isLoaded) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isLoaded 
            ? const Color.fromARGB(255, 86, 22, 36) 
            : Colors.red,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          '$numero',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEquipamentoInfo(Equipamento equipamento) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          equipamento.displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 86, 22, 36),
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoRow(Icons.qr_code_2, 'Código: ${equipamento.codigo}'),
        const SizedBox(height: 4),
        _buildInfoRow(Icons.location_on, 'Local: ${equipamento.bloco}'),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildEquipamentoNotFound() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Equipamento não encontrado',
          style: TextStyle(
            fontSize: 14,
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Verifique o código no banco de dados',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildStatusIcon(bool isLoaded) {
    return Icon(
      isLoaded ? Icons.check_circle : Icons.error,
      color: isLoaded ? Colors.green : Colors.red,
      size: 24,
    );
  }
}
