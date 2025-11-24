import 'package:flutter/foundation.dart';
import '../models/equipamento.dart';
import '../models/emprestimo_model.dart';
import '../models/bloco_model.dart';
import '../services/equipamento_service.dart';

class CarrinhoEmprestimo extends ChangeNotifier {
  final List<Equipamento> _equipamentos = [];
  final EquipamentoService _equipamentoService = EquipamentoService();
  Bloco? _blocoEsperado;

  void setBlocoEsperado(Bloco bloco) {
    _blocoEsperado = bloco;
  }

  List<Equipamento> get equipamentos => List.unmodifiable(_equipamentos);

  int get quantidade => _equipamentos.length;

  bool get temItens => _equipamentos.isNotEmpty;

  Future<Map<String, dynamic>> adicionarEquipamento(String codigo) async {
    // busca o equipamento do banco
    final equipamento = await _equipamentoService.buscarPorCodigo(codigo);

    if (equipamento == null) {
      return {
        'sucesso': false,
        'mensagem': 'Equipamento não encontrado.',
      };
    }

    // verifica se o bloco do equipamento
    if (_blocoEsperado != null && equipamento.bloco != _blocoEsperado!.nome) {
      return {
        'sucesso': false,
        'mensagem': 'Este equipamento pertence a outro bloco (${equipamento.bloco}). Você só pode emprestar itens do bloco ${_blocoEsperado!.nome}.',
      };
    }

    _equipamentos.add(equipamento);
    notifyListeners();
    return {
      'sucesso': true,
      'mensagem': 'Equipamento adicionado com sucesso.',
    };
  }

  void removerEquipamento(int index) {
    if (index >= 0 && index < _equipamentos.length) {
      _equipamentos.removeAt(index);
      notifyListeners();
    }
  }

  void removerPorCodigo(String codigo) {
    _equipamentos.removeWhere((e) => e.codigo == codigo);
    notifyListeners();
  }

  void limparCarrinho() {
    _equipamentos.clear();
    notifyListeners();
  }

  bool contemCodigo(String codigo) {
    return _equipamentos.any((e) => e.codigo == codigo);
  }

  /// gera o modelo de emprestimo pro qr code
  /// recebe o id do usuario e retorna um emprestimomodel
  EmprestimoModel gerarEmprestimo(String userId) {
    final codigosEquipamentos = _equipamentos.map((e) => e.codigo).toList();
    return EmprestimoModel(
      userId: userId,
      codigosEquipamentos: codigosEquipamentos,
      confirmado: null, // inicia como pendente (null)
    );
  }
}
