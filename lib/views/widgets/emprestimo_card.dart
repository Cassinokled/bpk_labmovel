import 'package:flutter/material.dart';
import '../../models/emprestimo_model.dart';

class EmprestimoCard extends StatelessWidget {
  final EmprestimoModel emprestimo;
  final int numero;
  final VoidCallback onTap;

  const EmprestimoCard({
    super.key,
    required this.emprestimo,
    required this.numero,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numeroFormatado = numero.toString().padLeft(3, '0');
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Ícone de empréstimo
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 86, 22, 36).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                color: Color.fromARGB(255, 86, 22, 36),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // informacoes do emprestimo
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Empréstimo $numeroFormatado',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${emprestimo.codigosEquipamentos.length} ${emprestimo.codigosEquipamentos.length == 1 ? 'equipamento' : 'equipamentos'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: _isAtrasado(emprestimo) ? Colors.red : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatarPrazo(emprestimo),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _isAtrasado(emprestimo) ? FontWeight.bold : FontWeight.normal,
                          color: _isAtrasado(emprestimo) ? Colors.red : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Icon(
              Icons.chevron_right,
              color: Color.fromARGB(255, 86, 22, 36),
            ),
          ],
        ),
      ),
    );
  }

  bool _isAtrasado(EmprestimoModel emprestimo) {
    if (emprestimo.isDevolvido) {
      return emprestimo.atrasado;
    }
    return emprestimo.isAtrasadoAtual;
  }

  String _formatarPrazo(EmprestimoModel emprestimo) {
    if (_isAtrasado(emprestimo)) {
      return 'ATRASADO - Devolver até 22:30';
    }
    
    final tempoRestante = emprestimo.tempoRestante;
    
    if (tempoRestante.inHours > 0) {
      return 'Devolver até 22:30 (${tempoRestante.inHours}h restantes)';
    } else if (tempoRestante.inMinutes > 0) {
      return 'Devolver até 22:30 (${tempoRestante.inMinutes}min restantes)';
    } else {
      return 'Devolver até 22:30 (HOJE)';
    }
  }
}
