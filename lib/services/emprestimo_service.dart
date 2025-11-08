import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emprestimo_model.dart';

// servico pra gerenciar emprestimos no firestore
class EmprestimoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'emprestimos';

  // cria um novo emprestimo no firestore e retorna o modelo com o id gerado
  Future<EmprestimoModel> criarEmprestimo(EmprestimoModel emprestimo) async {
    try {
      final docRef = await _firestore.collection(_collection).add(emprestimo.toJson());
      
      return emprestimo.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erro ao criar empréstimo: $e');
    }
  }

  // busca um emprestimo por id
  Future<EmprestimoModel?> buscarEmprestimo(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return EmprestimoModel.fromJson(doc.data()!, docId: doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar empréstimo: $e');
    }
  }

  // confirma um emprestimo
  Future<void> confirmarEmprestimo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'confirmado': true,
        'confirmedoEm': Timestamp.now(),
        'motivoRecusa': null,
      });
    } catch (e) {
      throw Exception('Erro ao confirmar empréstimo: $e');
    }
  }

  // recusa um emprestimo
  Future<void> recusarEmprestimo(String id, {String? motivo}) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'confirmado': false,
        'confirmedoEm': Timestamp.now(),
        'motivoRecusa': motivo,
      });
    } catch (e) {
      throw Exception('Erro ao recusar empréstimo: $e');
    }
  }

  // monitora o status de um emprestimo em tempo real
  Stream<EmprestimoModel?> monitorarEmprestimo(String id) {
    return _firestore
        .collection(_collection)
        .doc(id)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }
      return EmprestimoModel.fromJson(snapshot.data()!, docId: snapshot.id);
    });
  }

  // lista todos os emprestimos de um usuario
  Future<List<EmprestimoModel>> listarEmprestimosPorUsuario(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('criadoEm', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => EmprestimoModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar empréstimos: $e');
    }
  }

  // lista emprestimos pendentes de confirmacao (confirmado == null)
  Stream<List<EmprestimoModel>> monitorarEmprestimosPendentes() {
    return _firestore
        .collection(_collection)
        .where('confirmado', isEqualTo: null)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmprestimoModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    });
  }

  // deleta um emprestimo
  Future<void> deletarEmprestimo(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar empréstimo: $e');
    }
  }

  // limpa emprestimos antigos
  Future<void> limparEmprestimosAntigos() async {
    try {
      final dataLimite = DateTime.now().subtract(const Duration(hours: 24));
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('confirmado', isEqualTo: null)
          .where('criadoEm', isLessThan: Timestamp.fromDate(dataLimite))
          .get();
      
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Erro ao limpar empréstimos antigos: $e');
    }
  }
}
