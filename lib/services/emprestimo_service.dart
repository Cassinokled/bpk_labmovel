import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emprestimo_model.dart';
import '../utils/brasilia_time.dart';
import 'equipamento_service.dart';

// servico pra gerenciar emprestimos no firestore
class EmprestimoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EquipamentoService _equipamentoService = EquipamentoService();
  final String _collection = 'emprestimos';

  // cria um novo emprestimo no firestore e retorna o modelo com o id gerado
  Future<EmprestimoModel> criarEmprestimo(EmprestimoModel emprestimo) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(emprestimo.toJson());

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
  Future<void> confirmarEmprestimo(String id, String atendenteId) async {
    try {
      final emprestimo = await buscarEmprestimo(id);

      if (emprestimo == null) {
        throw Exception('Empréstimo não encontrado');
      }

      // atualiza o status do emprestimo
      await _firestore.collection(_collection).doc(id).update({
        'confirmado': true,
        'confirmedoEm': Timestamp.fromDate(BrasiliaTime.now()),
        'atendenteEmprestimoId': atendenteId,
      });

      // atualiza o estado de cada equipamento emprestado
      for (final codigoEquipamento in emprestimo.codigosEquipamentos) {
        await _equipamentoService.atualizarEstadoEmprestimo(
          codigoEquipamento,
          true,
        );
      }
    } catch (e) {
      throw Exception('Erro ao confirmar empréstimo: $e');
    }
  }

  // recusa um emprestimo
  Future<void> recusarEmprestimo(String id, {String? motivo}) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'confirmado': false,
        'confirmedoEm': Timestamp.fromDate(BrasiliaTime.now()),
        'motivoRecusa': motivo,
      });
    } catch (e) {
      throw Exception('Erro ao recusar empréstimo: $e');
    }
  }

  // atualiza isBlocoCorreto
  Future<void> atualizarIsBlocoCorreto(String id, bool isBlocoCorreto) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isBlocoCorreto': isBlocoCorreto,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar bloco correto: $e');
    }
  }

  // atualiza campos especificos emprestimo
  Future<void> atualizarEmprestimo(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(id).update(updates);
    } catch (e) {
      throw Exception('Erro ao atualizar empréstimo: $e');
    }
  }

  // devolve um emprestimo (finaliza)
  Future<void> devolverEmprestimo(String id, String atendenteId) async {
    try {
      // busca o emprestimo
      final emprestimo = await buscarEmprestimo(id);

      if (emprestimo == null) {
        throw Exception('Empréstimo não encontrado');
      }

      // verifica se esta atrasado
      final agora = BrasiliaTime.now();
      final atrasado = agora.isAfter(emprestimo.prazoLimiteDevolucao);

      // atualiza o status do emprestimo
      await _firestore.collection(_collection).doc(id).update({
        'devolvido': true,
        'devolvidoEm': Timestamp.fromDate(agora),
        'atendenteDevolucaoId': atendenteId,
        'atrasado': atrasado,
      });

      // libera cada equipamento (estado_emprestado = false)
      for (final codigoEquipamento in emprestimo.codigosEquipamentos) {
        await _equipamentoService.atualizarEstadoEmprestimo(
          codigoEquipamento,
          false,
        );
      }
    } catch (e) {
      throw Exception('Erro ao devolver empréstimo: $e');
    }
  }

  // monitora o status de um emprestimo em tempo real
  Stream<EmprestimoModel?> monitorarEmprestimo(String id) {
    return _firestore.collection(_collection).doc(id).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) {
        return null;
      }
      return EmprestimoModel.fromJson(snapshot.data()!, docId: snapshot.id);
    });
  }

  // monitora emprestimos ativos de um usuario (confirmados e nao devolvidos)
  Stream<List<EmprestimoModel>> monitorarEmprestimosAtivos(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          // filtra e ordena
          final emprestimos = snapshot.docs
              .map((doc) => EmprestimoModel.fromJson(doc.data(), docId: doc.id))
              .where(
                (emprestimo) =>
                    emprestimo.confirmado == true &&
                    emprestimo.devolvido != true,
              )
              .toList();

          // ordena por data
          emprestimos.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

          return emprestimos;
        });
  }

  // lista todos os emprestimos de um usuario
  Future<List<EmprestimoModel>> listarEmprestimosPorUsuario(
    String userId,
  ) async {
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
