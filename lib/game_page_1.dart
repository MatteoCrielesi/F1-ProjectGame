import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game/screens/game_screen.dart';
import 'game/models/circuit.dart';
import 'game/models/car.dart';
import 'dashboard.dart';
import 'game/controllers/game_controller.dart';
import 'start_lights.dart'; // importa il widget StartLights

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
  bool _timerRunning = false; // stato timer
  int _elapsedCentis = 0; // timer in centesimi
  Timer? _countdownTimer;
  int? _lastSelectedIndex; // salva l’indice dell’ultima pista scelta

  // GlobalKey per controllare GameScreen
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
      if (!mounted) {
        timer.cancel();
        return;
      }

      // Se GameScreen non esiste più, fermiamo il timer
      if (_gameScreenKey.currentState == null) {
        timer.cancel();
        return;
      }

      setState(() {
        _elapsedCentis++;
      });

      if (_gameScreenKey.currentState!.controller.disqualified) {
        _stopTimer();
      }
    });
  }

  void _stopTimer() {
    // Ferma il timer
    _countdownTimer?.cancel();
    _countdownTimer = null;

    if (!mounted) return;

    // Aggiorna stato principale solo se montato
    try {
      setState(() {
        _timerRunning = false;
      });
    } catch (e) {
      // Ignora errori se il widget non è più montato
      debugPrint("setState ignorato: $e");
    }

    // Aggiorna GameScreen solo se montato
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
    _pageController.dispose();
    _preloadController?.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double centralWidgetWidth = 200;
    const double centralWidgetHeight = 40;

    return Scaffold(
      body: Stack(
        children: [
          // gradient background
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
          // red top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: const Color(0xFFE10600)),
            child: Container(height: 3, color: const Color(0xFFE10600)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // logo + title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/f1_logo.svg', height: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Formula 1',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_selectedCircuit != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            minimumSize: const Size(40, 40),
                          ),
                          onPressed: () {
                            _resetGame();

                            if (_teamSelected) {
                              setState(() {
                                _teamSelected = false;
                                _selectedTeam = null;
                              });
                            } else if (_selectedCircuit != null) {
                              setState(() {
                                _lastSelectedIndex = allCircuits.indexOf(
                                  _selectedCircuit!,
                                );
                                _selectedCircuit = null;
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (_lastSelectedIndex != null) {
                                  _pageController.jumpToPage(
                                    _lastSelectedIndex!,
                                  );
                                  setState(
                                    () => _currentPage = _lastSelectedIndex!,
                                  );
                                }
                              });
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DashboardPage(),
                                ),
                              );
                            }
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
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
                  )
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white10,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.all(12),
                            minimumSize: const Size(40, 40),
                          ),
                          onPressed: () {
                            _resetGame();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardPage(),
                              ),
                            );
                          },
                          child: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),

                // CIRCUIT SELECTION
                if (_selectedCircuit == null)
                  Expanded(
  child: PageView.builder(
    controller: _pageController,
    scrollDirection: MediaQuery.of(context).orientation == Orientation.portrait
        ? Axis.vertical   // verticale su telefono
        : Axis.horizontal, // orizzontale su tablet/landscape
    itemCount: allCircuits.length,
    onPageChanged: (index) {
      setState(() => _currentPage = index);
    },
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
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                        child: SvgPicture.asset(
                          circuit.svgPath,
                        ),
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
)

                // TEAM SELECTION
                else if (!_teamSelected)
                  Expanded(
                    child: Stack(
                      children: [
                        if (_preloadFuture != null)
                          FutureBuilder(
                            future: _preloadFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                    child: Stack(
                      children: [
                        if (_preloadFuture != null)
                          FutureBuilder(
                            future: _preloadFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                    ),
                  )
                // GAME ACTIVE
                else
                  Expanded(
                    child: GameScreen(
                      key: _gameScreenKey,
                      circuit: _selectedCircuit!,
                      car: _selectedTeam!,
                      onGameFinished: (lapTimes) {
                        // callback opzionale
                      },
                      elapsedCentis: _elapsedCentis,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int centis) {
    final minutes = centis ~/ 6000;
    final seconds = (centis % 6000) ~/ 100;
    final cs = centis % 100;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }
}

// Painter per background circuito
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

  String _formatTime(int centis) {
    final minutes = centis ~/ 6000;
    final seconds = (centis % 6000) ~/ 100;
    final cs = centis % 100;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }
}

// Painter per background circuito
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
