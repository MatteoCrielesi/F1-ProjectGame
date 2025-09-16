import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:svg_path_parser/svg_path_parser.dart';

class TrackInfo {
  final String name;
  final String asset;
  const TrackInfo({required this.name, required this.asset});
}

class TeamInfo {
  final String name;
  final Color color;
  const TeamInfo({required this.name, required this.color});
}

// Your data
const tracks = <TrackInfo>[
  TrackInfo(name: 'Abudhabi', asset: 'assets/circuiti/abudhabi.svg'),
];

const teams = <TeamInfo>[
  TeamInfo(name: "McLaren", color: Color(0xFFFF8700)),
  TeamInfo(name: "Aston Martin", color: Color(0xFF006F62)),
  TeamInfo(name: "Alpine", color: Color.fromARGB(255, 243, 34, 229)),
  TeamInfo(name: "Ferrari", color: Color(0xFFDC0000)),
  TeamInfo(name: "Mercedes", color: Color(0xFF00D2BE)),
  TeamInfo(name: "Red Bull Racing", color: Color(0xFF1E41FF)),
  TeamInfo(name: "Haas", color: Color(0xFFB6BABD)),
  TeamInfo(name: "Racing Bulls", color: Color(0xFF00205B)),
  TeamInfo(name: "Kick Sauber", color: Color.fromARGB(255, 0, 255, 8)),
  TeamInfo(name: "Williams", color: Color(0xFF005AFF)),
];

// CHANGE SPEED HERE for all dots (pixels per second)
const double kDotSpeed = 120.0;

class TrackRaceApp extends StatelessWidget {
  const TrackRaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TrackSetupScreen();
  }
}

class TrackSetupScreen extends StatefulWidget {
  const TrackSetupScreen({super.key});

  @override
  State<TrackSetupScreen> createState() => _TrackSetupScreenState();
}

class _TrackSetupScreenState extends State<TrackSetupScreen> {
  TrackInfo selectedTrack = tracks.first;
  TeamInfo selectedTeam = teams.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Dot Runner')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'Track:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<TrackInfo>(
                  value: selectedTrack,
                  items: tracks
                      .map(
                        (t) => DropdownMenuItem(value: t, child: Text(t.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedTrack = v!),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Your Team:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 12),
                DropdownButton<TeamInfo>(
                  value: selectedTeam,
                  items: teams
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: t.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(t.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedTeam = v!),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RaceScreen(
                      track: selectedTrack,
                      playerTeam: selectedTeam,
                    ),
                  ),
                );
              },
              child: const Text('Start Race'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tip: Edit kDotSpeed in the file to change the speed for all dots.',
            ),
          ],
        ),
      ),
    );
  }
}

class RaceScreen extends StatefulWidget {
  final TrackInfo track;
  final TeamInfo playerTeam;
  const RaceScreen({super.key, required this.track, required this.playerTeam});

  @override
  State<RaceScreen> createState() => _RaceScreenState();
}

class _RaceScreenState extends State<RaceScreen>
    with SingleTickerProviderStateMixin {
  late final _engine = SvgTrackEngine(assetPath: widget.track.asset);
  bool _ready = false;

  late final Ticker _ticker;
  double _elapsedSecs = 0;
  late final List<Color> _dotColors;

  @override
  void initState() {
    super.initState();
    final others = teams
        .where((t) => t.name != widget.playerTeam.name)
        .map((t) => t.color)
        .toList();
    _dotColors = [widget.playerTeam.color, ...others].take(10).toList();

    _engine.load().then((_) {
      if (mounted) setState(() => _ready = true);
    });

    _ticker = createTicker((duration) {
      setState(() => _elapsedSecs = duration.inMicroseconds / 1e6);
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.track.name} • 10 Dots')),
      body: _ready
          ? LayoutBuilder(
              builder: (context, constraints) {
                return CustomPaint(
                  painter: RacePainter(
                    engine: _engine,
                    elapsedSeconds: _elapsedSecs,
                    dotColors: _dotColors,
                  ),
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                );
              },
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class SvgTrackEngine {
  final String assetPath;
  SvgTrackEngine({required this.assetPath});

  late String svgString;
  svg.DrawableRoot? root;
  List<List<Offset>> polylines = [];
  double totalLength = 0;

  Future<void> load() async {
    svgString = await rootBundle.loadString(assetPath);

    // ✅ FIX: use SvgParser instead of fromSvgString
    final parser = svg.SvgParser();
    root = await parser.parse(svgString);

    final candidates = _extractPathCandidates(svgString);
    if (candidates.isEmpty) throw Exception('No path d="" found in SVG.');

    for (final c in candidates) {
      final path = parseSvgPath(c.d);
      c.length = _measurePathLength(path);
      c.darkness = _strokeDarkness(c.stroke);
      c.widthScore = _widthScore(c.strokeWidth);
    }
    candidates.sort((a, b) {
      final d = b.darkness.compareTo(a.darkness);
      if (d != 0) return d;
      final w = b.widthScore.compareTo(a.widthScore);
      if (w != 0) return w;
      return b.length.compareTo(a.length);
    });

    final chosen = candidates.first;
    final chosenPath = parseSvgPath(chosen.d);

    polylines = _extractPolylines(chosenPath);
    totalLength = polylines.isNotEmpty ? _polylineLength(polylines.first) : 0;
  }

  static List<_PathCandidate> _extractPathCandidates(String svgStr) {
    final tags = RegExp(
      r'<path\b[^>]*>',
      multiLine: true,
      caseSensitive: false,
    ).allMatches(svgStr).map((m) => m.group(0)!).toList();

    final list = <_PathCandidate>[];
    for (final tag in tags) {
      final d = RegExp(
        r'd="([^"]+)"',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      if (d == null) continue;
      final stroke =
          RegExp(
            r'stroke\s*=\s*"([^"]+)"',
            caseSensitive: false,
          ).firstMatch(tag)?.group(1) ??
          'none';
      final swStr = RegExp(
        r'stroke-width\s*=\s*"([^"]+)"',
        caseSensitive: false,
      ).firstMatch(tag)?.group(1);
      final double sw = swStr != null ? double.tryParse(swStr) ?? 0.0 : 0.0;
      list.add(_PathCandidate(d: d, stroke: stroke, strokeWidth: sw));
    }

    final exact = list
        .where((c) => c.stroke.toLowerCase().contains('#1c1c29'))
        .toList();
    if (exact.isNotEmpty) return exact;

    return list;
  }

  static double _measurePathLength(Path path) {
    double t = 0;
    for (final m in path.computeMetrics()) {
      t += m.length;
    }
    return t;
  }

  static List<List<Offset>> _extractPolylines(Path path) {
    final res = <List<Offset>>[];
    for (final metric in path.computeMetrics()) {
      final line = <Offset>[];
      for (double d = 0; d <= metric.length; d += 3) {
        final pos = metric.getTangentForOffset(d)!.position;
        line.add(pos);
      }
      final last = metric.getTangentForOffset(metric.length)!.position;
      if (line.isEmpty || (line.last - last).distance > 0.001) line.add(last);
      if (line.length > 1) res.add(line);
    }
    return res;
  }

  static double _polylineLength(List<Offset> line) {
    double t = 0;
    for (int i = 0; i < line.length - 1; i++) {
      t += (line[i + 1] - line[i]).distance;
    }
    return t;
  }

  static double _strokeDarkness(String stroke) {
    final s = stroke.toLowerCase();
    if (s == 'none') return 0;
    final hex = RegExp(r'#([0-9a-f]{6})').firstMatch(s)?.group(1);
    if (hex != null) {
      final r = int.parse(hex.substring(0, 2), radix: 16);
      final g = int.parse(hex.substring(2, 4), radix: 16);
      final b = int.parse(hex.substring(4, 6), radix: 16);
      final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
      return 1 - lum;
    }
    final rgb = RegExp(
      r'rgb\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)',
    ).firstMatch(s);
    if (rgb != null) {
      final r = int.parse(rgb.group(1)!);
      final g = int.parse(rgb.group(2)!);
      final b = int.parse(rgb.group(3)!);
      final lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255.0;
      return 1 - lum;
    }
    return 0.5;
  }

  static double _widthScore(double w) {
    if (w <= 0) return 0;
    if (w < 2) return w / 2;
    if (w <= 20) return 1;
    if (w <= 40) return 1 - ((w - 20) / 20).clamp(0.0, 1.0);
    return 0;
  }
}

class _PathCandidate {
  final String d;
  final String stroke;
  final double strokeWidth;
  double length = 0;
  double darkness = 0;
  double widthScore = 0;
  _PathCandidate({
    required this.d,
    required this.stroke,
    required this.strokeWidth,
  });
}

class RacePainter extends CustomPainter {
  final SvgTrackEngine engine;
  final double elapsedSeconds;
  final List<Color> dotColors;

  RacePainter({
    required this.engine,
    required this.elapsedSeconds,
    required this.dotColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final root = engine.root;
    if (root == null || engine.polylines.isEmpty) return;

    root.scaleCanvasToViewBox(canvas, size);
    root.clipCanvasToViewBox(canvas);
    root.draw(canvas, size);

    final guidePaint = Paint()
      ..color = Colors.red.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final pts in engine.polylines) {
      if (pts.length < 2) continue;
      final p = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final o in pts.skip(1)) p.lineTo(o.dx, o.dy);
      canvas.drawPath(p, guidePaint);
    }

    final line = engine.polylines.first;
    if (line.length < 2 || engine.totalLength <= 0) return;

    final segLens = <double>[];
    for (int i = 0; i < line.length - 1; i++) {
      segLens.add((line[i + 1] - line[i]).distance);
    }

    final n = dotColors.length;
    final spacing = engine.totalLength / n;

    for (int i = 0; i < n; i++) {
      final dist =
          (kDotSpeed * elapsedSeconds + i * spacing) % engine.totalLength;
      final pos = _sampleAlong(line, segLens, dist);
      final dotPaint = Paint()..color = dotColors[i];
      canvas.drawCircle(pos, 2.8, dotPaint);
      canvas.drawCircle(
        pos,
        2.8,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = Colors.black.withOpacity(0.7),
      );
    }
  }

  Offset _sampleAlong(
    List<Offset> line,
    List<double> segLens,
    double distance,
  ) {
    double d = distance;
    for (int i = 0; i < segLens.length; i++) {
      final l = segLens[i];
      if (d <= l) {
        final t = d / l;
        return Offset.lerp(line[i], line[i + 1], t)!;
      }
      d -= l;
    }
    return line.last;
  }

  @override
  bool shouldRepaint(covariant RacePainter oldDelegate) =>
      oldDelegate.elapsedSeconds != elapsedSeconds ||
      oldDelegate.engine != engine ||
      oldDelegate.dotColors != dotColors;
}
