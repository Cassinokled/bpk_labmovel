import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/brasilia_time.dart';

// modelo de emprestimo para gerar qr code
class EmprestimoModel {
  final String? id; // id no firestore (gera automatico)
  final String userId; // id do usuario que solicitou
  final List<String> codigosEquipamentos; // lista de codigos
  final bool? confirmado; // null = pendente, true = confirmado, false = recusado
  final DateTime criadoEm; // data de criacao
  final DateTime? confirmedoEm; // data de confirmacao
  final String? atendenteEmprestimoId; // id do atendente que confirmou o emprestimo
  final String? atendenteDevolucaoId; // id do atendente que confirmou a devolucao
  final bool atrasado; // se foi devolvido atrasado
  final bool? devolvido; // se foi devolvido
  final DateTime? devolvidoEm; // data de devolucao

  EmprestimoModel({
    this.id,
    required this.userId,
    required this.codigosEquipamentos,
    this.confirmado,
    DateTime? criadoEm,
    this.confirmedoEm,
    this.atendenteEmprestimoId,
    this.atendenteDevolucaoId,
    this.atrasado = false,
    this.devolvido,
    this.devolvidoEm,
  }) : criadoEm = criadoEm ?? BrasiliaTime.now();
  
  // helpers verificar status
  bool get isPendente => confirmado == null;
  bool get isConfirmado => confirmado == true;
  bool get isRecusado => confirmado == false;
  bool get isDevolvido => devolvido == true;
  bool get isAtivo => confirmado == true && devolvido != true;

  // calcula o prazo de devolucao (22:30)
  DateTime get prazoLimiteDevolucao {
    if (confirmedoEm == null) {
      return BrasiliaTime.now().add(const Duration(days: 365));
    }
    
    return BrasiliaTime.create(
      confirmedoEm!.year,
      confirmedoEm!.month,
      confirmedoEm!.day,
      22,
      30,
    );
  }

  // verifica se esta atrasado
  bool get isAtrasadoAtual {
    if (!isAtivo) return false;
    return BrasiliaTime.now().isAfter(prazoLimiteDevolucao);
  }

  // calcula tempo restante
  Duration get tempoRestante {
    final agora = BrasiliaTime.now();
    if (agora.isAfter(prazoLimiteDevolucao)) {
      return Duration.zero;
    }
    return prazoLimiteDevolucao.difference(agora);
  }

  // converte json pra salvar no firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'equipamentos': codigosEquipamentos,
      'confirmado': confirmado,
      'criadoEm': Timestamp.fromDate(criadoEm),
      'confirmedoEm': confirmedoEm != null ? Timestamp.fromDate(confirmedoEm!) : null,
      'atendenteEmprestimoId': atendenteEmprestimoId,
      'atendenteDevolucaoId': atendenteDevolucaoId,
      'atrasado': atrasado,
      'devolvido': devolvido,
      'devolvidoEm': devolvidoEm != null ? Timestamp.fromDate(devolvidoEm!) : null,
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
      criadoEm: (json['criadoEm'] as Timestamp?)?.toDate() ?? BrasiliaTime.now(),
      confirmedoEm: (json['confirmedoEm'] as Timestamp?)?.toDate(),
      atendenteEmprestimoId: json['atendenteEmprestimoId'],
      atendenteDevolucaoId: json['atendenteDevolucaoId'],
      atrasado: json['atrasado'] ?? false,
      devolvido: json['devolvido'],
      devolvidoEm: (json['devolvidoEm'] as Timestamp?)?.toDate(),
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
    String? atendenteEmprestimoId,
    String? atendenteDevolucaoId,
    bool? atrasado,
    bool? devolvido,
    DateTime? devolvidoEm,
  }) {
    return EmprestimoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      codigosEquipamentos: codigosEquipamentos ?? this.codigosEquipamentos,
      confirmado: confirmado ?? this.confirmado,
      criadoEm: criadoEm ?? this.criadoEm,
      confirmedoEm: confirmedoEm ?? this.confirmedoEm,
      atendenteEmprestimoId: atendenteEmprestimoId ?? this.atendenteEmprestimoId,
      atendenteDevolucaoId: atendenteDevolucaoId ?? this.atendenteDevolucaoId,
      atrasado: atrasado ?? this.atrasado,
      devolvido: devolvido ?? this.devolvido,
      devolvidoEm: devolvidoEm ?? this.devolvidoEm,
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
