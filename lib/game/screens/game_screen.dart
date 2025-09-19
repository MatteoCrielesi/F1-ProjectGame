import 'dart:math';
import 'package:f1_project/dashboard.dart';
import 'package:f1_project/game_page_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;
  final bool showTouchControls;
  final void Function(List<int> lapTimes)? onGameFinished;
  final int elapsedCentis; // riceve timer da GamePage_1

  const GameScreen({
    super.key,
    required this.circuit,
    required this.car,
    this.showTouchControls = true,
    this.onGameFinished,
    required this.elapsedCentis,
  });

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  late GameController controller;
  int _lastLapCentis = 0;
  final List<int> _lapTimes = [];

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);

    controller.onLapCompleted = (lap) {
      final lapTime = widget.elapsedCentis - _lastLapCentis;
      _lastLapCentis = widget.elapsedCentis;
      setState(() {
        _lapTimes.add(lapTime);
      });

      if (widget.onGameFinished != null) {
        widget.onGameFinished!(_lapTimes);
      }
    };

    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadTrackFromJson();
    controller.start();
  }

  void startGame() {
    if (!mounted) return;
    _respawnCarAndReset();
  }

  void respawnCar() {
    if (!mounted) return;
    controller.respawn();
  }

  void respawnCarAndReset() {
    if (!mounted) return;
    _respawnCarAndReset();
  }

  void resetGame() {
    if (!mounted) return;

    // Dispose del vecchio controller
    controller.disposeController();

    // Ricrea controller nuovo
    controller = GameController(circuit: widget.circuit, carModel: widget.car);

    controller.onLapCompleted = (lap) {
      final lapTime = widget.elapsedCentis - _lastLapCentis;
      _lastLapCentis = widget.elapsedCentis;
      setState(() {
        _lapTimes.add(lapTime);
      });

      if (widget.onGameFinished != null) {
        widget.onGameFinished!(_lapTimes);
      }
    };

    // Ripristina variabili
    _lastLapCentis = 0;
    _lapTimes.clear();

    // Carica la pista e avvia
    _initGame();

    setState(() {});
  }

  void onStopTimer() {
    // eventuali azioni da fare quando GamePage ferma il timer
    if (!mounted) return;
    setState(() {});
  }

  void _respawnCarAndReset() {
    controller.respawn();
    _lastLapCentis = 0;
    _lapTimes.clear();
  }

  String _formatTime(int centis) {
    final ms = (centis % 100).toString().padLeft(2, '0');
    final seconds = ((centis ~/ 100) % 60).toString().padLeft(2, '0');
    final minutes = (centis ~/ 6000).toString().padLeft(2, '0');
    return "$minutes:$seconds:$ms";
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTime = _lapTimes.isNotEmpty
        ? _lapTimes.reduce((a, b) => a + b)
        : widget.elapsedCentis;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 3, color: const Color(0xFFE10600)),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (widget.car.logoPath.isNotEmpty)
                                  Center(
                                    child: Image.asset(
                                      widget.car.logoPath,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                for (int i = 0; i < _lapTimes.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      "Lap ${i + 1}   Time: ${_formatTime(_lapTimes[i])}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                for (int i = _lapTimes.length; i < 5; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      "Lap ${i + 1}   Time: --:--:--",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const Divider(color: Colors.white24),
                                Text(
                                  "Total Time: ${_formatTime(totalTime)}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: controller,
                      builder: (context, _) {
                        return Padding(
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
                                        widget.car,
                                        canvasWidth: maxWidth,
                                        canvasHeight: maxHeight,
                                      ),
                                    ),
                                  ),
                                  if (controller.disqualified)
                                    Positioned.fill(
                                      child: Container(
                                        color: Colors.black.withOpacity(0.8),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Text(
                                              "Ti sei schiantato!",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 36,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            ElevatedButton(
                                              onPressed: () {
                                                resetGame();
                                              },
                                              child: const Text("Riprova"),
                                            ),
                                            const SizedBox(height: 12),
                                            ElevatedButton(
                                              onPressed: () {
                                                // 1. Ferma timer e resetta stato
                                                resetGame();

                                                // 2. Esegui la navigazione solo dopo che il frame corrente è completato
                                                WidgetsBinding.instance
                                                    .addPostFrameCallback((_) {
                                                      Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              const GamePage_1(),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: const Text(
                                                "Torna alla scelta pista",
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  if (widget.showTouchControls)
                                    Positioned(
                                      bottom: 24,
                                      right: 24,
                                      child: GameControls(
                                        controller: controller,
                                        controlsEnabled:
                                            !controller.disqualified,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        );
                      },
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
  final CarModel car;
  final double canvasWidth;
  final double canvasHeight;

  _TrackPainter(
    this.points,
    this.spawnPoint,
    this.carPosition,
    this.circuit,
    this.car, {
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
      final playerPaint = Paint()..color = car.color;
      final px = carPosition.dx * scale + offsetX;
      final py = carPosition.dy * scale + offsetY;
      canvas.drawCircle(Offset(px, py), 8.0, playerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
