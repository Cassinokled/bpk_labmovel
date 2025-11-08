import 'package:cloud_firestore/cloud_firestore.dart';

// model de usuario com suporte a multiplos tipos
class UserModel {
  final String uid;
  final String email;
  
  // dados basicos obrigatorios
  final String nome;
  final String sobrenome;
  final String nomeCompleto;
  final String dataNasc; // formato: "YYYY-MM-DD"
  final List<String> tiposUsuario; // ["user", "atendente", "admin"]
  final bool ativo;
  final String? foto; // url ou nome da foto do usuario
  
  // dados academicos/funcionais opcionais
  final String? registroAcademico; // ra alunos
  final String? numCracha; // funcionarios admin/atendente/professores
  final String? curso; // alunos
  final int? semestre; // alunos
  
  // metadados
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
    this.foto,
    this.createdAt,
    this.lastLogin,
  });

  // criar usermodel a partir do firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // converte tipos_usuario para list<string>
    List<String> tipos = [];
    if (data['tipos_usuario'] != null) {
      tipos = List<String>.from(data['tipos_usuario']);
    } else {
      tipos = ['user']; // padrao se nao existir
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
      foto: data['foto'],
      registroAcademico: data['registro_academico'],
      numCracha: data['num_cracha'],
      curso: data['curso'],
      semestre: data['semestre'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  // criar a partir de um map
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
      foto: data['foto'],
      registroAcademico: data['registro_academico'],
      numCracha: data['num_cracha'],
      curso: data['curso'],
      semestre: data['semestre'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  // converter map para salvar no firestore
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nome': nome,
      'sobrenome': sobrenome,
      'nome_completo': nomeCompleto,
      'data_nasc': dataNasc,
      'tipos_usuario': tiposUsuario,
      'ativo': ativo,
      'foto': foto,
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

  // helpers para verificar tipos de usuario
  bool get isAdmin => tiposUsuario.contains('admin');
  bool get isAtendente => tiposUsuario.contains('atendente');
  bool get isUser => tiposUsuario.contains('user');
  
  // permissoes baseadas em tipos
  bool get canManageEquipments => isAdmin || isAtendente;
  bool get canManageUsers => isAdmin;
  bool get canMakeLoans => isUser || isAtendente || isAdmin;
  
  // identificacao de perfis
  bool get isAluno => isUser && curso != null && semestre != null;
  bool get isProfessor => isUser && numCracha != null && curso == null;
  bool get isFuncionario => isAdmin || isAtendente;
  
  // tipo principal para exibicao
  String get tipoPrincipal {
    if (isAdmin) return 'Administrador';
    if (isAtendente && isUser) return 'Atendente/Aluno';
    if (isAtendente) return 'Atendente';
    if (isAluno) return 'Aluno';
    if (isProfessor) return 'Professor';
    return 'Usuário';
  }

  // copiar com alteracoes
  UserModel copyWith({
    String? uid,
    String? email,
    String? nome,
    String? sobrenome,
    String? nomeCompleto,
    String? dataNasc,
    List<String>? tiposUsuario,
    bool? ativo,
    String? foto,
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
      foto: foto ?? this.foto,
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
