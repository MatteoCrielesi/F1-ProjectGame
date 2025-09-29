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
  bool _lobbyClosedByHost = false;

  bool _gameOver = false;
  bool _crashState = false;
  bool _victoryState = false;

  bool _dialogShown = false;

  List<Map<String, dynamic>> _foundLobbies = [];

  final GlobalKey<GameScreenState> _gameScreenKey =
      GlobalKey<GameScreenState>();

  @override
  void initState() {
    super.initState();
    print("Tipo selezionato: ${widget.selectedType}");
    _dialogShown = false;

    if (widget.selectedType == "local") {
      _lobbyStep = true;

      _mpclient = MpClient(
        id: "guest_${DateTime.now().millisecondsSinceEpoch}",
        name: "Player",
      );

      _mpclient!.listenForLobbies((id, ip, port, playerCount, maxPlayers) {
        final exists = _foundLobbies.any((l) => l['id'] == id);
        if (!exists) {
          setState(() {
            _foundLobbies.add({
              'id': id,
              'ip': ip,
              'port': port,
              'playerCount': playerCount,
              'maxPlayers': maxPlayers,
            });
          });
        } else {
          setState(() {
            final index = _foundLobbies.indexWhere((l) => l['id'] == id);
            if (index != -1) {
              _foundLobbies[index]['playerCount'] = playerCount;
              _foundLobbies[index]['maxPlayers'] = maxPlayers;
            }
          });
        }
      });

      _mpclient!.onLobbyUpdate = (lobbyData) {
        print("Lobby update received: $lobbyData");

        setState(() {
          if (lobbyData['cars'] is Map) {
            final carsMap = Map<String, bool>.from(lobbyData['cars'] as Map);
            _takenCars = carsMap.entries
                .where((entry) => entry.value == true)
                .map((entry) => entry.key)
                .toList();
          }

          if (_selectedTeam != null &&
              _takenCars.contains(_selectedTeam!.name)) {
          } else if (_selectedTeam != null &&
              !_takenCars.contains(_selectedTeam!.name)) {
            _selectedTeam = null;
            _teamSelected = false;
          }

          if (lobbyData['selectedCircuit'] != null) {
            final circuitId = lobbyData['selectedCircuit'] as String;
            final circuit = allCircuits.firstWhere(
              (c) => c.id == circuitId,
              orElse: () => allCircuits.first,
            );
            _selectedCircuit = circuit;
            _lobbyStep = false;

            _preloadFuture = _preloadCircuit(circuit);
          }
        });
      };

      _mpclient!.onCarSelectFailed = (carName) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "$carName è già stata selezionata da un altro giocatore",
            ),
            backgroundColor: Colors.red,
          ),
        );
      };

      _mpclient!.onLobbyClosed = (reason) {
        print("[GamePage] onLobbyClosed chiamato, reason: $reason");
        if (mounted) {
          setState(() {
            _lobbyClosedByHost = true;
          });

          Future.delayed(Duration(milliseconds: 100), () {
            if (mounted && !_dialogShown) {
              _dialogShown = true;
              _showLobbyClosedDialog();
            }
          });
        }
      };
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = _pageController.initialPage;
      });
    });
  }

  /// NOTIFICA IL SERVER CHE STAI LIBERANDO L'AUTO
  void _notifyServerImFree() {
    if (_isHost) {
      _lobby?.freePlayerCar(_playerId!);
      _server?.broadcastLobby();
      print("[GamePage] Host ha liberato la sua auto");
    } else {
      _mpclient?.freeCar();
      print("[GamePage] Client ha inviato free_car al server");
    }
  }

  void _createLobbyAfterCircuitSelection() async {
    try {
      final lobby = MpLobby(
        id: "lobby_${DateTime.now().millisecondsSinceEpoch}",
      );
      final server = MpServer(lobby: lobby);

      await server.start(startPort: 4040);

      _playerId = "host_${DateTime.now().millisecondsSinceEpoch}";
      lobby.players[_playerId!] = MpPlayer(id: _playerId!, name: "Host");

      server.setCircuit(_selectedCircuit!.id);
      server.announceLobby();

      server.onLobbyChange = (lobbyData) {
        setState(() {
          final carsMap = Map<String, bool>.from(lobbyData['cars']);
          _takenCars = carsMap.entries
              .where((entry) => entry.value == true)
              .map((entry) => entry.key)
              .toList();
        });
      };

      setState(() {
        _server = server;
        _lobby = lobby;
        _isHost = true;
        _playerId = "host_${DateTime.now().millisecondsSinceEpoch}";
        _lobbyStep = false;
        _creatingLobby = false;
      });
    } catch (e) {
      print("Errore nella creazione della lobby: $e");
      setState(() {
        _creatingLobby = false;
        _lobbyStep = true;
      });
    }
  }

  void _handleCreateLobby() {
    setState(() {
      _creatingLobby = true;
      _lobbyStep = false;
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

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            _isHost ? "Chiudi lobby" : "Lascia lobby",
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            _isHost
                ? "Così facendo chiuderai la lobby. Vuoi continuare?"
                : "Così facendo lascerai la lobby. Vuoi continuare?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Annulla", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleExitLobby();
              },
              child: Text(
                "Conferma",
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleExitLobby() {
    print("[GamePage] Host sta chiudendo la lobby");

    if (_isHost) {
      _server?.closeWithNotification();
    } else {
      _mpclient?.leave();
    }

    _redirectToLobbyScreen();
  }

  void _redirectToLobbyScreen() {
    print("[GamePage] Reindirizzamento alla scelta lobby");

    if (!mounted) return;

    setState(() {
      _lobbyStep = true;
      _selectedCircuit = null;
      _teamSelected = false;
      _selectedTeam = null;
      _takenCars = [];
      _foundLobbies = [];
      _creatingLobby = false;
      _isHost = false;
      _lobbyClosedByHost = false;
      _dialogShown = false;
      _gameOver = false;
      _crashState = false;
      _victoryState = false;
      _timerRunning = false;
      _elapsedCentis = 0;

      _server?.close();
      _server = null;
      _mpclient?.leave();
      _mpclient = null;
      _lobby = null;
      _playerId = null;
      _client = null;
    });

    _stopTimer();
    _countdownTimer?.cancel();
    _countdownTimer = null;

    print("[GamePage] Reindirizzamento completato");
  }

  void _showLobbyClosedDialog() {
    print("[GamePage] Mostrando dialog di chiusura lobby");

    if (!mounted) {
      print("[GamePage] Context non valido, dialog non mostrato");
      return;
    }

    showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.black87,
              title: Text(
                "Lobby chiusa",
                style: TextStyle(color: Colors.white),
              ),
              content: Text(
                "L'host ha chiuso la lobby.\nVerrai reindirizzato alla scelta della lobby.",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _redirectToLobbyScreen();
                  },
                  child: Text("OK", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        )
        .then((_) {
          print("[GamePage] Dialog chiuso, reindirizzamento in corso");
          _dialogShown = false;
        })
        .catchError((error) {
          print("[GamePage] Errore nel dialog: $error");
          _dialogShown = false;
          _redirectToLobbyScreen();
        });
  }

  void _handleBackButton() {
    if (_selectedCircuit != null &&
        _teamSelected == false &&
        _lobbyStep == false) {
      _notifyServerImFree();
      _showExitConfirmationDialog();
      return;
    }
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
    if (_lobbyClosedByHost) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text("Lobby chiusa...", style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }
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
                    _createLobbyAfterCircuitSelection();
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

    if (_lobbyStep) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _handleCreateLobby,
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
                        final playerCount = lobby['playerCount'] ?? 0;
                        final maxPlayers = lobby['maxPlayers'] ?? 4;

                        return ListTile(
                          title: Text(
                            "Lobby ${lobby['id']}",
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${lobby['ip']}:${lobby['port']}",
                                style: TextStyle(color: Colors.white70),
                              ),
                              Text(
                                "$playerCount/$maxPlayers giocatori",
                                style: TextStyle(
                                  color: playerCount >= maxPlayers
                                      ? Colors.red
                                      : Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () async {
                              try {
                                final client = MpClient(
                                  id: "guest_${DateTime.now().millisecondsSinceEpoch}",
                                  name: "Player",
                                );

                                client.onCircuitSelect = (circuitId) {
                                  print("Circuit select received: $circuitId");
                                  final circuit = allCircuits.firstWhere(
                                    (c) => c.id == circuitId,
                                    orElse: () => allCircuits.first,
                                  );
                                  setState(() {
                                    _selectedCircuit = circuit;
                                    _lobbyStep = false;
                                    _preloadFuture = _preloadCircuit(circuit);
                                  });
                                };

                                client.onLobbyUpdate = (lobbyData) {
                                  print("Lobby update received");
                                  setState(() {
                                    if (lobbyData['cars'] is Map) {
                                      final carsMap = Map<String, bool>.from(
                                        lobbyData['cars'] as Map,
                                      );
                                      _takenCars = carsMap.entries
                                          .where((entry) => entry.value == true)
                                          .map((entry) => entry.key)
                                          .toList();
                                    }

                                    if (lobbyData['selectedCircuit'] != null) {
                                      final circuitId =
                                          lobbyData['selectedCircuit']
                                              as String;
                                      final circuit = allCircuits.firstWhere(
                                        (c) => c.id == circuitId,
                                        orElse: () => allCircuits.first,
                                      );
                                      _selectedCircuit = circuit;
                                      _lobbyStep = false;
                                    }
                                  });
                                };

                                await client.connect(
                                  lobby['ip'],
                                  port: lobby['port'],
                                );

                                setState(() {
                                  _mpclient = client;
                                  _isHost = false;
                                  _playerId = client.id;
                                });
                              } catch (e) {
                                print("Errore durante la connessione: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Errore di connessione: $e"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Caricamento...", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _lobbyStep = true;
                  _selectedCircuit = null;
                  _teamSelected = false;
                });
              },
              child: const Text("Torna alle Lobby"),
            ),
          ],
        ),
      );
    } else if (!_teamSelected) {
      // NOTIFICA IL SERVER CHE STAI LIBERANDO L'AUTO QUANDO ENTRi IN QUESTA SEZIONE
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_teamSelected && _selectedCircuit != null) {
          _notifyServerImFree();
        }
      });

      return Stack(
        children: [
          Container(
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Seleziona la tua scuderia",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // AGGIUNTA: Messaggio informativo
                  Container(
                    padding: EdgeInsets.all(12),
                    margin: EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Text(
                      "La tua auto precedente è stata liberata",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: allCars.map((car) {
                      final isTaken = _takenCars.contains(car.name);
                      final isSelected = _selectedTeam?.name == car.name;

                      return GestureDetector(
                        onTap: () {
                          if (isTaken && !isSelected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "${car.name} è già stata selezionata!",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          if (!_isHost) {
                            _mpclient?.selectCar(car.name);
                          } else {
                            final success =
                                _lobby?.tryAssignCar(_playerId!, car.name) ??
                                false;
                            if (success) {
                              _server?.broadcastLobby();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Impossibile selezionare ${car.name}!",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          }

                          setState(() {
                            _teamSelected = true;
                            _selectedTeam = car;
                          });
                        },
                        child: Container(
                          width: 120,
                          height: 140,
                          decoration: BoxDecoration(
                            color: isTaken
                                ? Colors.grey.withOpacity(0.3)
                                : car.color.withOpacity(isSelected ? 1.0 : 0.7),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.yellow
                                  : isTaken
                                  ? Colors.red
                                  : Colors.white,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: [
                              if (isSelected)
                                BoxShadow(
                                  color: Colors.yellow.withOpacity(0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (car.logoPath.isNotEmpty)
                                Container(
                                  height: 60,
                                  padding: const EdgeInsets.all(4),
                                  child: ColorFiltered(
                                    colorFilter: isTaken
                                        ? ColorFilter.mode(
                                            Colors.grey,
                                            BlendMode.saturation,
                                          )
                                        : ColorFilter.mode(
                                            Colors.transparent,
                                            BlendMode.srcIn,
                                          ),
                                    child: Image.asset(
                                      car.logoPath,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              Text(
                                car.name,
                                style: TextStyle(
                                  color: isTaken ? Colors.grey : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              if (isTaken)
                                const Text(
                                  "OCCUPATA",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              if (isSelected)
                                const Text(
                                  "SELEZIONATA",
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  if (_takenCars.isNotEmpty) ...[
                    Text(
                      "Scuderie già selezionate:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _takenCars.map((carName) {
                        final car = allCars.firstWhere(
                          (c) => c.name == carName,
                          orElse: () => allCars.first,
                        );
                        return Chip(
                          backgroundColor: car.color,
                          label: Text(
                            carName,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    } else {
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