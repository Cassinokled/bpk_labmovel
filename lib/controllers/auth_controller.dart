import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();

  Future<bool> login(String ra, String senha) async {
    final token = await _authService.login(ra, senha);
    return token != null;
  }

  void logout() {
    _authService.logout();
  }

  bool get estaLogado => _authService.estaLogado;

  String? get token => _authService.token;
}
