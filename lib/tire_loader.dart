import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class TireLoader extends StatefulWidget {
  final double size;
  final int rotationPeriodMs;
  final int colorChangePeriodMs;

  const TireLoader({
    super.key,
    this.size = 100,
    this.rotationPeriodMs = 1200,
    this.colorChangePeriodMs = 1000,
  });

  @override
  State<TireLoader> createState() => _TireLoaderState();
}

class _TireLoaderState extends State<TireLoader> with TickerProviderStateMixin {
  late final AnimationController _rotation;
  late Timer _colorTimer;
  int _colorIndex = 0;

  static const List<Color> sidewallColors = <Color>[
    Color(0xFF00AEEF), // Blue
    Color(0xFF00A75D), // Green
    Color(0xFFFFFFFF), // White
    Color(0xFFFFD100), // Yellow
    Color(0xFFFF1E00), // Red
  ];

  @override
  void initState() {
    super.initState();
    _rotation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.rotationPeriodMs),
    )..repeat();

    _colorTimer = Timer.periodic(
      Duration(milliseconds: widget.colorChangePeriodMs),
      (_) => setState(() => _colorIndex = (_colorIndex + 1) % sidewallColors.length),
    );
  }

  @override
  void dispose() {
    _rotation.dispose();
    _colorTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = sidewallColors[_colorIndex];
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _rotation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _rotation.value * 2 * math.pi,
            child: CustomPaint(
              painter: _TirePainter(color),
            ),
          );
        },
      ),
    );
  }
}

class _TirePainter extends CustomPainter {
  final Color highlight;

  _TirePainter(this.highlight);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final outer = radius;
    final inner = radius * 0.55;
    final hub = radius * 0.22;
    final treadStroke = radius * 0.35;
    final highlightStroke = radius * 0.08;

    final blackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = treadStroke
      ..color = Colors.black;

    final darkGrey = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF3E3E3E);

    final lightGrey = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.035
      ..color = const Color(0xFFBFBFBF);

    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = highlightStroke
      ..color = highlight;

    // Tire sidewall
    canvas.drawCircle(center, (outer - treadStroke / 1.1), blackPaint);

    // Highlight band
    final arcRect = Rect.fromCircle(center: center, radius: outer - treadStroke * 0.9);
    const arcSweep = math.pi * 1.2;
    canvas.drawArc(arcRect, -math.pi * 0.1, arcSweep, false, highlightPaint);

    // Rim
    canvas.drawCircle(center, inner, darkGrey);

    // Rim spokes
    final spokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.04
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF9E9E9E);
    const spokes = 8;
    for (int i = 0; i < spokes; i++) {
      final angle = (2 * math.pi / spokes) * i;
      final p1 = center + Offset(math.cos(angle), math.sin(angle)) * (inner * 0.25);
      final p2 = center + Offset(math.cos(angle), math.sin(angle)) * (inner * 0.9);
      canvas.drawLine(p1, p2, spokePaint);
    }

    // Hub ring detail
    canvas.drawCircle(center, hub, lightGrey);

    // Small lug holes
    final lugPaint = Paint()..color = Colors.black;
    const lugs = 5;
    for (int i = 0; i < lugs; i++) {
      final a = (2 * math.pi / lugs) * i;
      final p = center + Offset(math.cos(a), math.sin(a)) * (hub * 1.4);
      canvas.drawCircle(p, radius * 0.035, lugPaint);
    }
  }

  @override
  bool shouldRepaint(_TirePainter oldDelegate) => oldDelegate.highlight != highlight;
}
