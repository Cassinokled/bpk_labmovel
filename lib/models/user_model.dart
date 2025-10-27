import 'package:cloud_firestore/cloud_firestore.dart';

/// Model de Usuário com suporte a múltiplos tipos
class UserModel {
  final String uid;
  final String email;
  
  // Dados básicos (obrigatórios)
  final String nome;
  final String sobrenome;
  final String nomeCompleto;
  final String dataNasc; // formato: "YYYY-MM-DD"
  final List<String> tiposUsuario; // ["user", "atendente", "admin"]
  final bool ativo;
  
  // Dados acadêmicos/funcionais (opcionais)
  final String? registroAcademico; // RA - alunos
  final String? numCracha; // Funcionários (admin/atendente/professores)
  final String? curso; // Alunos
  final int? semestre; // Alunos
  
  // Metadados
  final DateTime? createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.nome,
    required this.sobrenome,
    required this.nomeCompleto,
    required this.dataNasc,
    required this.tiposUsuario,
    this.ativo = true,
    this.registroAcademico,
    this.numCracha,
    this.curso,
    this.semestre,
    this.createdAt,
    this.lastLogin,
  });

  /// Criar UserModel a partir do Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Converte tipos_usuario para List<String>
    List<String> tipos = [];
    if (data['tipos_usuario'] != null) {
      tipos = List<String>.from(data['tipos_usuario']);
    } else {
      tipos = ['user']; // padrão se não existir
    }
    
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
      nomeCompleto: data['nome_completo'] ?? '${data['nome']} ${data['sobrenome']}',
      dataNasc: data['data_nasc'] ?? '',
      tiposUsuario: tipos,
      ativo: data['ativo'] ?? true,
      registroAcademico: data['registro_academico'],
      numCracha: data['num_cracha'],
      curso: data['curso'],
      semestre: data['semestre'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  /// Criar a partir de um Map
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    List<String> tipos = [];
    if (data['tipos_usuario'] != null) {
      tipos = List<String>.from(data['tipos_usuario']);
    } else {
      tipos = ['user'];
    }
    
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      nome: data['nome'] ?? '',
      sobrenome: data['sobrenome'] ?? '',
      nomeCompleto: data['nome_completo'] ?? '${data['nome']} ${data['sobrenome']}',
      dataNasc: data['data_nasc'] ?? '',
      tiposUsuario: tipos,
      ativo: data['ativo'] ?? true,
      registroAcademico: data['registro_academico'],
      numCracha: data['num_cracha'],
      curso: data['curso'],
      semestre: data['semestre'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  /// Converter para Map para salvar no Firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'sobrenome': sobrenome,
      'nome_completo': nomeCompleto,
      'data_nasc': dataNasc,
      'tipos_usuario': tiposUsuario,
      'ativo': ativo,
      'registro_academico': registroAcademico,
      'num_cracha': numCracha,
      'curso': curso,
      'semestre': semestre,
      'createdAt': createdAt != null 
          ? Timestamp.fromDate(createdAt!) 
          : FieldValue.serverTimestamp(),
      'lastLogin': lastLogin != null 
          ? Timestamp.fromDate(lastLogin!) 
          : FieldValue.serverTimestamp(),
    };
  }

  /// Helpers para verificar tipos de usuário
  bool get isAdmin => tiposUsuario.contains('admin');
  bool get isAtendente => tiposUsuario.contains('atendente');
  bool get isUser => tiposUsuario.contains('user');
  
  /// Permissões baseadas em tipos
  bool get canManageEquipments => isAdmin || isAtendente;
  bool get canManageUsers => isAdmin;
  bool get canMakeLoans => isUser || isAtendente || isAdmin;
  
  /// Identificação de perfis
  bool get isAluno => isUser && curso != null && semestre != null;
  bool get isProfessor => isUser && numCracha != null && curso == null;
  bool get isFuncionario => isAdmin || isAtendente;
  
  /// Tipo principal (para exibição)
  String get tipoPrincipal {
    if (isAdmin) return 'Administrador';
    if (isAtendente && isUser) return 'Atendente/Aluno';
    if (isAtendente) return 'Atendente';
    if (isAluno) return 'Aluno';
    if (isProfessor) return 'Professor';
    return 'Usuário';
  }

  /// Copiar com alterações
  UserModel copyWith({
    String? uid,
    String? email,
    String? nome,
    String? sobrenome,
    String? nomeCompleto,
    String? dataNasc,
    List<String>? tiposUsuario,
    bool? ativo,
    String? registroAcademico,
    String? numCracha,
    String? curso,
    int? semestre,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      dataNasc: dataNasc ?? this.dataNasc,
      tiposUsuario: tiposUsuario ?? this.tiposUsuario,
      ativo: ativo ?? this.ativo,
      registroAcademico: registroAcademico ?? this.registroAcademico,
      numCracha: numCracha ?? this.numCracha,
      curso: curso ?? this.curso,
      semestre: semestre ?? this.semestre,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, nome: $nomeCompleto, email: $email, tipos: $tiposUsuario)';
  }
}
