import 'game_records_impl_io.dart'
    if (dart.library.html) 'game_records_impl_web.dart' as impl;

class GameRecords {
  static Future<void> save(
    String circuitId,
    int lapTime,
    int? totalTime,
  ) async => impl.save(circuitId, lapTime, totalTime);

  static Future<Map<String, int>> get(String circuitId) async => impl.get(circuitId);
}
