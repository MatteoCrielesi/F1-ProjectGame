import 'dart:math';
import 'package:f1_project/game/saves/game_records.dart';
import 'package:f1_project/game/screens/game_screen.dart' as _keyFocusNode;
import 'package:f1_project/game_page_0.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final int elapsedCentis;
  final void Function(bool crash, bool victory)? onGameStateChanged;

  const GameScreen({
    super.key,
    required this.circuit,
    required this.car,
    this.showTouchControls = true,
    this.onGameFinished,
    required this.elapsedCentis,
    this.onGameStateChanged,
  });

  @override
  State<GameScreen> createState() => GameScreenState();
}

class GameScreenState extends State<GameScreen> {
  bool _raceFinished = false;
  bool _crashState = false;
  late GameController controller;
  int _lastLapCentis = 0;
  final List<int> _lapTimes = [];
  Orientation? _currentOrientation;
  bool _gameStarted = false;
  final FocusNode _keyFocusNode = FocusNode();
  final Set<LogicalKeyboardKey> _pressedKeys = {};

  void _notifyGameState() {
    widget.onGameStateChanged?.call(_crashState, _raceFinished);
  }

  // ✅ Modifica: variabile normale con valore di default
  String _selectedMode = 'challenge';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String) {
      _selectedMode = args; // riassegnabile senza LateInitializationError
    }
  }

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);

    controller.onLapCompleted = _handleLapCompleted;

    controller.addListener(() {
      if (controller.disqualified && !_crashState) {
        setState(() {
          _crashState = true;
        });
        _notifyGameState();
      }
    });

    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadTrackFromJson();
  }

  Future<void> _printSavedRecords() async {
    final records = await GameRecords.get(widget.circuit.id);
    if (records.isNotEmpty) {
      final bestLap = records['bestLap'] ?? 0;
      final bestGame = records['bestGame'] ?? 0;
      print("[DEBUG] Records salvati per ${widget.circuit.displayName}:");
      print("  Miglior Lap: ${_formatTime(bestLap)}");
      print("  Miglior Game: ${_formatTime(bestGame)}");
    }
  }

  void _handleLapCompleted(int lap) async {
    final lapTime = widget.elapsedCentis - _lastLapCentis;
    _lastLapCentis = widget.elapsedCentis;

    setState(() {
      _lapTimes.add(lapTime);
    });

    await GameRecords.save(widget.circuit.id, lapTime, null);
    await _printSavedRecords();

    if (_lapTimes.length == 3) {
      final totalTime = _lapTimes.reduce((a, b) => a + b);
      final bestLapTime = _lapTimes.reduce((a, b) => a < b ? a : b);
      final bestLapIndex = _lapTimes.indexOf(bestLapTime) + 1;

      await GameRecords.save(widget.circuit.id, bestLapTime, totalTime);

      if (_selectedMode == 'challenge') {
        setState(() {
          _raceFinished = true;
          _crashState = false;
          controller.stop();
        });
        _notifyGameState();
      }

      widget.onGameFinished?.call(_lapTimes);
    } else {
      widget.onGameFinished?.call(_lapTimes);
    }
  }

  void startGame() {
    if (!mounted) return;
    _gameStarted = true;
    controller.disqualified = false;
    _crashState = false;
    _raceFinished = false;
    _respawnCarAndReset();
    controller.start();
    _notifyGameState();
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
    controller.onLapCompleted = _handleLapCompleted;

    _lastLapCentis = 0;
    _lapTimes.clear();
    _raceFinished = false;
    _crashState = false;

    controller.addListener(() {
      if (controller.disqualified && !_crashState) {
        setState(() {
          _crashState = true;
        });
        _notifyGameState();
      }
    });

    _initGame();
    _notifyGameState();
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
    _crashState = false;
    controller.debugPrintState("_respawnCarAndReset");
  }

  String _formatTime(int centis) {
    final ms = (centis % 100).toString().padLeft(2, '0');
    final seconds = ((centis ~/ 100) % 60).toString().padLeft(2, '0');
    final minutes = (centis ~/ 6000).toString();
    return "$minutes:$seconds:$ms";
  }

  @override
  void dispose() {
    // Dispose del FocusNode usato dal RawKeyboardListener per evitare leak
    _keyFocusNode.dispose();
    controller.disposeController();
    super.dispose();
  }

  bool _isPhone(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
  }

  void _handleKey(RawKeyEvent ev) {
    // Gestione input tastiera per Web/Desktop
    final key = ev.logicalKey;
    final isDown = ev is RawKeyDownEvent;

    if (isDown) {
      _pressedKeys.add(key);
    } else {
      _pressedKeys.remove(key);
    }

    // Aggiorna stati dei controlli
    final accel =
        _pressedKeys.contains(LogicalKeyboardKey.arrowUp) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyW);
    final brake =
        _pressedKeys.contains(LogicalKeyboardKey.arrowDown) ||
        _pressedKeys.contains(LogicalKeyboardKey.keyS);

    if (controller.acceleratePressed != accel ||
        controller.brakePressed != brake) {
      setState(() {
        controller.acceleratePressed = accel;
        controller.brakePressed = brake;
      });
    }
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

    final bestLapTime = _lapTimes.isNotEmpty
        ? _lapTimes.reduce((a, b) => a < b ? a : b)
        : 0;
    final bestLapIndex = _lapTimes.isNotEmpty
        ? _lapTimes.indexOf(bestLapTime) + 1
        : 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RawKeyboardListener(
        focusNode: _keyFocusNode,
        autofocus: true,
        onKey: _handleKey,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: orientation == Orientation.landscape
                        ? _buildLandscapeLayout(totalTime, isDesktop)
                        : _buildPortraitLayout(totalTime, context, isDesktop),
                  ),
                ],
              ),
              if (controller.disqualified) _buildCrashMask(),
              if (_raceFinished && _selectedMode == 'challenge')
                _buildVictoryMask(bestLapIndex, bestLapTime),
            ],
          ),
        ),
      ),
    );
  }

  // --- Maschere e UI ---
  Widget _buildCrashMask() {
    return Positioned.fill(
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
              onPressed: () => resetGame(),
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
                          const GamePage_0(selectedType: 'challenge'),
                    ),
                  );
                });
              },
              child: const Text("Torna alla scelta pista"),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     resetGame();
            //     WidgetsBinding.instance.addPostFrameCallback((_) {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (_) => const DashboardPage()),
            //       );
            //     });
            //   },
            //   child: const Text("Torna alla dashboard"),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildVictoryMask(int bestLapIndex, int bestLapTime) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Congratulazioni!\nHai completato i 3 giri!",
              style: TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_lapTimes.isNotEmpty)
              Text(
                "Miglior Giro: Lap $bestLapIndex: ${_formatTime(bestLapTime)}",
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // Comportamento uguale a "Riprova": resetta e resta in pista
                resetGame();
              },
              child: const Text("Riscendi in pista"),
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
                          const GamePage_0(selectedType: 'challenge'),
                    ),
                  );
                });
              },
              child: const Text("Torna alla scelta pista"),
            ),
            const SizedBox(height: 12),
            // ElevatedButton(
            //   onPressed: () {
            //     resetGame();
            //     WidgetsBinding.instance.addPostFrameCallback((_) {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (_) => const DashboardPage()),
            //       );
            //     });
            //   },
            //   child: const Text("Torna alla dashboard"),
            // ),
          ],
        ),
      ),
    );
  }

  // --- Layout Landscape e Portrait ---
  Widget _buildLandscapeLayout(int totalTime, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            isDesktop
                ? Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    child: _buildLapTable(totalTime),
                  )
                : Container(
                    width: 160,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.circuit.displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (widget.car.logoPath.isNotEmpty)
                          Image.asset(
                            widget.car.logoPath,
                            width: 50,
                            height: 50,
                            fit: BoxFit.contain,
                          ),
                        const SizedBox(height: 16),
                        if (_lapTimes.isNotEmpty)
                          Text(
                            'Last Lap: ${_formatTime(_lapTimes.last)}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          )
                        else
                          const Text(
                            'Last Lap: --:--:--',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Total: ${_formatTime(totalTime)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTrackWithOverlays(),
              ),
            ),
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
                          'Laps: ${_lapTimes.length}/3',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  if (isDesktop)
                    Row(children: [Expanded(child: _buildLapTable(totalTime))]),
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
          // Nome pista
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.circuit.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (widget.car.logoPath.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Image.asset(
                widget.car.logoPath,
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                // Nella scheda tempi:
                // - McLaren e Sauber/Kick Sauber usano il colore della scuderia
                // - Alpine usa un azzurro del logo, leggermente più chiaro di Williams
                color: widget.car.name == "Alpine"
                    ? const Color.fromARGB(255, 0, 120, 255)
                    : (widget.car.name == "McLaren" ||
                          widget.car.name == "Sauber" ||
                          widget.car.name == "Kick Sauber")
                    ? widget.car.color
                    : null,
                colorBlendMode:
                    (widget.car.name == "McLaren" ||
                        widget.car.name == "Alpine" ||
                        widget.car.name == "Sauber" ||
                        widget.car.name == "Kick Sauber")
                    ? BlendMode.srcIn
                    : null,
              ),
            ),
          for (int i = 0; i < 3; i++)
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

  Widget _buildTrackWithOverlays() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        return RepaintBoundary(
          child: Stack(
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
            ],
          ),
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

    if (spawnPoint != null) {
      final spawnPaint = Paint()..color = Colors.red;
      const spawnRadius = 5.0;
      final sx = spawnPoint!.dx * scale + offsetX;
      final sy = spawnPoint!.dy * scale + offsetY;
      canvas.drawCircle(Offset(sx, sy), spawnRadius, spawnPaint);
    }

    if (carPosition != Offset.zero) {
      final carPaint = Paint()
        ..color = car.color
        ..style = PaintingStyle.fill;
      final px = carPosition.dx * scale + offsetX;
      final py = carPosition.dy * scale + offsetY;
      canvas.drawCircle(Offset(px, py), 8.0, carPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// (rimosso) override di dispose fuori dalla classe
