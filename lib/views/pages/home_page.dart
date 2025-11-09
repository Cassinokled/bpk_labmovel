import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/emprestimo_model.dart';
import '../../models/user_model.dart';
import '../../providers/carrinho_emprestimo_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/emprestimos_lista.dart';
import '../widgets/home_action_buttons.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/home_equipamentos_list.dart';
import '../widgets/navbar.dart';
import '../widgets/test_qr_button.dart';
import 'qr_code_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = AuthService().currentUser;
      if (user != null) {
        final userData = await _userService.getUser(user.uid);
        setState(() {
          _currentUser = userData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  bool get _canGoBackToSelection {
    // verifica se o usuario eh atendente e user ao mesmo tempo
    return _currentUser?.isAtendente == true && 
           _currentUser?.tiposUsuario.contains('user') == true;
  }

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
    return Column(
      children: [
        const SizedBox(height: 60),
        Row(
          children: [
            if (_canGoBackToSelection)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color.fromARGB(255, 86, 22, 36),
                  ),
                  tooltip: 'Voltar para seleção',
                  onPressed: () => Navigator.pop(context),
                ),
              )
            else
              const SizedBox(width: 56),
            const Expanded(
              child: Center(child: AppLogo()),
            ),
            const SizedBox(width: 56),
          ],
        ),
        const SizedBox(height: 20),
        // botao de teste pra gerar qr code
        const TestQRButton(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Consumer<CarrinhoEmprestimo>(
      builder: (context, carrinho, child) {
        final temItensNoCarrinho = carrinho.temItens;

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const EmprestimosLista(),
                    
                    if (temItensNoCarrinho) ...[
                      const SizedBox(height: 16),
                      HomeEquipamentosList(carrinho: carrinho),
                    ] else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: HomeEmptyState(),
                      ),
                  ],
                ),
              ),
            ),
            
            if (temItensNoCarrinho)
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
