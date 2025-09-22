import 'dart:math';
import 'package:f1_project/game_page_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../widgets/game_controls.dart';
import '../controllers/game_bot_controller.dart'; // import controller dei bot

class GameScreenBot extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;
  final bool showTouchControls;
  final void Function(List<int> lapTimes)? onGameFinished;
  final int elapsedCentis;
  final GameBotController? botController; // controller bot opzionale

  const GameScreenBot({
    super.key,
    required this.circuit,
    required this.car,
    this.showTouchControls = true,
    this.onGameFinished,
    required this.elapsedCentis,
    this.botController,
  });

  @override
  State<GameScreenBot> createState() => GameScreenBotState();
}

class GameScreenBotState extends State<GameScreenBot> {
  late GameController controller;
  late GameBotController? botController;
  int _lastLapCentis = 0;
  final List<int> _lapTimes = [];
  Orientation? _currentOrientation;
  bool _gameStarted = false;

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);
    botController = widget.botController;
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadTrackFromJson();
    botController?.initBots();
    setState(() {});
  }

  void startGame() {
    if (!mounted) return;
    _gameStarted = true;
    controller.disqualified = false;
    _respawnCarAndReset();
    controller.start();
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
    botController?.initBots();
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
    controller.debugPrintState("_respawnCarAndReset");
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

  bool _isPhone(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
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

    final isPhone = _isPhone(context);
    final isDesktop = !isPhone;

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
        return Row(
          children: [
            // BARRA LATERALE PARTECIPANTI
            Container(
              width: 150,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.car.name,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (botController != null)
                    ...botController!.bots.map(
                      (bot) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          bot.disqualified
                              ? "${bot.color} (DQ)"
                              : bot.color.toString(),
                          style: TextStyle(color: bot.color),
                        ),
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

            // CONTROLLI TOUCH
            if (widget.showTouchControls)
              Container(
                width: 100,
                padding: const EdgeInsets.all(12),
                child: GameControls(
                  controller: controller,
                  controlsEnabled: _gameStarted && !controller.disqualified,
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
        final isSmallScreen = screenHeight < 500;

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
                        controlsEnabled:
                            _gameStarted && !controller.disqualified,
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
                  bots: botController?.bots,
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
                                builder: (_) =>
                                    const GamePage_1(selectedType: 'challenge'),
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
  final List<BotCar>? bots; // lista dei bot da disegnare

  _TrackPainter(
    this.points,
    this.spawnPoint,
    this.carPosition,
    this.circuit,
    this.car, {
    this.bots,
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

    // TRACK
    final trackPaint = Paint()
      ..color = const Color.fromARGB(255, 78, 78, 78)
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

    // SPAWN
    if (spawnPoint != null) {
      final spawnPaint = Paint()..color = Colors.red;
      canvas.drawCircle(
        Offset(
          spawnPoint!.dx * scale + offsetX,
          spawnPoint!.dy * scale + offsetY,
        ),
        5,
        spawnPaint,
      );
    }

    // PLAYER CAR
    final playerPaint = Paint()..color = car.color;
    canvas.drawCircle(
      Offset(
        carPosition.dx * scale + offsetX,
        carPosition.dy * scale + offsetY,
      ),
      8,
      playerPaint,
    );

    // BOTS
    if (bots != null) {
      for (var bot in bots!) {
        if (bot.disqualified) continue;
        final botPaint = Paint()..color = bot.color;
        canvas.drawCircle(
          Offset(
            bot.position.dx * scale + offsetX,
            bot.position.dy * scale + offsetY,
          ),
          6,
          botPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
