import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // agurada conexao
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // verifica erro
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Erro ao verificar autenticação'),
            ),
          );
        }

        //if user logado then homepage
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }

        // else LoginPage
        return const LoginPage();
      },
    );
  }
}
