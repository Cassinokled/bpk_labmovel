import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'dart:convert';
import '../models/solicitacao_relatorio_model.dart';

class SolicitacaoRelatorioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'solicitacoes_relatorio';
  final String _arquivosCollection = 'protocolos_arquivos';

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

  // salvando em base64 - para salvar no firestore
  Future<String?> uploadComprovante(File file, String userId, String solicitacaoId) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = file.path.split('/').last;
      return await _salvarArquivoFirestore(bytes, fileName, userId, solicitacaoId);
    } catch (e) {
      print('Erro detalhado no upload: $e');
      throw Exception('Erro ao fazer upload do comprovante: $e');
    }
  }

  Future<String?> uploadComprovanteBytes(List<int> bytes, String fileName, String userId, String solicitacaoId) async {
    try {
      return await _salvarArquivoFirestore(bytes, fileName, userId, solicitacaoId);
    } catch (e) {
      print('Erro detalhado no upload: $e');
      throw Exception('Erro ao fazer upload do comprovante: $e');
    }
  }

  Future<String?> uploadComprovantePath(String filePath, String userId, String solicitacaoId) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final fileName = filePath.split('/').last;
      return await _salvarArquivoFirestore(bytes, fileName, userId, solicitacaoId);
    } catch (e) {
      print('Erro detalhado no upload: $e');
      throw Exception('Erro ao fazer upload do comprovante: $e');
    }
  }

  // metodo que salva no firestore
  Future<String> _salvarArquivoFirestore(List<int> bytes, String fileName, String userId, String solicitacaoId) async {
    try {
      // limitando o tamanho do arquivo por conta do limite do firestore
      const maxSize = 1024 * 1024; //1mb
      if (bytes.length > maxSize) {
        throw Exception('Arquivo muito grande. O tamanho máximo é 1MB.');
      }

      // converte para base64
      final base64String = base64Encode(bytes);
      
      // verifica o tipo de arquivo
      final extension = fileName.split('.').last.toLowerCase();
      String mimeType = 'application/octet-stream';
      
      if (extension == 'pdf') {
        mimeType = 'application/pdf';
      } else if (['jpg', 'jpeg'].contains(extension)) {
        mimeType = 'image/jpeg';
      } else if (extension == 'png') {
        mimeType = 'image/png';
      } else if (extension == 'txt') {
        mimeType = 'text/plain';
      } else if (['doc', 'docx'].contains(extension)) {
        mimeType = 'application/msword';
      }

      // salva no firestore
      final docRef = await _firestore.collection(_arquivosCollection).add({
        'userId': userId,
        'solicitacaoId': solicitacaoId,
        'fileName': fileName,
        'mimeType': mimeType,
        'base64Data': base64String,
        'size': bytes.length,
        'criadoEm': Timestamp.now(),
      });

      return docRef.id;
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

  // buscando arquivo do firestore e retornando URL para visualizr
  Future<Map<String, dynamic>?> buscarArquivo(String arquivoId) async {
    try {
      final doc = await _firestore.collection(_arquivosCollection).doc(arquivoId).get();
      
      if (!doc.exists) {
        return null;
      }

      return doc.data();
    } catch (e) {
      throw Exception('Erro ao buscar arquivo: $e');
    }
  }

  // converte o arquivo do base64 pra o original novamente (se tudo der certo '-')
  String gerarDataUri(String base64Data, String mimeType) {
    return 'data:$mimeType;base64,$base64Data';
  }
}