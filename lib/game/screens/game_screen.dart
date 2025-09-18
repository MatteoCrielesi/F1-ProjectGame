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
  final bool showTouchControls;
  final void Function(List<int> lapTimes)? onGameFinished; // callback verso GamePage_1

  const GameScreen({
    super.key,
    required this.circuit,
    required this.car,
    this.showTouchControls = true,
    this.onGameFinished,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  int? _countdown;
  bool _isTimerRunning = false;
  int _elapsedCentis = 0;
  int _lastLapCentis = 0;
  final List<int> _lapTimes = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);

    // Gestione lap completati dal GameController
    controller.onLapCompleted = (lap) {
      final lapTime = _elapsedCentis - _lastLapCentis;
      _lastLapCentis = _elapsedCentis;

      setState(() {
        _lapTimes.add(lapTime); // aggiorna la sidebar
      });

      // Notifica GamePage_1
      if (widget.onGameFinished != null) {
        widget.onGameFinished!(_lapTimes);
      }

      // interrompe il timer se sono completati 5 giri
      if (_lapTimes.length >= 5) {
        _stopTimer();
      }
    };

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
      _lastLapCentis = 0;
      _lapTimes.clear();
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

  String _formatTime(int centis) {
    final ms = (centis % 100).toString().padLeft(2, '0');
    final seconds = ((centis ~/ 100) % 60).toString().padLeft(2, '0');
    final minutes = (centis ~/ 6000).toString().padLeft(2, '0');
    return "$minutes:$seconds:$ms";
  }

  @override
  void dispose() {
    _timer?.cancel();
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalTime = _lapTimes.isNotEmpty
        ? _lapTimes.reduce((a, b) => a + b)
        : _elapsedCentis;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 3, color: const Color(0xFFE10600)),
            Expanded(
              child: Row(
                children: [
                  // SIDEBAR LAP TIMES
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
                                for (int i = 0; i < 5; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Text(
                                      "Lap ${i + 1}   Time: ${i < _lapTimes.length ? _formatTime(_lapTimes[i]) : "--:--:--"}",
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
                  // TRACK + CONTROLS
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
                                    widget.car,
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

    final offsetX = (canvasWidth - circuit.viewBoxWidth * scale) / 2 - circuit.viewBoxX * scale;
    final offsetY = (canvasHeight - circuit.viewBoxHeight * scale) / 2 - circuit.viewBoxY * scale;

    final trackPaint = Paint()
      ..color = Colors.yellow
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(points.first.dx * scale + offsetX, points.first.dy * scale + offsetY);
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
