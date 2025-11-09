import 'package:flutter/material.dart';

class HomeActionButtons extends StatelessWidget {
  final VoidCallback onCancelar;
  final VoidCallback onConcluir;

  const HomeActionButtons({
    super.key,
    required this.onCancelar,
    required this.onConcluir,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.9;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onCancelar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEDEDED),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.5),
              ),
              child: const Text(
                'Cancelar empréstimo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: buttonWidth,
            child: ElevatedButton(
              onPressed: onConcluir,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 86, 22, 36),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: const Text(
                'Concluir empréstimo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
