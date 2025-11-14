import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'atendente_user_select_page.dart';
import 'atendente_page.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // aguarda conexao
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

        //if user logado then verifica tipo e redireciona
        if (snapshot.hasData && snapshot.data != null) {
          return FutureBuilder<UserModel?>(
            future: UserService().getUser(snapshot.data!.uid),
            builder: (context, userSnapshot) {
              // aguarda dados do usuario
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // verifica erro ao buscar dados
              if (userSnapshot.hasError) {
                return const Scaffold(
                  body: Center(
                    child: Text('Erro ao carregar dados do usuário'),
                  ),
                );
              }

              final user = userSnapshot.data;

              // se nao encontrou dados do usuario vai pra login
              if (user == null) {
                return const LoginPage();
              }

              // verifica tipo de usuario e redireciona
              // se for apenas atendente (sem ser user), vai direto para seleção de bloco
              if (user.isAtendente && !user.isUser) {
                return const AtendentePage();
              }
              
              // se for atendente E user, vai pra página de seleção de tipo
              if (user.isAtendente && user.isUser) {
                return const AtendenteUserSelectPage();
              }

              // se for apenas user vai pra home normal
              return const HomePage();
            },
          );
        }

        // else LoginPage
        return const LoginPage();
      },
    );
  }
}
