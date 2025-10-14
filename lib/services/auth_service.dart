import 'dart:math';

import '../models/usuario_model.dart';

class AuthService {
  Usuario? _usuarioLogado;
  String? _token;

  //Banco de dados simulado
  final List<Usuario> _usuarios = [
    Usuario(id: '1', nome: 'Vitor', ra: '20244759', senha: '1234'),
    Usuario(id: '2', nome: 'Maria', ra: '20244760', senha: '1234'),
    Usuario(id: '3', nome: 'Izadora', ra: '20244761', senha: '1234'),
    Usuario(id: '4', nome: 'Ruan', ra: '20244762', senha: '1234'),
    Usuario(id: '5', nome: 'Herick', ra: '20244763', senha: '1234'),
  ];

  //Simula login e retorna o token
  Future<String?> login(String ra, String senha) async {
    await Future.delayed(const Duration(seconds: 1));

    final usuario = _usuarios.firstWhere(
      (u) => u.ra == ra && u.senha == senha,
      orElse: () => Usuario(id: '', nome: '', ra: '', senha: ''),
    );

    if (usuario.id.isEmpty) return null;

    _usuarioLogado = usuario;
    _token = _gerarTokenFake(usuario);
    return _token;
  }

  //Simula logout
  void logout() {
    _usuarioLogado = null;
    _token = null;
  }

  bool get estaLogado => _usuarioLogado != null;

  String? get token => _token;

  Usuario? get usuario => _usuarioLogado;

  //Gerar token fake (vai ser implementado JWT quando tiver o banco)
  String _gerarTokenFake(Usuario usuario) {
    final random = Random();
    return "${usuario.id}-${random.nextInt(999999)}-${DateTime.now()}";
  }
}
