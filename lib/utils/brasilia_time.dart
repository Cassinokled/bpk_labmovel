import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class BrasiliaTime {
  static bool _initialized = false;

  // inicializa
  static void initialize() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  // retorna o horario atual de brasilia
  static DateTime now() {
    initialize();
    final saoPaulo = tz.getLocation('America/Sao_Paulo');
    return tz.TZDateTime.now(saoPaulo);
  }

  // converte um datetime utc pro horario de brasilia
  static DateTime fromUtc(DateTime utc) {
    initialize();
    final saoPaulo = tz.getLocation('America/Sao_Paulo');
    return tz.TZDateTime.from(utc, saoPaulo);
  }

  // cria um datetime especifico no horario de brasilia
  static DateTime create(int year, int month, int day, [int hour = 0, int minute = 0, int second = 0]) {
    initialize();
    final saoPaulo = tz.getLocation('America/Sao_Paulo');
    return tz.TZDateTime(saoPaulo, year, month, day, hour, minute, second);
  }
}
