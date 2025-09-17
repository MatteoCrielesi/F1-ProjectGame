import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:svg_path_parser/svg_path_parser.dart';

class GameEngine {
  final String circuitAsset;

  // Selected centerline as polylines (one list per subpath)
  final List<List<Offset>> _polylines = [];

  double viewBoxX = 0;
  double viewBoxY = 0;
  double viewBoxWidth = 1000;
  double viewBoxHeight = 1000;

  GameEngine({required this.circuitAsset});

  Future<void> loadPath() async {
    final svgString = await rootBundle.loadString(circuitAsset);

    // Read viewBox if present
    final vb = RegExp(
      r'viewBox="([\d\.\-]+)\s+([\d\.\-]+)\s+([\d\.\-]+)\s+([\d\.\-]+)"',
    ).firstMatch(svgString);
    if (vb != null) {
      viewBoxX = double.parse(vb.group(1)!);
      viewBoxY = double.parse(vb.group(2)!);
      viewBoxWidth = double.parse(vb.group(3)!);
      viewBoxHeight = double.parse(vb.group(4)!);
    }

    // Collect all <path ...> tags
    final pathTagRegex = RegExp(
      r'<path\b[^>]*>',
      multiLine: true,
      caseSensitive: false,
    );
    final tags = pathTagRegex
        .allMatches(svgString)
        .map((m) => m.group(0)!)
        .toList();
    if (tags.isEmpty) {
      throw Exception('No <path> found in SVG.');
    }

    // Extract attributes we care about
    List<_PathCandidate> candidates = [];
    for (final tag in tags) {
      final d = RegExp(
        r'd="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      if (d == null) continue;

      final stroke = RegExp(
        r'stroke\s*=\s*"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      final strokeWidthStr = RegExp(
        r'stroke-width\s*=\s*"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      final strokeWidth = strokeWidthStr != null
          ? double.tryParse(strokeWidthStr) ?? 0
          : 0;

      candidates.add(
        _PathCandidate(
          d: d,
          stroke: stroke ?? 'none',
          strokeWidth: strokeWidth.toDouble(),
        ),
      );
    }

    if (candidates.isEmpty) {
      throw Exception('No path d="" attributes found in SVG.');
    }

    // Score candidates: prefer very dark strokes and reasonable width, then by geometric length
    for (final c in candidates) {
      c.length = _measurePathLength(parseSvgPath(c.d));
      c.darkness = _strokeDarkness(c.stroke);
      c.widthScore = _widthScore(c.strokeWidth);
    }

    candidates.sort((a, b) {
      // Higher darkness first, then width score, then longer length
      final d = b.darkness.compareTo(a.darkness);
      if (d != 0) return d;
      final w = b.widthScore.compareTo(a.widthScore);
      if (w != 0) return w;
      return b.length.compareTo(a.length);
    });

    final chosen = candidates.first;
    final path = parseSvgPath(chosen.d);

    _polylines
      ..clear()
      ..addAll(_extractPolylines(path));
  }

  // Return polylines (one per subpath)
  List<List<Offset>> getPolylines() => _polylines;

  // Helpers

  List<List<Offset>> _extractPolylines(Path path) {
    final res = <List<Offset>>[];
    for (final metric in path.computeMetrics()) {
      final line = <Offset>[];
      for (double d = 0; d <= metric.length; d += 4) {
        final pos = metric.getTangentForOffset(d)!.position;
        line.add(pos);
      }
      // ensure last point
      final last = metric.getTangentForOffset(metric.length)!.position;
      if (line.isEmpty || (line.last - last).distance > 0.001) {
        line.add(last);
      }
      if (line.length > 1) res.add(line);
    }
    return res;
  }

  static double _measurePathLength(Path path) {
    double total = 0;
    for (final m in path.computeMetrics()) {
      total += m.length;
    }
    return total;
  }

  // Map stroke to a darkness in [0..1], where 1 is darkest/most preferred
  static double _strokeDarkness(String stroke) {
    if (stroke.toLowerCase() == 'none') return 0;
    // Handle hex like #1c1c29 or rgb()
    final hex = RegExp(r'#([0-9a-fA-F]{6})').firstMatch(stroke)?.group(1);
    if (hex != null) {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      // Perceived luminance
      final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
      return 1.0 - lum; // darker => higher score
    }
    // Basic rgb(r,g,b)
    final rgb = RegExp(
      r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)',
      caseSensitive: false,
    ).firstMatch(stroke);
    if (rgb != null) {
      final r = int.parse(rgb.group(1)!);
      final g = int.parse(rgb.group(2)!);
      final b = int.parse(rgb.group(3)!);
      final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
      return 1.0 - lum;
    }
    // Unknown format: neutral score
    return 0.5;
  }

  // Favor widths in [2..20], penalize outside
  static double _widthScore(double w) {
    if (w <= 0) return 0.0;
    if (w < 2) return w / 2.0; // up to 1
    if (w <= 20) return 1.0; // ideal band
    if (w <= 40) return 1.0 - ((w - 20) / 20.0).clamp(0.0, 1.0);
    return 0.0;
  }
}

class _PathCandidate {
  _PathCandidate({
    required this.d,
    required this.stroke,
    required this.strokeWidth,
  });
  final String d;
  final String stroke;
  final double strokeWidth;
  double length = 0;
  double darkness = 0;
  double widthScore = 0;
}
