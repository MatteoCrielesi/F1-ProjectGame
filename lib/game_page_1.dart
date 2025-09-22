import 'dart:async';
import 'package:f1_project/game/saves/game_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game/screens/game_screen.dart';
import 'game/models/circuit.dart';
import 'game/models/car.dart';
import 'game/controllers/game_controller.dart';
import 'start_lights.dart';

class GamePage_1 extends StatefulWidget {
  const GamePage_1({super.key});

  @override
  State<GamePage_1> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage_1> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentPage = 0;
  Circuit? _selectedCircuit;
  CarModel? _selectedTeam;
  bool _teamSelected = false;
  GameController? _preloadController;
  Future<void>? _preloadFuture;
  bool _timerRunning = false;
  int _elapsedCentis = 0;
  Timer? _countdownTimer;
  int? _lastSelectedIndex;

  final GlobalKey<GameScreenState> _gameScreenKey =
      GlobalKey<GameScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = _pageController.initialPage;
      });
    });
  }

  Future<void> _preloadCircuit(Circuit circuit) async {
    _preloadController = GameController(
      circuit: circuit,
      carModel: _selectedTeam ?? allCars.first,
    );
    await _preloadController!.loadTrackFromJson();
  }

  void _startTimer() {
    if (!mounted) return;

    _countdownTimer?.cancel();
    _elapsedCentis = 0;
    _timerRunning = true;

    _gameScreenKey.currentState?.respawnCarAndReset();

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted || _gameScreenKey.currentState == null) {
        timer.cancel();
        return;
      }

      setState(() => _elapsedCentis++);

      if (_gameScreenKey.currentState!.controller.disqualified) {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (!mounted) return;

    try {
      setState(() {
        _timerRunning = false;
      });
    } catch (e) {
      debugPrint("setState ignorato: $e");
    }

    final gameScreenState = _gameScreenKey.currentState;
    if (gameScreenState != null && gameScreenState.mounted) {
      gameScreenState.onStopTimer();
    }
  }

  void _resetGame() {
    _stopTimer();
    _elapsedCentis = 0;
    _gameScreenKey.currentState?.resetGame();
  }

  @override
  void dispose() {
    _stopTimer();
    _preloadController?.waitingForStart = true;
    _preloadController?.disposeController();
    _preloadController?.stop();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double centralWidgetWidth = 200;
    const double centralWidgetHeight = 40;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 71, 71, 71),
                  Color.fromARGB(255, 71, 0, 0),
                  Color.fromARGB(255, 33, 0, 0),
                ],
              ),
            ),
          ),
          // Red top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Color(0xFFE10600)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔝 Top bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    isPortrait ? 14 : 1,
                    16,
                    isPortrait ? 10 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lato sinistro: back + logo + titolo
                      Row(
                        children: [
                          if (_selectedCircuit != null)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white10,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(8),
                                minimumSize: const Size(36, 36),
                              ),
                              onPressed: () {
                                _resetGame();
                                if (_teamSelected) {
                                  setState(() {
                                    _teamSelected = false;
                                    _selectedTeam = null;
                                  });
                                } else {
                                  _lastSelectedIndex = allCircuits.indexOf(
                                    _selectedCircuit!,
                                  );
                                  setState(() {
                                    _selectedCircuit = null;
                                    _currentPage = _lastSelectedIndex!;
                                  });
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _pageController.jumpToPage(
                                      _lastSelectedIndex!,
                                    );
                                  });
                                }
                              },
                              child: const Icon(Icons.arrow_back, size: 20),
                            ),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/f1_logo.svg', height: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Formula 1',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),

                      // Lato destro: pulsante record
                      if (_selectedCircuit == null)
                        FutureBuilder(
                          future: GameRecords.get(allCircuits[_currentPage].id),
                          builder: (context, snapshot) {
                            final hasData =
                                snapshot.hasData && snapshot.data != null;
                            return GestureDetector(
                              onTap: () {
                                if (!hasData) return;
                                final records = snapshot.data!;
                                final bestLap = records['bestLap'] ?? 0;
                                final bestGame = records['bestGame'] ?? 0;

                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: Colors.black87,
                                    title: Text(
                                      allCircuits[_currentPage].displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Giro più veloce: ${_formatTime(bestLap)}',
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Game più veloce: ${_formatTime(bestGame)}',
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text(
                                          'Chiudi',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white10,
                                ),
                                child: const Icon(
                                  Icons.star,
                                  size: 20,
                                  color: Colors.yellow,
                                ),
                              ),
                            );
                          },
                        ),

                      // 👉 Solo in orizzontale: start/timer accanto al titolo
                      if (!isPortrait && _selectedCircuit != null)
                        SizedBox(
                          width: centralWidgetWidth,
                          height: centralWidgetHeight,
                          child: _teamSelected
                              ? !_timerRunning
                                    ? StartLights(
                                        showStartButton: true,
                                        onSequenceComplete: () {
                                          if (_gameScreenKey
                                                  .currentState
                                                  ?.mounted ??
                                              false) {
                                            _gameScreenKey.currentState!
                                                .startGame();
                                          }
                                          _startTimer();
                                        },
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                        child: Text(
                                          _formatTime(_elapsedCentis),
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontFamily: 'monospace',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                              : const SizedBox.shrink(),
                        ),
                    ],
                  ),
                ),

                // 👇 Solo in verticale: start/timer + nome circuito
                if (isPortrait && _selectedCircuit != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: centralWidgetWidth,
                          height: centralWidgetHeight,
                          child: _teamSelected
                              ? !_timerRunning
                                    ? StartLights(
                                        showStartButton: true,
                                        onSequenceComplete: () {
                                          if (_gameScreenKey
                                                  .currentState
                                                  ?.mounted ??
                                              false) {
                                            _gameScreenKey.currentState!
                                                .startGame();
                                          }
                                          _startTimer();
                                        },
                                      )
                                    : Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.06),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                        child: Text(
                                          _formatTime(_elapsedCentis),
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontFamily: 'monospace',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      )
                              : const SizedBox.shrink(),
                        ),
                        Text(
                          _selectedCircuit?.displayName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),
                Expanded(child: _buildContentArea(context)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea(BuildContext context) {
    if (_selectedCircuit == null) {
      // Circuit selection
      return Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection:
                MediaQuery.of(context).orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            itemCount: allCircuits.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final circuit = allCircuits[index];
              final double scale = (_currentPage == index) ? 1.0 : 0.85;
              return AnimatedScale(
                scale: scale,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCircuit = circuit;
                      _currentPage = index;
                      _preloadFuture = _preloadCircuit(circuit);
                    });
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      color: const Color.fromARGB(120, 255, 6, 0),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 6),
                          Text(
                            circuit.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SvgPicture.asset(circuit.svgPath),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      );
    } else if (!_teamSelected) {
      // Team selection
      return Stack(
        children: [
          if (_preloadFuture != null)
            FutureBuilder(
              future: _preloadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _BackgroundTrackPainter(
                      _preloadController!.trackPoints,
                      _selectedCircuit!,
                    ),
                  );
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          Container(
            color: Colors.black54,
            child: Center(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: allCars.map((car) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _teamSelected = true;
                        _selectedTeam = car;
                      });
                    },
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                        color: car.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (car.logoPath.isNotEmpty)
                            SizedBox(
                              height: 50,
                              child: Image.asset(
                                car.logoPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            car.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      );
    } else {
      // Game active
      return GameScreen(
        key: _gameScreenKey,
        circuit: _selectedCircuit!,
        car: _selectedTeam!,
        elapsedCentis: _elapsedCentis,
        onGameFinished: (lapTimes) {},
      );
    }
  }

  String _formatTime(int centis) {
    final minutes = centis ~/ 6000;
    final seconds = (centis % 6000) ~/ 100;
    final cs = centis % 100;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }
}

class _BackgroundTrackPainter extends CustomPainter {
  final List<Offset> points;
  final Circuit circuit;

  _BackgroundTrackPainter(this.points, this.circuit);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final scaleX = size.width / circuit.viewBoxWidth;
    final scaleY = size.height / circuit.viewBoxHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX =
        (size.width - circuit.viewBoxWidth * scale) / 2 -
        circuit.viewBoxX * scale;
    final offsetY =
        (size.height - circuit.viewBoxHeight * scale) / 2 -
        circuit.viewBoxY * scale;

    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(
        points.first.dx * scale + offsetX,
        points.first.dy * scale + offsetY,
      );
    for (final p in points.skip(1)) {
      path.lineTo(p.dx * scale + offsetX, p.dy * scale + offsetY);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
