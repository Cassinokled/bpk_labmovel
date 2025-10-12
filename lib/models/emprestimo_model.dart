//modelo apenas para verificar a criacao do qrcode
//tem que verificar depois as tabelas do banco e
//ver quais dados serao precisos para gerar o qr
//mas ja esta encaminhado


class EmprestimoModel {
  final String ra;
  final String nome;
  final List<ItemEmprestimo> itens;
  final String data;
  final String horario;

  EmprestimoModel({
    required this.ra,
    required this.nome,
    required this.itens,
    required this.data,
    required this.horario,
  });

  // Converte para JSON
  Map<String, dynamic> toJson() {
    return {
      'ra': ra,
      'nome': nome,
      'itens': itens.map((item) => item.toJson()).toList(),
      'data': data,
      'horario': horario,
    };
  }

  // Converte para String JSON formatada para o QR Code
  String toQrString() {
    return '''
{
  "ra": "$ra",
  "nome": "$nome",
  "itens": [
${itens.map((item) => '    {"cod": "${item.cod}", "descricao": "${item.descricao}"}').join(',\n')}
  ],
  "data": "$data",
  "horario": "$horario"
}''';
  }

  // Dados de exemplo
  factory EmprestimoModel.exemplo() {
    return EmprestimoModel(
      ra: '000001',
      nome: 'Fulano',
      itens: [
        ItemEmprestimo(cod: '00001', descricao: 'Notebook Dell Inspiron'),
        ItemEmprestimo(cod: '00002', descricao: 'Régua de carregamento'),
      ],
      data: 'dd-mm-yyyy',
      horario: 'hh:mm',
    );
  }
}

class ItemEmprestimo {
  final String cod;
  final String descricao;

  ItemEmprestimo({
    required this.cod,
    required this.descricao,
  });

  Map<String, dynamic> toJson() {
    return {
      'cod': cod,
      'descricao': descricao,
    };
  }
}
