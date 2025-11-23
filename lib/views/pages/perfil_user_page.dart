import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../widgets/navbar_user.dart';
import '../widgets/app_logo.dart';
import '../widgets/emprestimo/user_photo_widget.dart';

class PerfilUserPage extends StatefulWidget {
  const PerfilUserPage({super.key});

  @override
  State<PerfilUserPage> createState() => _PerfilUserPageState();
}

class _PerfilUserPageState extends State<PerfilUserPage> {
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

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar saída'),
        content: const Text('Deseja realmente sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _authService.logout();
        // remove todas as rotas e volta para AuthChecker
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao sair: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPerfilContent(user),
          ),
        ],
      ),
      bottomNavigationBar: const NavBarUser(selectedIndex: 4),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 60),
        // logo com logout
        Row(
          children: [
            const SizedBox(width: 56),
            const Expanded(child: Center(child: AppLogo())),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: IconButton(
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.primary,
                ),
                tooltip: 'Sair',
                onPressed: _logout,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPerfilContent(user) {
    return Column(
      children: [
        // Avatar + nome
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UserPhotoWidget(
                usuario: _userData,
                size: 96,
              ),
              const SizedBox(height: 12),
              Text(
                _userData?.nomeCompleto ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // email, RA, curso, semestre
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildInfoTile(Icons.email_outlined, user?.email ?? '—'),
                const SizedBox(height: 12),
                _buildInfoTile(
                  Icons.badge_outlined,
                  _userData?.registroAcademico ?? '—',
                ),
                if (_userData?.curso != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    Icons.school_outlined,
                    _userData!.curso!,
                  ),
                ],
                if (_userData?.semestre != null) ...[
                  const SizedBox(height: 12),
                  _buildInfoTile(
                    Icons.calendar_today_outlined,
                    '${_userData!.semestre}º Semestre',
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.textWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
