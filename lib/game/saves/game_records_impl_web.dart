import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefsKey = 'game_records_json';

Future<Map<String, dynamic>> _readAll() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final content = prefs.getString(_prefsKey);
    if (content == null || content.isEmpty) return {};
    return json.decode(content) as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
}

Future<void> _writeAll(Map<String, dynamic> data) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_prefsKey, json.encode(data));
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