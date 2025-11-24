import 'package:flutter/foundation.dart';
import '../models/bloco_model.dart';

// provider para gerenciar bloco selecionado
class BlocoProvider extends ChangeNotifier {
  Bloco? _blocoSelecionado;

  Bloco? get blocoSelecionado => _blocoSelecionado;

  // seleciona um bloco
  void selecionarBloco(Bloco bloco) {
    _blocoSelecionado = bloco;
    notifyListeners();
  }

  // limpa selecao do bloco
  void limparSelecao() {
    _blocoSelecionado = null;
    notifyListeners();
  }
}
