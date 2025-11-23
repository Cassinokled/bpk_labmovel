import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../utils/app_colors.dart';
import 'user_photo_widget.dart';

// widget pra exibir informacoes do usuario (foto + nome + curso)
class UserInfoCard extends StatelessWidget {
  final UserModel? usuario;

  const UserInfoCard({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserPhotoWidget(usuario: usuario),
        const SizedBox(height: 20),
        _buildUserName(),
      ],
    );
  }

  Widget _buildUserName() {
    final nomeCompleto = usuario != null
        ? '${usuario!.nome} ${usuario!.sobrenome}'
        : 'Nome do Usuário';

    return Column(
      children: [
        Text(
          nomeCompleto,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ),
        if (usuario?.curso != null) ...[
          const SizedBox(height: 8),
          Text(
            usuario!.curso!,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
