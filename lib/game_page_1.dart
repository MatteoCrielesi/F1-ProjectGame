import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:f1_project/game/local/mp_client.dart';
import 'package:f1_project/game/local/mp_lobby.dart';
import 'package:f1_project/game/local/mp_server.dart';
import 'package:f1_project/game/saves/game_records.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game/screens/game_screen.dart';
import 'game/models/circuit.dart';
import 'game/models/car.dart';
import 'game/controllers/game_controller.dart';
import 'start_lights.dart';

class GamePage_1 extends StatefulWidget {
  final String selectedType;

  const GamePage_1({super.key, required this.selectedType});

  @override
  State<GamePage_1> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage_1> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentPage = 0;
  int? _lastSelectedIndex;

  Circuit? _selectedCircuit;
  CarModel? _selectedTeam;
  bool _teamSelected = false;
  List<String> _takenCars = [];

  GameController? _preloadController;
  Future<void>? _preloadFuture;
  bool _timerRunning = false;
  int _elapsedCentis = 0;
  Timer? _countdownTimer;

  bool _lobbyStep = false;
  MpServer? _server;
  MpClient? _mpclient;
  Socket? _client;
  MpLobby? _lobby;
  String? _playerId;
  bool _isHost = false;
  bool _creatingLobby = false;

  bool _gameOver = false;
  bool _crashState = false;
  bool _victoryState = false;

  List<Map<String, dynamic>> _foundLobbies = [];

  final GlobalKey<GameScreenState> _gameScreenKey =
      GlobalKey<GameScreenState>();

  @override
  void initState() {
    super.initState();
    print("Tipo selezionato: ${widget.selectedType}");

    if (widget.selectedType == "local") {
      _lobbyStep = true;

      _mpclient = MpClient(
        id: "guest_${DateTime.now().millisecondsSinceEpoch}",
        name: "Player",
      );

      _mpclient!.listenForLobbies((id, ip, port) {
        final exists = _foundLobbies.any((l) => l['id'] == id);
        if (!exists) {
          setState(() {
            _foundLobbies.add({'id': id, 'ip': ip, 'port': port});
          });
        }
      });

      _mpclient!.onLobbyUpdate = (lobbyData) {
        setState(() {
          _takenCars = List<String>.from(lobbyData['cars']);
        });
      };
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = _pageController.initialPage;
      });
    });
  }

  void _createLobbyAfterCircuitSelection() {
    final lobby = MpLobby(id: "lobby_${DateTime.now().millisecondsSinceEpoch}");
    final server = MpServer(lobby: lobby);

    server.start(startPort: 4040).then((_) {
      server.setCircuit(
        _selectedCircuit!.id,
      ); // Imposta il circuito selezionato
      server.announceLobby();

      setState(() {
        _server = server;
        _lobby = lobby;
        _isHost = true;
        _playerId = "host";
        _lobbyStep = false; // Esci dalla fase lobby
        _creatingLobby = false;
      });
    });
  }

  void _handleCreateLobby() {
    setState(() {
      _creatingLobby = true;
      _lobbyStep =
          false; // Nascondi la schermata lobby per mostrare selezione circuito
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
    _gameOver = false;
    _crashState = false;
    _victoryState = false;

    _gameScreenKey.currentState?.respawnCarAndReset();

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted || _gameScreenKey.currentState == null) {
        timer.cancel();
        return;
      }

      setState(() => _elapsedCentis++);

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

  void _handleBackButton() {
    if (_creatingLobby) {
      setState(() {
        _creatingLobby = false;
        _lobbyStep = true;
        _selectedCircuit = null;
      });
    } else if (_selectedCircuit == null) {
      Navigator.pop(context);
    } else if (!_teamSelected) {
      _lastSelectedIndex = allCircuits.indexOf(_selectedCircuit!);
      setState(() {
        _selectedCircuit = null;
        _currentPage = _lastSelectedIndex!;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pageController.jumpToPage(_lastSelectedIndex!);
      });
    } else {
      _resetGame();
      setState(() {
        _teamSelected = false;
        _selectedTeam = null;
      });
    }
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
                      Row(
                        children: [
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
                            onPressed: _handleBackButton,
                            child: const Icon(Icons.arrow_back, size: 20),
                          ),
                          const SizedBox(width: 12),
                          SvgPicture.asset('assets/f1_logo.svg', height: 24),
                          const SizedBox(width: 12),
                        ],
                      ),
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
                      if (!isPortrait && _selectedCircuit != null)
                        SizedBox(
                          width: centralWidgetWidth,
                          height: centralWidgetHeight,
                          child: _teamSelected
                              ? !_timerRunning && !_gameOver
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
                              ? !_timerRunning && !_gameOver
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
    if (_creatingLobby) {
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
                    });
                    _createLobbyAfterCircuitSelection(); // Crea lobby dopo selezione
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
    }
    // Se siamo ancora nella fase di lobby (crea/unisciti)
    if (_lobbyStep) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleCreateLobby, // Usa il nuovo metodo
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Crea Lobby",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _foundLobbies.isEmpty
                  ? const Center(
                      child: Text(
                        "Nessuna lobby trovata",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _foundLobbies.length,
                      itemBuilder: (context, index) {
                        final lobby = _foundLobbies[index];
                        return ListTile(
                          title: Text(
                            "Lobby ${lobby['id']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            "${lobby['ip']}:${lobby['port']}",
                            style: TextStyle(color: Colors.white70),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              final sock = await Socket.connect(
                                lobby['ip'],
                                lobby['port'],
                              );

                              // Configura il client per ricevere aggiornamenti sul circuito
                              _mpclient!.onCircuitSelect = (circuitId) {
                                final circuit = allCircuits.firstWhere(
                                  (c) => c.id == circuitId,
                                );
                                setState(() {
                                  _selectedCircuit = circuit;
                                  _lobbyStep = false;
                                });
                              };

                              await _mpclient!.connect(
                                lobby['ip'],
                                port: lobby['port'],
                              );

                              setState(() {
                                _client = sock;
                                _isHost = false;
                                _playerId =
                                    "guest_${DateTime.now().millisecondsSinceEpoch}";
                              });
                            },
                            child: const Text("Unisciti"),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    } else if (_selectedCircuit == null) {
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
                children: allCars
                    .where((car) {
                      // Filtra solo le auto non occupate
                      if (_isHost)
                        return true; // Host può scegliere qualsiasi auto
                      return !_takenCars.contains(car.name);
                    })
                    .map((car) {
                      return GestureDetector(
                        onTap: () {
                          if (!_isHost) {
                            // Client invia la selezione al server
                            _mpclient?.selectCar(car.name);
                          }
                          setState(() {
                            _teamSelected = true;
                            _selectedTeam = car;
                          });
                        },
                        child: Container(
                          width: 100,
                          height: 120,
                          decoration: BoxDecoration(
                            color: _takenCars.contains(car.name)
                                ? Colors.grey.withOpacity(0.5) // Auto occupata
                                : car.color,
                            borderRadius: BorderRadius.circular(8),
                            border: _takenCars.contains(car.name)
                                ? Border.all(color: Colors.red, width: 2)
                                : null,
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
                                style: TextStyle(
                                  color: _takenCars.contains(car.name)
                                      ? Colors.grey
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (_takenCars.contains(car.name))
                                const Text(
                                  "Occupata",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    })
                    .toList(),
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
    return '$minutes:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }
}

class _BackgroundTrackPainter extends CustomPainter {
  final List<Offset> trackPoints;
  final Circuit circuit;

  _BackgroundTrackPainter(this.trackPoints, this.circuit);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
