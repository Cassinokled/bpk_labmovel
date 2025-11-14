import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';
import 'registros_emprestimos_page.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class AtendentePage extends StatefulWidget {
  final String? user;

  const AtendentePage({super.key, this.user});

  @override
  State<AtendentePage> createState() => _AtendentePageState();
}

class _AtendentePageState extends State<AtendentePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  UserModel? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        final userData = await _userService.getUser(user.uid);
        setState(() {
          _userData = userData;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pegando tamanho da tela
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // verifica se mostra o botao de voltar ou nao
    final bool showBackButton = !_isLoading && _userData != null && _userData!.isUser && _userData!.isAtendente;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Column(
        children: [
          const SizedBox(height: 60),
          
          // header com seta de voltar e logo
          Row(
            children: [
              if (showBackButton)
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color.fromARGB(255, 86, 22, 36),
                    ),
                    tooltip: 'Voltar',
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                )
              else
                const SizedBox(width: 56), 
              const Expanded(child: Center(child: AppLogo())),
              const SizedBox(width: 56),
            ],
          ),

          const SizedBox(height: 40),

          // Conteúdo scrollável
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                ),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.08),
                    
                    const Text(
                      'Escolha o bloco que\nestara atendendo',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0x80561624),
                        fontFamily: 'Avignon',
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    _buildBlocoButton(context, 'Bloco I - Branco', screenWidth),
                    _buildBlocoButton(context, 'Bloco II - Verde Claro', screenWidth),
                    _buildBlocoButton(context, 'Bloco III - Verde Musgo', screenWidth),
                    _buildBlocoButton(context, 'Bloco IV - Vermelho', screenWidth),
                    _buildBlocoButton(context, 'Charles Darwin', screenWidth),

                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Botão responsivo
  Widget _buildBlocoButton(
    BuildContext context,
    String bloco,
    double screenWidth,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 86, 22, 36),
          minimumSize: Size(screenWidth * 0.9, 50), // largura proporcional
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          // Navega para a home do atendente com o bloco selecionado
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrosEmprestimosPage(nomeBloco: bloco),
              settings: RouteSettings(arguments: {'nomeBloco': bloco}),
            ),
          );
        },

        child: Text(
          bloco,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
