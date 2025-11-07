import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/user_model.dart';
import '../widgets/navbar.dart';
import '../widgets/app_logo.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
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
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F5),
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
      bottomNavigationBar: const NavBar(),
    );
  }

  Widget _buildHeader() {
    return const Column(
      children: [
        SizedBox(height: 60),
        Center(child: AppLogo()),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPerfilContent(user) {
    return Column(
      children: [
        // Parte superior: Avatar + nome
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 48,
                backgroundColor: Color.fromARGB(255, 200, 200, 200),
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                _userData?.nome ?? 'Usuário',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 86, 22, 36),
                ),
              ),
            ],
          ),
        ),

        // Parte inferior: Email, Telefone, RA, Tipo de Usuário
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildInfoTile(Icons.email_outlined, user?.email ?? '—'),
                const SizedBox(height: 12),
                _buildInfoTile(Icons.badge_outlined, _userData?.registroAcademico ?? '—'),
                const SizedBox(height: 12),
                _buildInfoTile(
                  Icons.verified_user,
                  (_userData?.tiposUsuario.isNotEmpty ?? false)
                      ? _userData!.tiposUsuario.join(' | ')
                      : 'Tipo não informado',
                ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 86, 22, 36)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Color.fromARGB(255, 86, 22, 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
