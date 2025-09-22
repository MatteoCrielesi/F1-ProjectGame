import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class GameRecords {
  static Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/game_records.json';
  }

  static Future<File> get _file async => File(await _path);

  // Legge tutto il file o restituisce mappa vuota
  static Future<Map<String, dynamic>> _readAll() async {
    try {
      final f = await _file;
      if (!await f.exists()) return {};
      final content = await f.readAsString();
      return json.decode(content);
    } catch (_) {
      return {};
    }
  }

  static Future<void> _writeAll(Map<String, dynamic> data) async {
    final f = await _file;
    await f.writeAsString(json.encode(data));
  }

  // Salva/aggiorna i record per un circuito
  static Future<void> save(
    String circuitId,
    int lapTime,
    int? totalTime,
  ) async {
    final data = await _readAll();

    if (!data.containsKey(circuitId)) data[circuitId] = {};

    final record = data[circuitId];

    // Miglior lap
    if (!record.containsKey('bestLap') || lapTime < record['bestLap']) {
      record['bestLap'] = lapTime;
    }

    // Miglior tempo totale (solo se passato)
    if (totalTime != null &&
        (!record.containsKey('bestGame') || totalTime < record['bestGame'])) {
      record['bestGame'] = totalTime;
    }

    data[circuitId] = record;
    await _writeAll(data);
  }

  // Recupera i record per un circuito
  static Future<Map<String, int>> get(String circuitId) async {
    final data = await _readAll();
    if (!data.containsKey(circuitId)) return {};
    final record = data[circuitId];
    return {
      'bestLap': record['bestLap'] ?? 0,
      'bestGame': record['bestGame'] ?? 0,
    };
  }
}
