import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar.dart';
import '../widgets/app_logo.dart';
import '../../providers/carrinho_emprestimo_provider.dart';

class EquipamentoConfPage extends StatelessWidget {
  final String bookCode;

  const EquipamentoConfPage({
    super.key,
    required this.bookCode,
  });

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

          const Spacer(),

          // Informacoes do Equipamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: Column(
              children: [
                // Titulo com o codigo
                Text(
                  'CÓD: $bookCode',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 86, 22, 36),
                    fontFamily: 'Avignon',
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Deseja adicionar o equipamento referente a esse código?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final carrinho = Provider.of<CarrinhoEmprestimo>(context, listen: false);
                      
                      // Verifica se o item já está no carrinho
                      if (carrinho.contemCodigo(bookCode)) {
                        // Mostra mensagem que o item já foi adicionado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Este equipamento já foi adicionado ao carrinho!'),
                            backgroundColor: Color.fromARGB(255, 86, 22, 36),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        // Volta home
                        Navigator.pop(context);
                      } else {
                        // Adiciona o equipamento ao carrinho
                        carrinho.adicionarEquipamento(bookCode);
                        
                        // Volta home
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 86, 22, 36),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Sim, adicionar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Não, remover
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(1.0),
                    ),
                    child: const Text(
                      'Não, remover',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Color.fromARGB(255, 86, 22, 36),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),
        ],
      ),
      bottomNavigationBar: const NavBar(selectedIndex: 2),
    );
  }
}
