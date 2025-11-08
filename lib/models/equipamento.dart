class Equipamento {
  final String codigo;
  final String nome;
  final String bloco;
  final String? categoria;
  final bool estadoEmprestado;

  Equipamento({
    required this.codigo,
    required this.nome,
    required this.bloco,
    this.categoria,
    this.estadoEmprestado = false,
  });

  factory Equipamento.fromCodigo(String codigo) {
    // depois tem que adicionar logica pra buscar no banco
    return Equipamento(
      codigo: codigo,
      nome: _getNomeFromCodigo(codigo),
      bloco: 'Verde Musgo',
      estadoEmprestado: false,
    );
  }

  static String _getNomeFromCodigo(String codigo) {
    // substituir pela chamada da api depois (pelo codigo do equipamento)
    if (codigo.startsWith('1')) {
      return 'Notebook 01';
    } else if (codigo.startsWith('2')) {
      return 'Extensão 01';
    } else {
      return 'Equipamento';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nome': nome,
      'bloco': bloco,
      'categoria': categoria,
      'estado_emprestado': estadoEmprestado,
    };
  }

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      codigo: json['codigo'] ?? '',
      nome: json['nome'] ?? 'Equipamento sem nome',
      bloco: json['bloco'] ?? 'Não especificado',
      categoria: json['categoria'],
      estadoEmprestado: json['estado_emprestado'] ?? false,
    );
  }
}
