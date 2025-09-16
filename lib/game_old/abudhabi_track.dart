import 'dart:ui';
import 'package:flutter/services.dart' show rootBundle;
import 'package:svg_path_parser/svg_path_parser.dart';

class AbuDhabiTrack {
  static List<Offset> points = [];

  /// Carica il path dall'SVG e converte in lista di Offset
  static Future<void> load() async {
    if (points.isNotEmpty) return; // evita di ricaricare due volte

    final svgData = await rootBundle.loadString('assets/circuiti/abudhabi.svg');

    // Trova l'attributo d="..."
    final regex = RegExp(r'd="([^"]+)"');
    final match = regex.firstMatch(svgData);
    if (match == null) {
      throw Exception("Path non trovato nell'SVG di Abu Dhabi");
    }

    final d = match.group(1)!;
    final path = parseSvgPath(d);

    // Approssima il path con molti punti
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      const precision = 300; // più alto = più punti
      for (int i = 0; i <= precision; i++) {
        final t = i / precision;
        final position = metric
            .getTangentForOffset(metric.length * t)!
            .position;
        points.add(position);
      }
    }
  }
}
