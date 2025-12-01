import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/solicitacao_relatorio_model.dart';

class SolicitacaoRelatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _collection = 'solicitacoes_relatorio';

  Future<SolicitacaoRelatorioModel> criarSolicitacao(SolicitacaoRelatorioModel solicitacao) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(solicitacao.toJson());

      return solicitacao.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Erro ao criar solicitação: $e');
    }
  }

  Future<String?> uploadComprovante(File file, String userId, String solicitacaoId) async {
    try {
      final ref = _storage.ref().child('comprovantes/$userId/$solicitacaoId/${file.path.split('/').last}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Erro ao fazer upload do comprovante: $e');
    }
  }

  // busca por id
  Future<SolicitacaoRelatorioModel?> buscarSolicitacao(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

      if (!doc.exists) {
        return null;
      }

      return SolicitacaoRelatorioModel.fromJson(doc.data()!, docId: doc.id);
    } catch (e) {
      throw Exception('Erro ao buscar solicitação: $e');
    }
  }

  // busca tudo
  Future<List<SolicitacaoRelatorioModel>> buscarSolicitacoesPorUsuario(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final solicitacoes = querySnapshot.docs
          .map((doc) => SolicitacaoRelatorioModel.fromJson(doc.data(), docId: doc.id))
          .toList();

      solicitacoes.sort((a, b) => b.criadoEm.compareTo(a.criadoEm));

      return solicitacoes;
    } catch (e) {
      throw Exception('Erro ao buscar solicitações: $e');
    }
  }

  Future<List<SolicitacaoRelatorioModel>> buscarTodasSolicitacoes() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('criadoEm', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SolicitacaoRelatorioModel.fromJson(doc.data(), docId: doc.id))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar solicitações: $e');
    }
  }

  Future<void> aprovarSolicitacao(String id, String atendenteId) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'aprovado': true,
        'aprovadoEm': Timestamp.now(),
        'atendenteId': atendenteId,
      });
    } catch (e) {
      throw Exception('Erro ao aprovar solicitação: $e');
    }
  }

  Future<void> atualizarComprovanteUrl(String id, String comprovanteUrl) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'comprovanteUrl': comprovanteUrl,
      });
    } catch (e) {
      throw Exception('Erro ao atualizar comprovante: $e');
    }
  }

  Future<void> rejeitarSolicitacao(String id, String motivo, String atendenteId) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'aprovado': false,
        'motivoRejeicao': motivo,
        'aprovadoEm': Timestamp.now(),
        'atendenteId': atendenteId,
      });
    } catch (e) {
      throw Exception('Erro ao rejeitar solicitação: $e');
    }
  }
}