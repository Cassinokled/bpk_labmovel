class Equipamento {
  final String codigo;
  final String nome;
  final String bloco;

  Equipamento({
    required this.codigo,
    required this.nome,
    required this.bloco,
  });

  factory Equipamento.fromCodigo(String codigo) {
    // adicionar lógica para buscar informações reais no banco depois
    return Equipamento(
      codigo: codigo,
      nome: _getNomeFromCodigo(codigo),
      bloco: 'Verde Musgo',
    );
  }

  static String _getNomeFromCodigo(String codigo) {
    // Subistituir na chamada da API depois (pelo codigo do equipamento)
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
    };
  }

  factory Equipamento.fromJson(Map<String, dynamic> json) {
    return Equipamento(
      codigo: json['codigo'],
      nome: json['nome'],
      bloco: json['bloco'],
    );
  }
}
