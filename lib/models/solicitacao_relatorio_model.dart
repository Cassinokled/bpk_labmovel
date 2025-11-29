import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/brasilia_time.dart';

class SolicitacaoRelatorioModel {
  final String? id;
  final String userId;
  final String titulo;
  final String motivo;
  final DateTime dataInicio;
  final DateTime dataFim;
  final String? comprovanteUrl; 
  final bool? aprovado; // null = pendente - true = aprovado - false = rejeitado
  final DateTime criadoEm;
  final DateTime? aprovadoEm;
  final String? atendenteId;
  final String? motivoRejeicao;

  SolicitacaoRelatorioModel({
    this.id,
    required this.userId,
    required this.titulo,
    required this.motivo,
    required this.dataInicio,
    required this.dataFim,
    this.comprovanteUrl,
    this.aprovado,
    DateTime? criadoEm,
    this.aprovadoEm,
    this.atendenteId,
    this.motivoRejeicao,
  }) : criadoEm = criadoEm ?? BrasiliaTime.now();

  // helpers
  bool get isPendente => aprovado == null;
  bool get isAprovado => aprovado == true;
  bool get isRejeitado => aprovado == false;

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'titulo': titulo,
      'motivo': motivo,
      'dataInicio': Timestamp.fromDate(dataInicio),
      'dataFim': Timestamp.fromDate(dataFim),
      'comprovanteUrl': comprovanteUrl,
      'aprovado': aprovado,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'aprovadoEm': aprovadoEm != null ? Timestamp.fromDate(aprovadoEm!) : null,
      'atendenteId': atendenteId,
      'motivoRejeicao': motivoRejeicao,
    };
  }

  factory SolicitacaoRelatorioModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return SolicitacaoRelatorioModel(
      id: docId ?? json['id'],
      userId: json['userId'],
      titulo: json['titulo'],
      motivo: json['motivo'],
      dataInicio: (json['dataInicio'] as Timestamp).toDate(),
      dataFim: (json['dataFim'] as Timestamp).toDate(),
      comprovanteUrl: json['comprovanteUrl'],
      aprovado: json['aprovado'],
      criadoEm: (json['criadoEm'] as Timestamp).toDate(),
      aprovadoEm: json['aprovadoEm'] != null ? (json['aprovadoEm'] as Timestamp).toDate() : null,
      atendenteId: json['atendenteId'],
      motivoRejeicao: json['motivoRejeicao'],
    );
  }

  SolicitacaoRelatorioModel copyWith({
    String? id,
    String? userId,
    String? titulo,
    String? motivo,
    DateTime? dataInicio,
    DateTime? dataFim,
    String? comprovanteUrl,
    bool? aprovado,
    DateTime? criadoEm,
    DateTime? aprovadoEm,
    String? atendenteId,
    String? motivoRejeicao,
  }) {
    return SolicitacaoRelatorioModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      titulo: titulo ?? this.titulo,
      motivo: motivo ?? this.motivo,
      dataInicio: dataInicio ?? this.dataInicio,
      dataFim: dataFim ?? this.dataFim,
      comprovanteUrl: comprovanteUrl ?? this.comprovanteUrl,
      aprovado: aprovado ?? this.aprovado,
      criadoEm: criadoEm ?? this.criadoEm,
      aprovadoEm: aprovadoEm ?? this.aprovadoEm,
      atendenteId: atendenteId ?? this.atendenteId,
      motivoRejeicao: motivoRejeicao ?? this.motivoRejeicao,
    );
  }
}