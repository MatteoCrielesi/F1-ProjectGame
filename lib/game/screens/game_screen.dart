import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;

  const GameScreen({super.key, required this.circuit, required this.car});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadTrackFromJson();
    controller.start();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.circuit.displayName),
        backgroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final maxWidth = constraints.maxWidth;
                        final maxHeight = constraints.maxHeight;

                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // --- SVG circuito ---
                            SvgPicture.asset(
                              widget.circuit.svgPath,
                              fit: BoxFit.contain,
                              width: maxWidth,
                              height: maxHeight,
                            ),

                            // --- Track + Player ---
                            CustomPaint(
                              size: Size(maxWidth, maxHeight),
                              painter: _TrackPainter(
                                controller.trackPoints,
                                controller.spawnPoint,
                                controller.carPosition,
                                widget.circuit,
                                maxWidth,
                                maxHeight,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(8),
              child: GameControls(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrackPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? spawnPoint;
  final Offset carPosition;
  final Circuit circuit;
  final double canvasWidth;
  final double canvasHeight;

  _TrackPainter(
    this.points,
    this.spawnPoint,
    this.carPosition,
    this.circuit,
    this.canvasWidth,
    this.canvasHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    // --- Calcolo scaling & offset per viewBox ---
    final scaleX = canvasWidth / circuit.viewBoxWidth;
    final scaleY = canvasHeight / circuit.viewBoxHeight;
    final scale = min(scaleX, scaleY);

    final offsetX =
        (canvasWidth - circuit.viewBoxWidth * scale) / 2 -
        circuit.viewBoxX * scale;
    final offsetY =
        (canvasHeight - circuit.viewBoxHeight * scale) / 2 -
        circuit.viewBoxY * scale;

    // --- Disegno TRACK ---
    final trackPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(
      points.first.dx * scale + offsetX,
      points.first.dy * scale + offsetY,
    );
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * scale + offsetX, p.dy * scale + offsetY);
    }
    canvas.drawPath(path, trackPaint);

    // --- Disegno SPAWN POINT ---
    if (spawnPoint != null) {
      final spawnPaint = Paint()..color = Colors.red;
      final spawnRadius = 5.0;
      final sx = spawnPoint!.dx * scale + offsetX;
      final sy = spawnPoint!.dy * scale + offsetY;
      canvas.drawCircle(Offset(sx, sy), spawnRadius, spawnPaint);
    }

    // --- Disegno PLAYER CAR ---
    if (carPosition != Offset.zero) {
      final playerPaint = Paint()..color = Colors.blueAccent;
      final px = carPosition.dx * scale + offsetX;
      final py = carPosition.dy * scale + offsetY;
      canvas.drawCircle(Offset(px, py), 8.0, playerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
