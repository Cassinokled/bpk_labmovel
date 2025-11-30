import '../../services/user_service.dart';
import '../../services/equipamento_service.dart';

/// busca e formata dados relacionados aos relatorios
/// utilizado pelo relatorio_pdf_service para os dados formatados
/// para evitar duplicacao de codigo
/// centraliza a logica na hora de pegar as informacoes dos usuarios e equipamentos

class RelatorioDataService {
  final UserService _userService;
  final EquipamentoService _equipamentoService;

  RelatorioDataService({
    UserService? userService,
    EquipamentoService? equipamentoService,
  }) : _userService = userService ?? UserService(),
       _equipamentoService = equipamentoService ?? EquipamentoService();

  Future<String> getUserName(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      return user?.nomeCompleto ?? 'Usuário não encontrado';
    } catch (e) {
      return 'Erro ao buscar usuário';
    }
  }

  Future<String> getEquipamentosFormatted(List<String> codigos) async {
    List<String> formatted = [];
    for (String codigo in codigos) {
      try {
        final equipamento = await _equipamentoService.buscarPorCodigo(codigo);
        final categoria = equipamento?.categoria ?? 'Sem categoria';
        formatted.add('$categoria - $codigo');
      } catch (e) {
        formatted.add('Erro - $codigo');
      }
    }
    return formatted.join(', ');
  }

  Future<Map<String, String>> getUserNames(Set<String> userIds) async {
    Map<String, String> userNames = {};
    for (var userId in userIds) {
      userNames[userId] = await getUserName(userId);
    }
    return userNames;
  }

  Future<Map<String, String>> getEquipamentosFormattedMap(Set<String> codigos) async {
    Map<String, String> equipamentosFormatted = {};
    for (var codigo in codigos) {
      if (!equipamentosFormatted.containsKey(codigo)) {
        equipamentosFormatted[codigo] = await getEquipamentosFormatted([codigo]);
      }
    }
    return equipamentosFormatted;
  }
}