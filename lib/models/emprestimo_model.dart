import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

// modelo de emprestimo para gerar qr code
class EmprestimoModel {
  final String? id; // id no firestore (gera automatico)
  final String userId; // id do usuario
  final List<String> codigosEquipamentos; // lista de codigos
  final bool? confirmado; // null = pendente, true = confirmado, false = recusado
  final DateTime criadoEm; // data de criacao
  final DateTime? confirmedoEm; // data de confirmacao/recusa
  final String? motivoRecusa; // motivo da recusa se houver

  EmprestimoModel({
    this.id,
    required this.userId,
    required this.codigosEquipamentos,
    this.confirmado,
    DateTime? criadoEm,
    this.confirmedoEm,
    this.motivoRecusa,
  }) : criadoEm = criadoEm ?? DateTime.now();
  
  // helpers verificar status
  bool get isPendente => confirmado == null;
  bool get isConfirmado => confirmado == true;
  bool get isRecusado => confirmado == false;

  // converte json pra salvar no firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'equipamentos': codigosEquipamentos,
      'confirmado': confirmado,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'confirmedoEm': confirmedoEm != null ? Timestamp.fromDate(confirmedoEm!) : null,
      'motivoRecusa': motivoRecusa,
    };
  }

  // converte string json pro qr code
  String toQrString() {
    return jsonEncode({
      'emprestimoId': id,
      'userId': userId,
    });
  }

  // cria a partir do json do firestore
  factory EmprestimoModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return EmprestimoModel(
      id: docId ?? json['id'],
      userId: json['userId'],
      codigosEquipamentos: List<String>.from(json['equipamentos'] ?? []),
      confirmado: json['confirmado'],
      criadoEm: (json['criadoEm'] as Timestamp?)?.toDate() ?? DateTime.now(),
      confirmedoEm: (json['confirmedoEm'] as Timestamp?)?.toDate(),
      motivoRecusa: json['motivoRecusa'],
    );
  }

  // cria a partir da string json (pra ler qr code)
  factory EmprestimoModel.fromQrString(String qrString) {
    final json = jsonDecode(qrString);
    return EmprestimoModel(
      id: json['emprestimoId'],
      userId: json['userId'],
      codigosEquipamentos: [],
    );
  }

  // cria copia com campos atualizados
  EmprestimoModel copyWith({
    String? id,
    String? userId,
    List<String>? codigosEquipamentos,
    bool? confirmado,
    DateTime? criadoEm,
    DateTime? confirmedoEm,
    String? motivoRecusa,
  }) {
    return EmprestimoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      codigosEquipamentos: codigosEquipamentos ?? this.codigosEquipamentos,
      confirmado: confirmado ?? this.confirmado,
      criadoEm: criadoEm ?? this.criadoEm,
      confirmedoEm: confirmedoEm ?? this.confirmedoEm,
      motivoRecusa: motivoRecusa ?? this.motivoRecusa,
    );
  }

  // Dados de exemplo
  factory EmprestimoModel.exemplo() {
    return EmprestimoModel(
      userId: 'user123abc',
      codigosEquipamentos: ['5815', '5820', '5825'],
    );
  }
}
