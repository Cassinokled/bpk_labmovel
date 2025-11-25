import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'users';

  /// criar apos de registro no auth
  Future<void> createUser({
    required String uid,
    required String email,
    required String nome,
    required String sobrenome,
    required String dataNasc,
    List<String> tiposUsuario = const ['user'],
    String? foto,
    String? registroAcademico,
    String? numCracha,
    String? curso,
    int? semestre,
  }) async {
    try {
      final nomeCompleto = '$nome $sobrenome';

      await _db.collection(_collection).doc(uid).set({
        'email': email,
        'nome': nome,
        'sobrenome': sobrenome,
        'nome_completo': nomeCompleto,
        'data_nasc': dataNasc,
        'tipos_usuario': tiposUsuario,
        'ativo': true,
        'foto': foto,
        'registro_academico': registroAcademico,
        'numCracha': numCracha,
        'curso': curso,
        'semestre': semestre,
        'comPendencias': false,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar dados
  Future<UserModel?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(uid).get();

      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar usuário: $e');
      rethrow;
    }
  }

  /// Stream do usuário
  Stream<UserModel?> streamUser(String uid) {
    return _db
        .collection(_collection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  /// Verificar tipos
  Future<List<String>> getUserTypes(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['tipos_usuario'] != null) {
          return List<String>.from(data['tipos_usuario']);
        }
      }
      return ['user'];
    } catch (e) {
      return ['user'];
    }
  }

  /// Verificar tipo específico
  Future<bool> hasUserType(String uid, String type) async {
    try {
      final types = await getUserTypes(uid);
      return types.contains(type);
    } catch (e) {
      return false;
    }
  }

  /// Adicionar tipo
  Future<void> addUserType(String uid, String type) async {
    try {
      final user = await getUser(uid);
      if (user != null && !user.tiposUsuario.contains(type)) {
        final newTypes = [...user.tiposUsuario, type];
        await _db.collection(_collection).doc(uid).update({
          'tipos_usuario': newTypes,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Remover tipo
  Future<void> removeUserType(String uid, String type) async {
    try {
      final user = await getUser(uid);
      if (user != null && user.tiposUsuario.contains(type)) {
        final newTypes = user.tiposUsuario.where((t) => t != type).toList();

        if (newTypes.isEmpty) {
          newTypes.add('user');
        }

        await _db.collection(_collection).doc(uid).update({
          'tipos_usuario': newTypes,
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Atualizar login
  Future<void> updateLastLogin(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {}
  }

  /// Atualizar dados
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    try {
      if (data.containsKey('nome') || data.containsKey('sobrenome')) {
        final currentUser = await getUser(uid);
        if (currentUser != null) {
          final nome = data['nome'] ?? currentUser.nome;
          final sobrenome = data['sobrenome'] ?? currentUser.sobrenome;
          data['nome_completo'] = '$nome $sobrenome';
        }
      }

      await _db.collection(_collection).doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar por tipo
  Future<List<UserModel>> getUsersByType(String type) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('tipos_usuario', arrayContains: type)
          .where('ativo', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar alunos
  Future<List<UserModel>> getAlunos() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('tipos_usuario', arrayContains: 'user')
          .where('ativo', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .where((user) => user.isAluno)
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar atendentes
  Future<List<UserModel>> getAtendentes() async {
    try {
      return await getUsersByType('atendente');
    } catch (e) {
      rethrow;
    }
  }

  /// Buscar por RA
  Future<UserModel?> getUserByRA(String ra) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('registro_academico', isEqualTo: ra)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Buscar por crachá
  Future<UserModel?> getUserByCracha(String cracha) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('numCracha', isEqualTo: cracha)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Desativar usuário
  Future<void> deactivateUser(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).update({'ativo': false});
    } catch (e) {
      rethrow;
    }
  }

  /// Reativar usuário
  Future<void> activateUser(String uid) async {
    try {
      await _db.collection(_collection).doc(uid).update({'ativo': true});
    } catch (e) {
      rethrow;
    }
  }

  /// Verificar se existe
  Future<bool> userExists(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(uid).get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  /// Verificar se RA já está em uso
  Future<bool> raExists(String ra) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('registro_academico', isEqualTo: ra)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Verificar se crachá já está em uso
  Future<bool> crachaExists(String cracha) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(_collection)
          .where('numCracha', isEqualTo: cracha)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // verificar e atualizar status de pendencias do usuario
  Future<void> verificarEAtualizarPendencias(String uid) async {
    try {
      // emprestimos ativos
      final emprestimosQuery = await _db
          .collection('emprestimos')
          .where('userId', isEqualTo: uid)
          .where('confirmado', isEqualTo: true)
          .where('devolvido', isEqualTo: null)
          .get();

      bool temPendencias = false;

      for (var doc in emprestimosQuery.docs) {
        final data = doc.data();
        final confirmedoEm = (data['confirmedoEm'] as Timestamp?)?.toDate();

        if (confirmedoEm != null) {
          // calcular prazo limite
          final prazoLimite = DateTime(
            confirmedoEm.year,
            confirmedoEm.month,
            confirmedoEm.day,
            22,
            30,
          );

          if (DateTime.now().isAfter(prazoLimite)) {
            temPendencias = true;
            break;
          }
        }
      }

      // atualizar o campo comPendencias
      await _db.collection(_collection).doc(uid).update({
        'comPendencias': temPendencias,
      });
    } catch (e) {
      print('Erro ao verificar pendencias: $e');
      rethrow;
    }
  }
}
