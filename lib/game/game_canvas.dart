import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game_engine.dart';

class GameCanvas extends StatefulWidget {
  final String circuitAsset;
  const GameCanvas({super.key, required this.circuitAsset});

  @override
  State<GameCanvas> createState() => _GameCanvasState();
}

class _GameCanvasState extends State<GameCanvas>
    with SingleTickerProviderStateMixin {
  late GameEngine _engine;
  bool _loaded = false;

  // Simple demo runner moving along the selected centerline
  double _distance = 0; // px along the polyline
  double _speed = 120; // px/s
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _engine = GameEngine(circuitAsset: widget.circuitAsset);
    _engine
        .loadPath()
        .then((_) {
          if (mounted) setState(() => _loaded = true);
        })
        .catchError((e) => debugPrint('[GameCanvas] SVG load error: $e'));

    _ticker = createTicker((elapsed) {
      final dt = elapsed.inMicroseconds / 1e6;
      _distance += _speed * dt;
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const Center(child: CircularProgressIndicator());

    final size = MediaQuery.of(context).size;

    final scaleX = size.width / _engine.viewBoxWidth;
    final scaleY = size.height / _engine.viewBoxHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX =
        (size.width - _engine.viewBoxWidth * scale) / 2 -
        _engine.viewBoxX * scale;
    final offsetY =
        (size.height - _engine.viewBoxHeight * scale) / 2 -
        _engine.viewBoxY * scale;

    final polylines = _engine
        .getPolylines()
        .map((line) {
          return line
              .map(
                (p) => Offset(p.dx * scale + offsetX, p.dy * scale + offsetY),
              )
              .toList(growable: false);
        })
        .toList(growable: false);

    return Stack(
      children: [
        Positioned.fill(
          child: SvgPicture.asset(
            widget.circuitAsset,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        Positioned.fill(child: CustomPaint(painter: _TrackPainter(polylines))),
        Positioned.fill(
          child: CustomPaint(painter: _DotsPainter(polylines, _distance)),
        ),
      ],
    );
  }
}

class _TrackPainter extends CustomPainter {
  final List<List<Offset>> lines;
  _TrackPainter(this.lines);

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    for (final pts in lines) {
      if (pts.length < 2) continue;
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrackPainter oldDelegate) => false;
}

class _DotsPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final double distance; // px progressed along the first polyline (demo)

  _DotsPainter(this.lines, this.distance);

  @override
  void paint(Canvas canvas, Size size) {
    if (lines.isEmpty) return;

    final line = lines.first;
    if (line.length < 2) return;

    // compute total length and draw one moving dot
    double total = 0;
    final segLens = <double>[];
    for (int i = 0; i < line.length - 1; i++) {
      final l = (line[i + 1] - line[i]).distance;
      segLens.add(l);
      total += l;
    }
    if (total <= 0) return;

    double d = distance % total;
    Offset pos = line.first;
    for (int i = 0; i < segLens.length; i++) {
      final l = segLens[i];
      if (d <= l) {
        final t = d / l;
        pos = Offset.lerp(line[i], line[i + 1], t)!;
        break;
      }
      d -= l;
    }

    final dot = Paint()..color = Colors.yellowAccent;
    canvas.drawCircle(pos, 5, dot);
  }

  @override
  bool shouldRepaint(covariant _DotsPainter oldDelegate) =>
      oldDelegate.distance != distance || oldDelegate.lines != lines;
}
