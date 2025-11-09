import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

// widget reutilizavel pra exibir a foto do usuario
class UserPhotoWidget extends StatelessWidget {
  final UserModel? usuario;
  final double size;

  const UserPhotoWidget({super.key, required this.usuario, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 86, 22, 36).withOpacity(0.1),
        border: Border.all(
          color: const Color.fromARGB(255, 86, 22, 36),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: usuario?.foto != null
            ? _buildUserImage()
            : _buildDefaultAvatar(),
      ),
    );
  }

  Widget _buildUserImage() {
    final foto = usuario!.foto!;

    // se comeca com http ou https, e uma url
    if (foto.startsWith('http://') || foto.startsWith('https://')) {
      return Image.network(
        foto,
        fit: BoxFit.cover,
        width: size,
        height: size,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              color: const Color.fromARGB(255, 86, 22, 36),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    }

    // caso contrario, tenta carregar como asset local
    return Image.asset(
      'assets/pics/$foto',
      fit: BoxFit.cover,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        return _buildDefaultAvatar();
      },
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: const Color.fromARGB(255, 86, 22, 36).withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: const Color.fromARGB(255, 86, 22, 36),
      ),
    );
  }
}
