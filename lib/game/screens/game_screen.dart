import 'dart:math';
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
  Orientation? _currentOrientation;

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

    controller.disposeController();

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

    _lastLapCentis = 0;
    _lapTimes.clear();

    _initGame();

    setState(() {});
  }

  void onStopTimer() {
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

    final orientation = MediaQuery.of(context).orientation;
    if (_currentOrientation != orientation) {
      _currentOrientation = orientation;
    }

    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Container(height: 3, color: const Color(0xFFE10600)),
            Expanded(
              child: orientation == Orientation.landscape
                  ? _buildLandscapeLayout(totalTime, isDesktop)
                  : _buildPortraitLayout(totalTime, context, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  // LANDSCAPE
  Widget _buildLandscapeLayout(int totalTime, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 500;

        return Row(
          children: [
            // INFO LAP TABLE O MOBILE
            isDesktop
                ? Container(
                    width: 200,
                    padding: const EdgeInsets.all(12),
                    child: _buildLapTable(totalTime),
                  )
                : Container(
                    width: 140,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              if (widget.car.logoPath.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: Image.asset(
                                    widget.car.logoPath,
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              Text(
                                _formatTime(totalTime),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              if (_lapTimes.isNotEmpty)
                                Text(
                                  'Last: ${_formatTime(_lapTimes.last)}',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: isSmallScreen ? 14 : 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 12),
                              Text(
                                'Laps: ${_lapTimes.length}/5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

            // TRACK
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTrackWithOverlays(),
              ),
            ),

            // CONTROLLI A DESTRA
            if (widget.showTouchControls)
              Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                child: GameControls(
                  controller: controller,
                  controlsEnabled: !controller.disqualified,
                  isLandscape: true,
                  isLeftSide: false,
                  showBothButtons: true,
                ),
              ),
          ],
        );
      },
    );
  }

  // PORTRAIT
  Widget _buildPortraitLayout(
    int totalTime,
    BuildContext context,
    bool isDesktop,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 600;

        return Column(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTrackWithOverlays(),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  if (!isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.car.logoPath.isNotEmpty)
                              Image.asset(
                                widget.car.logoPath,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total: ${_formatTime(totalTime)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_lapTimes.isNotEmpty)
                                  Text(
                                    'Last: ${_formatTime(_lapTimes.last)}',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: isSmallScreen ? 12 : 14,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'Laps: ${_lapTimes.length}/5',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  if (widget.showTouchControls)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: GameControls(
                        controller: controller,
                        controlsEnabled: !controller.disqualified,
                        isLandscape: false,
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // LAP TABLE PER DESKTOP
  Widget _buildLapTable(int totalTime) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          if (widget.car.logoPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.asset(
                widget.car.logoPath,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
          for (int i = 0; i < 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lap ${i + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    i < _lapTimes.length
                        ? _formatTime(_lapTimes[i])
                        : '--:--:--',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTime(totalTime),
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // TRACK + OVERLAYS
  Widget _buildTrackWithOverlays() {
    return LayoutBuilder(
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
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          resetGame();
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const GamePage_1(),
                              ),
                            );
                          });
                        },
                        child: const Text("Torna alla scelta pista"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
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
