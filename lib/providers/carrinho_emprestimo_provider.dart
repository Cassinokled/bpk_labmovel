import 'package:flutter/foundation.dart';
import '../models/equipamento.dart';
import '../models/emprestimo_model.dart';

class CarrinhoEmprestimo extends ChangeNotifier {
  final List<Equipamento> _equipamentos = [];

  List<Equipamento> get equipamentos => List.unmodifiable(_equipamentos);

  int get quantidade => _equipamentos.length;

  bool get temItens => _equipamentos.isNotEmpty;

  void adicionarEquipamento(String codigo) {
    final equipamento = Equipamento.fromCodigo(codigo);
    _equipamentos.add(equipamento);
    notifyListeners();
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
