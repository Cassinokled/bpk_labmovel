import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authController = AuthController();
  final _raController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _carregando = false;
  String? _erro;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Logo
                Image.asset(
                  'assets/pics/logos/logo_bpk.png',
                  width: 161,
                  height: 45,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 60),

                // Campo de e-mail
                TextField(
                  controller: _raController,
                  decoration: InputDecoration(
                    labelText: 'Digite seu RA',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de senha
                TextField(
                  controller: _senhaController,
                  decoration: InputDecoration(
                    labelText: 'Digite sua senha',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),

                // Botão de login
                ElevatedButton(
                  onPressed: _carregando
                      ? null
                      : () async {
                          setState(() {
                            _carregando = true;
                            _erro = null;
                          });

                          final sucesso = await _authController.login(
                            _raController.text.trim(),
                            _senhaController.text.trim(),
                          );

                          setState(() {
                            _carregando = false;
                          });

                          if (sucesso) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          } else {
                            setState(() {
                              _erro = 'RA ou senha inválidos.';
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C2E3E),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: _carregando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),

                if (_erro != null) ...[
                  const SizedBox(height: 16),
                  Text(_erro!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
