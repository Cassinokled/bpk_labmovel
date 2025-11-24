import 'package:cloud_firestore/cloud_firestore.dart';

// modelo de bloco
class Bloco {
  final String id;
  final String nome;

  Bloco({
    required this.id,
    required this.nome,
  });

  // cria bloco firestore
  factory Bloco.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Bloco(
      id: doc.id,
      nome: data['nome'] ?? '',
    );
  }

  // converte para map
  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
    };
  }

  @override
  String toString() {
    return 'Bloco(id: $id, nome: $nome)';
  }
}
