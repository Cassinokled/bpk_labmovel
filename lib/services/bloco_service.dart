import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bloco_model.dart';

// servico para gerenciar blocos no firestore
class BlocoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'blocos';

  // busca blocos
  Future<List<Bloco>> buscarTodos() async {
    try {
      QuerySnapshot querySnapshot = await _db.collection(_collection).get();
      return querySnapshot.docs.map((doc) => Bloco.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erro ao buscar blocos: $e');
      return [];
    }
  }

  // busca bloco por id
  Future<Bloco?> buscarPorId(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Bloco.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar bloco: $e');
      return null;
    }
  }
}
