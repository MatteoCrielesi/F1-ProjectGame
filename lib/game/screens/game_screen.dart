// screen_game.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import 'package:flutter/services.dart';
import '../widgets/game_controls.dart'; // Importa il nuovo widget dei comandi

class GameScreen extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;
  final bool showTouchControls;

  const GameScreen({
    super.key,
    required this.circuit,
    required this.car,
    this.showTouchControls = true,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  int? _countdown;
  bool _isTimerRunning = false;
  int _elapsedCentis = 0;
  Timer? _timer;
  final Set<LogicalKeyboardKey> _pressedKeys = {};

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

  void _startCountdown() {
    if (_countdown != null || _isTimerRunning) return;
    setState(() => _countdown = 3);

    Timer.periodic(const Duration(seconds: 1), (tick) {
      if (!mounted) return;
      setState(() {
        if (_countdown == null) {
          tick.cancel();
        } else if (_countdown! <= 1) {
          _countdown = null;
          tick.cancel();
          _startTimer();
        } else {
          _countdown = _countdown! - 1;
        }
      });
    });
  }

  void _startTimer() {
    if (_isTimerRunning) return;
    setState(() {
      _isTimerRunning = true;
      _elapsedCentis = 0;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (!mounted) return;
      setState(() => _elapsedCentis += 1);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isTimerRunning = false);
  }

  int getLapsForPlayer(int index) => (index % 5) + 1;

  @override
  void dispose() {
    _timer?.cancel();
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 3, color: const Color(0xFFE10600)),
            Expanded(
              child: Row(
                children: [
                  // LEFT SIDEBAR
                  SizedBox(
                    width: 170,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Classifica',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: 10,
                                      itemBuilder: (context, index) {
                                        final car =
                                            allCars[index % allCars.length];
                                        final laps = getLapsForPlayer(index);
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 4,
                                          ),
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: 26,
                                                child: Text(
                                                  '${index + 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Container(
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: car.color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                      ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (car
                                                          .logoPath
                                                          .isNotEmpty)
                                                        SizedBox(
                                                          width: 26,
                                                          height: 26,
                                                          child: Image.asset(
                                                            car.logoPath,
                                                            fit: BoxFit.contain,
                                                          ),
                                                        ),
                                                      Text(
                                                        '$laps/5',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // MAIN TRACK AREA + CONTROLS
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          final maxHeight = constraints.maxHeight;

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: SvgPicture.asset(
                                  widget.circuit.svgPath,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Positioned.fill(
                                child: CustomPaint(
                                  size: Size(maxWidth, maxHeight),
                                  painter: _TrackPainter(
                                    controller.trackPoints,
                                    controller.spawnPoint,
                                    controller.carPosition,
                                    widget.circuit,
                                    canvasWidth: maxWidth,
                                    canvasHeight: maxHeight,
                                  ),
                                ),
                              ),
                              if (_countdown != null)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.35),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$_countdown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 120,
                                      ),
                                    ),
                                  ),
                                ),
                              // Controlli touch / mobile
                              if (widget.showTouchControls)
                                Positioned(
                                  bottom: 24,
                                  right: 24,
                                  child: GameControls(
                                    controller: controller,
                                    controlsEnabled: false,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
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
    this.circuit, {
    required this.canvasWidth,
    required this.canvasHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final scaleX = canvasWidth / circuit.viewBoxWidth;
    final scaleY = canvasHeight / circuit.viewBoxHeight;
    final scale = min(scaleX, scaleY);

    final offsetX =
        (canvasWidth - circuit.viewBoxWidth * scale) / 2 -
        circuit.viewBoxX * scale;
    final offsetY =
        (canvasHeight - circuit.viewBoxHeight * scale) / 2 -
        circuit.viewBoxY * scale;

    final trackPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(
        points.first.dx * scale + offsetX,
        points.first.dy * scale + offsetY,
      );
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * scale + offsetX, p.dy * scale + offsetY);
    }
    canvas.drawPath(path, trackPaint);

    if (spawnPoint != null) {
      final spawnPaint = Paint()..color = Colors.red;
      const spawnRadius = 5.0;
      final sx = spawnPoint!.dx * scale + offsetX;
      final sy = spawnPoint!.dy * scale + offsetY;
      canvas.drawCircle(Offset(sx, sy), spawnRadius, spawnPaint);
    }

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
