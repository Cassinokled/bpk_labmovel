import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/equipamento.dart';

class EquipamentoService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'equipamentos';

  // busca um equipamento pelo codigo de barras
  Future<Equipamento?> buscarPorCodigo(String codigo) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(_collection)
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data() as Map<String, dynamic>;
      
      return Equipamento.fromJson(data);
    } catch (e) {
      print('Erro ao buscar equipamento: $e');
      return null;
    }
  }

  // verifica se um equipamento existe e esta disponivel
  Future<Map<String, dynamic>> verificarDisponibilidade(String codigo) async {
    try {
      final equipamento = await buscarPorCodigo(codigo);

      if (equipamento == null) {
        return {
          'existe': false,
          'disponivel': false,
          'mensagem': 'Equipamento não encontrado no banco de dados.',
        };
      }

      if (equipamento.estadoEmprestado) {
        return {
          'existe': true,
          'disponivel': false,
          'mensagem': 'Este equipamento já está emprestado.',
          'equipamento': equipamento,
        };
      }

      return {
        'existe': true,
        'disponivel': true,
        'mensagem': 'Equipamento disponível para empréstimo.',
        'equipamento': equipamento,
      };
    } catch (e) {
      return {
        'existe': false,
        'disponivel': false,
        'mensagem': 'Erro ao verificar equipamento: $e',
      };
    }
  }

  // atualiza o estado de emprestimo de um equipamento
  Future<bool> atualizarEstadoEmprestimo(String codigo, bool emprestado) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(_collection)
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return false;
      }

      final docId = querySnapshot.docs.first.id;
      await _db.collection(_collection).doc(docId).update({
        'estado_emprestado': emprestado,
      });

      return true;
    } catch (e) {
      print('Erro ao atualizar estado de empréstimo: $e');
      return false;
    }
  }
}
