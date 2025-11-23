import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navbar_user.dart';
import '../widgets/app_logo.dart';
import '../../providers/carrinho_emprestimo_provider.dart';
import '../../services/equipamento_service.dart';
import '../../utils/app_colors.dart';

class EquipamentoConfPage extends StatefulWidget {
  final String bookCode;

  const EquipamentoConfPage({super.key, required this.bookCode});

  @override
  State<EquipamentoConfPage> createState() => _EquipamentoConfPageState();
}

class _EquipamentoConfPageState extends State<EquipamentoConfPage> {
  final EquipamentoService _equipamentoService = EquipamentoService();
  bool _isLoading = true;
  bool _isEmprestado = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _verificarDisponibilidade();
  }

  Future<void> _verificarDisponibilidade() async {
    try {
      final resultado = await _equipamentoService.verificarDisponibilidade(
        widget.bookCode,
      );

      setState(() {
        _isLoading = false;
        if (resultado['existe'] == false) {
          _errorMessage = resultado['mensagem'];
        } else if (resultado['disponivel'] == false) {
          _isEmprestado = true;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao verificar equipamento';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),

          const Center(child: AppLogo()),

          const Spacer(),

          // Informacoes do Equipamento
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26.0),
            child: _isLoading
                ? _buildLoading()
                : _errorMessage != null
                ? _buildError()
                : _isEmprestado
                ? _buildEmprestado()
                : _buildConfirmacao(),
          ),

          const Spacer(),
        ],
      ),
      bottomNavigationBar: const NavBarUser(selectedIndex: 2),
    );
  }

  Widget _buildLoading() {
    return const Column(
      children: [
        CircularProgressIndicator(color: AppColors.primary),
        SizedBox(height: 20),
        Text(
          'Verificando disponibilidade...',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Column(
      children: [
        const Icon(Icons.error_outline, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.red, height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmprestado() {
    return Column(
      children: [
        // Titulo com o codigo
        Text(
          'CÓD: ${widget.bookCode}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Avignon',
          ),
        ),
        const SizedBox(height: 20),
        const Icon(Icons.block, size: 64, color: Colors.red),
        const SizedBox(height: 20),
        const Text(
          'Este equipamento já está emprestado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Por favor, escolha outro equipamento.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 2,
            ),
            child: const Text(
              'OK',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmacao() {
    return Column(
      children: [
        // Titulo com o codigo
        Text(
          'CÓD: ${widget.bookCode}',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
            fontFamily: 'Avignon',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Deseja adicionar o equipamento referente a esse código?',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.black87, height: 1.4),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              final carrinho = Provider.of<CarrinhoEmprestimo>(
                context,
                listen: false,
              );

              // Verifica se o item já está no carrinho
              if (carrinho.contemCodigo(widget.bookCode)) {
                // Mostra mensagem que o item já foi adicionado
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Este equipamento já foi adicionado ao carrinho!',
                    ),
                    backgroundColor: AppColors.primary,
                    duration: Duration(seconds: 2),
                  ),
                );
                // Volta home
                Navigator.pop(context);
              } else {
                // Adiciona o equipamento ao carrinho
                await carrinho.adicionarEquipamento(widget.bookCode);

                // Volta home
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
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
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
