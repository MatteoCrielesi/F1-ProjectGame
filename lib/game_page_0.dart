import 'dart:async';
import 'package:f1_project/game/saves/game_records.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game/screens/game_screen.dart';
import 'game/models/circuit.dart';
import 'game/models/car.dart';
import 'game/controllers/game_controller.dart';
import 'start_lights.dart';

// Abilita il drag con mouse/trackpad nelle viste scrollabili
class _MouseTouchScrollBehavior extends MaterialScrollBehavior {
  const _MouseTouchScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class GamePage_0 extends StatefulWidget {
  final String selectedType;

  const GamePage_0({super.key, required this.selectedType});

  @override
  State<GamePage_0> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage_0> {
  @override
  void initState() {
    super.initState();
    print("Tipo selezionato: ${widget.selectedType}");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = _pageController.initialPage;
      });
    });
  }

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
  Stopwatch _stopwatch = Stopwatch();
  int? _lastSelectedIndex;
  bool _gameOver = false;
  bool _crashState = false;
  bool _victoryState = false;

  final GlobalKey<GameScreenState> _gameScreenKey =
      GlobalKey<GameScreenState>();

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
    _stopwatch
      ..reset()
      ..start();
    _timerRunning = true;
    _gameOver = false;
    _crashState = false;
    _victoryState = false;

    _gameScreenKey.currentState?.respawnCarAndReset();

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (!mounted || _gameScreenKey.currentState == null) {
        timer.cancel();
        return;
      }
      final nextCentis = _stopwatch.elapsedMilliseconds ~/ 10;
      if (nextCentis != _elapsedCentis) {
        setState(() => _elapsedCentis = nextCentis);
      }

      if (_gameScreenKey.currentState!.controller.disqualified ||
          _gameScreenKey.currentState!.controller.gameComplete) {
        _stopTimer();
      }
    });
  }

  void _handleGameState(bool crash, bool victory) {
    if (!mounted) return;

    setState(() {
      _gameOver = crash || victory;
      _crashState = crash;
      _victoryState = victory;
    });
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
      _stopwatch.reset();
    }
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
    _gameOver = false;
    _crashState = false;
    _victoryState = false;
    _gameScreenKey.currentState?.resetGame();
  }

  void _showHelpDialog() {
    // Rileva se il dispositivo è mobile o desktop
    final bool isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Come Giocare',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHelpSection(
                  'Scelta Circuito',
                  'Qui potrai scegliere il circuito che più preferisci! Sono disponibili tutti i circuiti ufficiali del Gran Premio F1 2025!',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Scelta Scuderia',
                  'Qui potrai scegliere la tua scuderia preferita! Puoi scegliere senza troppe preoccupazioni, le prestazioni di ogni scuderia sono uguali!',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Funzionamento del Gioco',
                  isMobile
                      ? 'Tramite il tasto START darai inizio al conto alla rovescia. Quando il timer partirà potrai muovere la macchina. Ad ogni nuovo tentativo ricorda di premere di nuovo START.\n Per guidare la tua vettura:\n -Tasto verde: Accelerazione tenendolo premuto. Lasciando il tasto la macchina rallenterà naturalmente;\n -Tasto rosso: Frenata più marcata e immediata.'
                      : 'Tramite il tasto START darai inizio al conto alla rovescia. Quando il timer partirà potrai muovere la macchina. Ad ogni nuovo tentativo ricorda di premere di nuovo START.\n Per guidare la tua vettura:\n -Tasto [W] o Freccia in su: Accelerazione tenendolo premuto. Lasciando il tasto la macchina rallenterà naturalmente;\n -Tasto [S] o Freccia in giù: Frenata più marcata e immediata.',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Dinamiche di Gioco',
                  'Durante la gara, il sistema implementa diverse meccaniche per rendere l\'esperienza più realistica. Se la velocità con cui si prende la curva è superiore a quella ottimale si attuerà un "micro respawn" e ci si ritroverà all\'inizio della curva, questo ti permetterà di continuare con una penalità di tempo. Tuttavia, se prendi una curva a velocità troppo eccessiva, la vettura si schianterà causando la squalifica immediata. L\'obiettivo è completare 3 giri consecutivi per terminare la gara.',
                ),
                const SizedBox(height: 16),
                _buildHelpSection(
                  'Consigli',
                  'Per ottenere le migliori prestazioni, è fondamentale moderare la velocità nelle curve più strette per evitare crash. Il sistema di fisica del gioco rileva automaticamente le curve pericolose e applica le conseguenze appropriate. La strategia migliore è mantenere un ritmo costante piuttosto che alternare accelerazioni brusche e frenate improvvise.',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Ho Capito!',
                style: TextStyle(
                  color: Color(0xFFE10600),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHelpSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFE10600),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
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
    final bool isGameActive = _selectedCircuit != null && _teamSelected;

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
                  Color.fromARGB(255, 78, 1, 1),
                  Color.fromARGB(255, 104, 104, 104),
                  Color.fromARGB(255, 88, 1, 1),
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
                // Top bar
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    isPortrait ? 22 : 8,
                    16,
                    isPortrait ? 10 : 0,
                  ),
                  child: Row(
                    children: [
                      // Lato sinistro: back + logo + titolo
                      Row(
                        children: [
                          // Nascondi la freccia back quando stai scegliendo il circuito
                          _selectedCircuit == null
                              ? const SizedBox.shrink()
                              : ElevatedButton(
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
                                    if (_selectedCircuit == null) {
                                      // Sei nella schermata scelta circuiti → vai a dashboard
                                      Navigator.pop(context);
                                    } else if (!_teamSelected) {
                                      // Sei nella schermata scelta scuderie → torna ai circuiti
                                      _lastSelectedIndex = allCircuits.indexOf(
                                        _selectedCircuit!,
                                      );
                                      setState(() {
                                        _selectedCircuit = null;
                                        _currentPage = _lastSelectedIndex!;
                                      });
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                            _pageController.jumpToPage(
                                              _lastSelectedIndex!,
                                            );
                                          });
                                    } else {
                                      // Sei nel gioco → torna alla scelta scuderia
                                      _resetGame();
                                      setState(() {
                                        _teamSelected = false;
                                        _selectedTeam = null;
                                      });
                                    }
                                  },
                                  child: const Icon(Icons.arrow_back, size: 20),
                                ),

                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/f1_logo.svg', height: 24),
                          const SizedBox(width: 12),
                        ],
                      ),

                      // Spazio espandibile per spingere i pulsanti a destra
                      const Expanded(child: SizedBox()),

                      //  Solo in orizzontale: start/timer a destra come i pulsanti record/help
                      if (!isPortrait && _selectedCircuit != null)
                        SizedBox(
                          width: centralWidgetWidth,
                          height: centralWidgetHeight,
                          child: _teamSelected
                              ? (!_timerRunning && !_gameOver
                                    ? Center(
                                        child: StartLights(
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
                                        ),
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
                                      ))
                              : const SizedBox.shrink(),
                        ),

                      // Spazio tra start/timer e help (solo quando c'è il timer)
                      if (!isPortrait && _selectedCircuit != null)
                        const SizedBox(width: 8),

                      // Spazio espandibile per spingere i pulsanti a destra (quando non c'è timer)
                      if (isPortrait || _selectedCircuit == null)
                        const Expanded(child: SizedBox()),

                      // Pulsante Record - solo nella selezione circuiti
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
                                        if (widget.selectedType ==
                                            "challenge") ...[
                                          Text(
                                            'Giro più veloce: ${_formatTime(records['bestLap'] ?? 0)}',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Game più veloce: ${_formatTime(records['bestGame'] ?? 0)}',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ] else if (widget.selectedType ==
                                            "bots") ...[
                                          Text(
                                            'Vittorie ottenute: ${records['bestGame'] ?? 0}',
                                            style: const TextStyle(
                                              color: Colors.greenAccent,
                                            ),
                                          ),
                                        ],
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

                      // Spazio tra i pulsanti
                      if (_selectedCircuit == null) const SizedBox(width: 8),

                      // Pulsante help sempre nell'angolo destro dell'header
                      GestureDetector(
                        onTap: _showHelpDialog,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white10,
                          ),
                          child: const Icon(
                            Icons.help_outline,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Riga rossa inferiore sotto l'header, visibile solo fuori dal gioco
                if (!isGameActive)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: SizedBox(
                      height: 3,
                      child: ColoredBox(color: Color(0xFFE10600)),
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
                              ? (!_timerRunning && !_gameOver
                                    ? Center(
                                        child: StartLights(
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
                                        ),
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
                                      ))
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

                // Spazio simmetrico sopra la linea inferiore (solo portrait e fuori dal gioco)
                if (isPortrait && !isGameActive && _selectedCircuit != null)
                  const SizedBox(height: 8),
                // Linea rossa inferiore: visibile solo fuori dal gioco
                if (!isGameActive)
                  const Padding(
                    padding: EdgeInsets.only(top: 0),
                    child: SizedBox(
                      height: 3,
                      child: ColoredBox(color: Color(0xFFE10600)),
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
          ScrollConfiguration(
            behavior: _MouseTouchScrollBehavior(),
            child: Listener(
              onPointerSignal: (PointerSignalEvent event) {
                if (event is PointerScrollEvent) {
                  final bool isPortrait =
                      MediaQuery.of(context).orientation ==
                      Orientation.portrait;
                  // Usa la rotellina (o scroll) per cambiare pagina.
                  final double delta = event.scrollDelta.dy != 0
                      ? event.scrollDelta.dy
                      : event.scrollDelta.dx;
                  if (delta > 0) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  } else if (delta < 0) {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  }
                }
              },
              child: PageView.builder(
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
            ),
          ),
        ],
      );
    } else if (!_teamSelected) {
      // Team selection
      return Stack(
        children: [
          // SVG del circuito in background insieme alla track
          if (_selectedCircuit != null)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: 0.12,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SvgPicture.asset(_selectedCircuit!.svgPath),
                    ),
                  ),
                ),
              ),
            ),
          // Rimosso il painter della track: lo sfondo usa solo l'SVG
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
                                color: car.name == "Racing Bulls"
                                    ? Colors.black
                                    : car.name == "Williams"
                                    ? Colors.white
                                    : null,
                                colorBlendMode:
                                    (car.name == "Racing Bulls" ||
                                        car.name == "Williams")
                                    ? BlendMode.srcIn
                                    : null,
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
        onGameStateChanged: _handleGameState,
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
      ..color = const Color.fromARGB(255, 0, 0, 0).withOpacity(0.5)
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
