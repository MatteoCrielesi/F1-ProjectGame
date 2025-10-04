import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<Map<String, dynamic>> _readAll() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/game_records.json');
    if (!await f.exists()) return {};
    final content = await f.readAsString();
    return json.decode(content) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

Future<void> _writeAll(Map<String, dynamic> data) async {
  final dir = await getApplicationDocumentsDirectory();
  final f = File('${dir.path}/game_records.json');
  await f.writeAsString(json.encode(data));
}

Future<void> save(String circuitId, int lapTime, int? totalTime) async {
  final data = await _readAll();
  if (!data.containsKey(circuitId)) data[circuitId] = {};
  final record = data[circuitId];
  if (!record.containsKey('bestLap') || lapTime < record['bestLap']) {
    record['bestLap'] = lapTime;
  }
  if (totalTime != null &&
      (!record.containsKey('bestGame') || totalTime < record['bestGame'])) {
    record['bestGame'] = totalTime;
  }
  data[circuitId] = record;
  await _writeAll(data);
}

Future<Map<String, int>> get(String circuitId) async {
  final data = await _readAll();
  if (!data.containsKey(circuitId)) return {};
  final record = data[circuitId];
  return {
    'bestLap': record['bestLap'] ?? 0,
    'bestGame': record['bestGame'] ?? 0,
  };
}