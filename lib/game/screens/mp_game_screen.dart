import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../local/mp_server.dart';
import '../local/mp_client.dart';
import '../local/mp_lobby.dart';
import '../local/mp_game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../local/mp_game_controls.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

enum MpMode { host, client, none }

class MpGameScreen extends StatefulWidget {
  final MpMode mode;
  final String lobbyId;
  final String hostAddress;
  final Circuit circuit;
  final CarModel carModel;
  final String playerId;

  const MpGameScreen({
    Key? key,
    this.mode = MpMode.none,
    this.lobbyId = "",
    this.hostAddress = "",
    required this.circuit,
    required this.carModel,
    required this.playerId,
  }) : super(key: key);

  @override
  State<MpGameScreen> createState() => _MpGameScreenState();
}

class _MpGameScreenState extends State<MpGameScreen> {
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  late MpGameController gameController;
  MpServer? server;
  MpClient? client;
  MpLobby? lobbyModel;

  Map<String, dynamic>? latestLobbyState;
  List<String> _takenCars = [];

  // Stato multiplayer
  Map<String, Map<String, dynamic>> _playersState = {};
  bool _gameStarted = false;

  // Timer e stato gioco (simile a GameScreen)
  bool _timerRunning = false;
  int _elapsedCentis = 0;
  Timer? _countdownTimer;
  bool _gameOver = false;
  bool _crashState = false;
  bool _victoryState = false;

  // Classifica in tempo reale
  List<Map<String, dynamic>> _ranking = [];
  List<Map<String, dynamic>> _previousRanking = [];

  @override
  void initState() {
    super.initState();
    _logger.i("MpGameScreen initState");

    gameController = MpGameController(
      circuit: widget.circuit,
      carModel: widget.carModel,
    );

    _logger.i("GameController creato");

    if (widget.mode == MpMode.host) {
      _logger.i("Modalità host selezionata");
      lobbyModel = MpLobby(id: widget.lobbyId);
      server = MpServer(lobby: lobbyModel!);
      server!.onLobbyChange = (lobbyMap) {
        _logger.d("Lobby update (server) players=${(lobbyMap['players'] as List?)?.length ?? 0} cars=${(lobbyMap['cars'] as Map?)?.length ?? 0}");
        _updateLobbyState(lobbyMap);
      };

      server!.onStateBroadcast = (stateData) {
        _logger.v("State broadcast id=${stateData['id']} lap=${stateData['lap']} idx=${stateData['trackIndex']}");
        _updatePlayerState(stateData);
      };

      server!.start();
      _logger.i("Server avviato");

      // Host locale
      lobbyModel!.players["host"] = MpPlayer(id: "host", name: "HostPlayer");
      _logger.d("Host locale aggiunto alla lobby");

      gameController.onStateUpdate = (state) {
        _logger.v("Send state (host) id=${state['id']} lap=${state['lap']} idx=${state['trackIndex']}");
        server!.onStateBroadcast?.call(state);
      };
    } else if (widget.mode == MpMode.client) {
      _logger.i("Modalità client selezionata");
      client = MpClient(id: widget.playerId, name: "PlayerClient");

      client!.onLobbyUpdate = (lobbyMap) {
        _logger.d("Lobby update (client) players=${(lobbyMap['players'] as List?)?.length ?? 0} cars=${(lobbyMap['cars'] as Map?)?.length ?? 0}");
        _updateLobbyState(lobbyMap);
      };

      client!.onStateUpdate = (state) {
        _logger.v("State update (client) id=${state['id']} lap=${state['lap']} idx=${state['trackIndex']}");
        _updatePlayerState(state);
      };

      client!.onCarSelectFailed = (carName) {
        _logger.w("Selezione auto $carName fallita - già occupata");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$carName è già stata selezionata!"),
            backgroundColor: Colors.red,
          ),
        );
      };

      client!.onLobbyClosed = (reason) {
        _logger.w("Lobby chiusa: $reason");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("La lobby è stata chiusa: $reason"),
            backgroundColor: Colors.red,
          ),
        );
      };

      gameController.onStateUpdate = (state) {
        _logger.v("Send state (client) id=${state['id']} lap=${state['lap']} idx=${state['trackIndex']}");
        client!.sendStateUpdate(state);
      };

      client!.connect(widget.hostAddress);
      _logger.i("Client connesso a ${widget.hostAddress}");
    }

    gameController.loadTrackFromJson().then((_) {
      _logger.i("Pista caricata, aggiornamento UI");
      setState(() {});
    });

    // Inizializza timer simile a GameScreen
    _startTimer();
  }

  void _updateLobbyState(Map<String, dynamic> lobbyMap) {
    setState(() {
      latestLobbyState = lobbyMap;

      // Aggiorna lista auto occupate
      if (lobbyMap['cars'] is Map) {
        final carsMap = Map<String, bool>.from(lobbyMap['cars'] as Map);
        _takenCars = carsMap.entries
            .where((entry) => entry.value == true)
            .map((entry) => entry.key)
            .toList();
      }

      // Aggiorna stati giocatori dalla lobby
      if (lobbyMap['players'] is List) {
        final players = lobbyMap['players'] as List<dynamic>;
        for (var playerData in players) {
          if (playerData is Map<String, dynamic>) {
            final playerId = playerData['id'] as String;
            if (playerId != widget.playerId) {
              final carName = playerData['car'] as String?;
              // VERIFICA SE IL NOME DELLA MACCHINA È VALIDO PRIMA DI AGGIUNGERE
              if (carName != null && carName.isNotEmpty) {
                try {
                  final car = allCars.firstWhere((c) => c.name == carName);

                  _playersState[playerId] = {
                    'x': playerData['x'],
                    'y': playerData['y'],
                    'car': carName,
                    'speed': playerData['speed'],
                    'lap': playerData['lap'],
                    'disqualified': playerData['disqualified'],
                    'color': car.color,
                    'name':
                        playerData['name'] ??
                        'Player', // AGGIUNGI IL NOME DEL GIOCATORE
                  };
                } catch (e) {
                  _logger.w("Auto non trovata: $carName per player $playerId");
                  // Non aggiungere player con auto non valida
                }
              }
            }
          }
        }
      }

      // Aggiorna classifica
      _updateRanking();
    });
  }

  // Modifica nel metodo _updatePlayerState
  void _updatePlayerState(Map<String, dynamic> stateData) {
    final playerId = stateData['id'];
    final isLocal = stateData['isLocal'] == true;
    
    _logger.d("_updatePlayerState player=$playerId isLocal=$isLocal lap=${stateData['lap']} idx=${stateData['trackIndex']} car=${stateData['car']}");
    
    // Skip if this is a local player state (our own car)
    if (!isLocal) {
      final carName = stateData['car'] as String?;
      _logger.v("Processo player remoto $playerId car=$carName");
      
      // VERIFICA SE IL NOME DELLA MACCHINA È VALIDO
      if (carName != null && carName.isNotEmpty) {
        try {
          final car = allCars.firstWhere((c) => c.name == carName);

          setState(() {
            _playersState[playerId] = {
              ...stateData,
              'color': car.color,
              'name': stateData['name'] ?? 'Player',
            };
            _logger.d("Player remoto $playerId aggiunto. Totale players: ${_playersState.length}");
            _updateRanking();
          });
        } catch (e) {
          _logger.w(
            "Auto non trovata nello state update: $carName per player $playerId",
          );
        }
      }
    } else {
      _logger.v("Skip player locale $playerId");
    }
  }

  void _updateRanking() {
    // Crea lista con tutti i giocatori (locale + remoti)
    List<Map<String, dynamic>> allPlayers = [];

    // Aggiungi giocatore locale
    allPlayers.add({
      'id': widget.playerId,
      'name': 'You', // O widget.carModel.name se preferisci
      'car': widget.carModel.name,
      'lap': gameController.playerLap,
      'trackIndex': gameController.playerIndex, // Add track position
      'disqualified': gameController.disqualified,
      'isLocal': true,
      'color': widget.carModel.color,
      'logoPath': widget.carModel.logoPath,
    });

    // Aggiungi giocatori remoti
    _playersState.forEach((playerId, state) {
      final carName = state['car'] as String?;
      if (carName != null && carName.isNotEmpty) {
        try {
          final car = allCars.firstWhere((c) => c.name == carName);

          allPlayers.add({
            'id': playerId,
            'name': state['name'] ?? 'Player', // USA IL NOME DEL GIOCATORE
            'car': carName,
            'lap': state['lap'] ?? 0,
            'trackIndex': state['trackIndex'] ?? 0, // Add track position
            'disqualified': state['disqualified'] ?? false,
            'isLocal': false,
            'color': car.color,
            'logoPath': car.logoPath,
          });
        } catch (e) {
          _logger.w(
            "Auto non valida in ranking: $carName per player $playerId",
          );
        }
      }
    });

    // Enhanced sorting: 1) Lap (descending), 2) Track position within same lap (descending), 3) Disqualified (false first)
    allPlayers.sort((a, b) {
      final lapA = a['lap'] as int;
      final lapB = b['lap'] as int;
      final trackIndexA = a['trackIndex'] as int;
      final trackIndexB = b['trackIndex'] as int;
      final disqualifiedA = a['disqualified'] as bool;
      final disqualifiedB = b['disqualified'] as bool;

      // First, sort by disqualification status (non-disqualified first)
      if (disqualifiedA != disqualifiedB) {
        return disqualifiedA ? 1 : -1;
      }

      // Then sort by lap (higher lap first)
      if (lapA != lapB) {
        return lapB.compareTo(lapA);
      }

      // Finally, sort by track position within the same lap (higher index = further ahead)
      return trackIndexB.compareTo(trackIndexA);
    });

    setState(() {
      // Store previous ranking for overtaking detection
      _previousRanking = List.from(_ranking);
      _ranking = allPlayers;
      
      // Check for overtaking events
      _detectOvertaking();
    });
  }

  void _detectOvertaking() {
    if (_previousRanking.isEmpty || _ranking.isEmpty) return;

    // Create maps for quick position lookup
    Map<String, int> previousPositions = {};
    Map<String, int> currentPositions = {};

    for (int i = 0; i < _previousRanking.length; i++) {
      previousPositions[_previousRanking[i]['id']] = i + 1;
    }

    for (int i = 0; i < _ranking.length; i++) {
      currentPositions[_ranking[i]['id']] = i + 1;
    }

    // Check for position changes
    for (String playerId in currentPositions.keys) {
      if (previousPositions.containsKey(playerId)) {
        int previousPos = previousPositions[playerId]!;
        int currentPos = currentPositions[playerId]!;

        if (previousPos > currentPos) {
          // Player moved up in ranking (overtook someone)
          final playerName = _ranking.firstWhere((p) => p['id'] == playerId)['name'];
          _logger.i("$playerName overtook and moved from position $previousPos to $currentPos!");
          
          // You can add visual feedback here (e.g., show a notification)
          _showOvertakingNotification(playerName, previousPos, currentPos);
        }
      }
    }
  }

  void _showOvertakingNotification(String playerName, int fromPos, int toPos) {
    // Optional: Show a brief notification about the overtaking
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$playerName moved from P$fromPos to P$toPos!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _notifyServerImFree() {
    if (widget.mode == MpMode.host) {
      lobbyModel?.freePlayerCar("host");
      server?.broadcastLobby();
      _logger.i("Host ha liberato la sua auto");
    } else if (widget.mode == MpMode.client) {
      client?.freeCar();
      _logger.i("Client ha inviato free_car al server");
    }
  }

  void startGame() {
    if (!mounted) return;
    _gameStarted = true;
    gameController.startGame();
    _startTimer();
  }

  // Timer functions (simili a GameScreen)
  void _startTimer() {
    if (!mounted) return;

    _countdownTimer?.cancel();
    _elapsedCentis = 0;
    _timerRunning = true;
    _gameOver = false;
    _crashState = false;
    _victoryState = false;

    gameController.respawn();

    _countdownTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() => _elapsedCentis++);

      if (gameController.disqualified || gameController.gameComplete) {
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
  }

  void _resetGame() {
    _stopTimer();
    _elapsedCentis = 0;
    _gameOver = false;
    _crashState = false;
    _victoryState = false;
    gameController.respawn();
  }

  String _formatTime(int centis) {
    final minutes = centis ~/ 6000;
    final seconds = (centis % 6000) ~/ 100;
    final cs = centis % 100;
    return '$minutes:${seconds.toString().padLeft(2, '0')}.${cs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _logger.i("MpGameScreen dispose");
    _stopTimer();
    gameController.disposeController();
    client?.leave();
    server?.close();
    super.dispose();
  }

  bool _isPhone(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    _logger.v("Build MpGameScreen");


    final orientation = MediaQuery.of(context).orientation;
    final isPhone = _isPhone(context);
    final isDesktop = !isPhone;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Container(height: 3, color: const Color(0xFFE10600)),
                Expanded(
                  child: orientation == Orientation.landscape
                      ? _buildLandscapeLayout(isDesktop)
                      : _buildPortraitLayout(context, isDesktop),
                ),
              ],
            ),
            if (gameController.disqualified) _buildCrashMask(),
          ],
        ),
      ),
    );
  }

  // --- Maschere e UI (simili a GameScreen) ---
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
              onPressed: () => _resetGame(),
              child: const Text("Riprova"),
            ),
          ],
        ),
      ),
    );
  }

  // --- Layout Landscape e Portrait (simili a GameScreen) ---
  Widget _buildLandscapeLayout(bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // TABELLA CLASSIFICA (sostituisce la tabella tempi)
            isDesktop
                ? Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    child: _buildRankingTable(),
                  )
                : Container(
                    width: 180,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: _buildCompactRanking(),
                  ),

            // AREA GIOCO PRINCIPALE
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTrackWithOverlays(),
              ),
            ),

            // CONTROLLI
            Container(
              width: 100,
              padding: const EdgeInsets.all(12),
              child: MpGameControls(
                controller: gameController,
                controlsEnabled: _gameStarted && !gameController.disqualified,
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

  Widget _buildPortraitLayout(BuildContext context, bool isDesktop) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight = constraints.maxHeight;
        final isSmallScreen = screenHeight < 500;

        return Column(
          children: [
            // AREA GIOCO PRINCIPALE
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: _buildTrackWithOverlays(),
              ),
            ),

            // INFO E CONTROLLI
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  // INFO COMPATTE
                  if (!isDesktop)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (widget.carModel.logoPath.isNotEmpty)
                              Image.asset(
                                widget.carModel.logoPath,
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                              ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Time: ${_formatTime(_elapsedCentis)}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isSmallScreen ? 14 : 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Lap: ${gameController.playerLap}',
                                  style: TextStyle(
                                    color: Colors.grey[300],
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // CLASSIFICA COMPATTA
                        _buildCompactRanking(),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // CONTROLLI
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MpGameControls(
                      controller: gameController,
                      controlsEnabled:
                          _gameStarted && !gameController.disqualified,
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

  // --- TABELLA CLASSIFICA (nuova) ---
  Widget _buildRankingTable() {
    final totalLaps = 3;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo
          const Text(
            'CLASSIFICA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Intestazione con allineamento fisso
          const Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  'Posto',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Scuderia',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Lap',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  'Status',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24),

          // Lista giocatori con allineamento fisso
          Expanded(
            child: ListView.builder(
              itemCount: _ranking.length,
              itemBuilder: (context, index) {
                final player = _ranking[index];
                final isLocal = player['isLocal'] as bool;
                final isDisqualified = player['disqualified'] as bool;
                final teamColor = player['color'] as Color;
                // Usa il metodo sicuro per ottenere il logoPath
                final logoPath = _getSafeLogoPath(player);

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: teamColor.withOpacity(0.7),
                    border: isLocal
                        ? Border.all(color: Colors.yellow, width: 2)
                        : Border.all(color: teamColor.withOpacity(0.9)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      // Posto - colonna fissa
                      SizedBox(
                        width: 40,
                        child: Text(
                          '${index + 1}°',
                          style: TextStyle(
                            color: _getPositionColor(index + 1),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      // Logo scuderia - colonna espandibile
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 30,
                          child: logoPath.isNotEmpty
                              ? Image.asset(
                                  logoPath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback se l'immagine non viene caricata
                                    return Text(
                                      player['name'] ?? 'Unknown',
                                      style: TextStyle(
                                        color: _getTextColorForBackground(
                                          teamColor,
                                        ),
                                        fontSize: 12,
                                        fontWeight: isLocal
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                )
                              : Text(
                                  player['name'] ?? 'Unknown',
                                  style: TextStyle(
                                    color: _getTextColorForBackground(
                                      teamColor,
                                    ),
                                    fontSize: 12,
                                    fontWeight: isLocal
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ),

                      // Lap - colonna fissa
                      SizedBox(
                        width: 50,
                        child: Text(
                          '${player['lap']}/$totalLaps',
                          style: TextStyle(
                            color: isDisqualified
                                ? Colors.red
                                : _getTextColorForBackground(teamColor),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      // Status - colonna fissa
                      SizedBox(
                        width: 50,
                        child: Icon(
                          isDisqualified ? Icons.warning : Icons.check_circle,
                          color: isDisqualified ? Colors.red : Colors.green,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSafeLogoPath(Map<String, dynamic> playerData) {
    final carName = playerData['car'] as String?;
    if (carName != null) {
      try {
        final car = allCars.firstWhere((c) => c.name == carName);
        return car.logoPath;
      } catch (e) {
        // Se non trova la macchina, ritorna una stringa vuota
        return '';
      }
    }
    return '';
  }

  Widget _buildCompactRanking() {
    final totalLaps = 3;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Rank',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          for (int i = 0; i < min(3, _ranking.length); i++)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: _ranking[i]['color'].withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Posizione
                  Text(
                    '${i + 1}°',
                    style: TextStyle(
                      color: _getPositionColor(i + 1),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Logo scuderia
                  Container(
                    width: 40,
                    height: 20,
                    child: _getSafeLogoPath(_ranking[i]).isNotEmpty
                        ? Image.asset(
                            _getSafeLogoPath(_ranking[i]),
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                _ranking[i]['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: _getTextColorForBackground(
                                    _ranking[i]['color'],
                                  ),
                                  fontSize: 8,
                                  fontWeight: _ranking[i]['isLocal']
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          )
                        : Text(
                            _ranking[i]['name'] ?? 'Unknown',
                            style: TextStyle(
                              color: _getTextColorForBackground(
                                _ranking[i]['color'],
                              ),
                              fontSize: 8,
                              fontWeight: _ranking[i]['isLocal']
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                  const SizedBox(width: 8),

                  // Lap
                  Text(
                    '${_ranking[i]['lap']}/$totalLaps',
                    style: TextStyle(
                      color: _getTextColorForBackground(_ranking[i]['color']),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Metodo per determinare il colore del testo in base al background
  Color _getTextColorForBackground(Color backgroundColor) {
    // Calcola la luminosità del colore di background
    final brightness = backgroundColor.computeLuminance();
    // Se il background è scuro, usa testo bianco, altrimenti nero
    return brightness > 0.5 ? Colors.black : Colors.white;
  }

  Color _getPositionColor(int position) {
    switch (position) {
      case 1:
        return Colors.yellow;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  // --- TRACK CON OVERLAYS (simile a GameScreen) ---
  Widget _buildTrackWithOverlays() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final maxHeight = constraints.maxHeight;

        return Stack(
          children: [
            // Circuito SVG
            Positioned.fill(
              child: SvgPicture.asset(
                widget.circuit.svgPath,
                fit: BoxFit.contain,
              ),
            ),

            // Paint personalizzato per track e players
            Positioned.fill(
              child: CustomPaint(
                size: Size(maxWidth, maxHeight),
                painter: _MpTrackPainter(
                  gameController.trackPoints,
                  gameController.spawnPoint,
                  gameController.carPosition,
                  _playersState,
                  widget.circuit,
                  widget.carModel,
                  canvasWidth: maxWidth,
                  canvasHeight: maxHeight,
                  debugLogs: kDebugMode,
                ),
              ),
            ),

            // Overlay info partita
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Lap: ${gameController.playerLap}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      "Speed: ${gameController.speed.toStringAsFixed(1)}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    Text(
                      "Time: ${_formatTime(_elapsedCentis)}",
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            // Pulsante start (se non iniziato)
            if (!_gameStarted)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: startGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      "START RACE",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MpTrackPainter extends CustomPainter {
  final List<Offset> points;
  final Offset? spawnPoint;
  final Offset localCarPosition;
  final Map<String, Map<String, dynamic>> playersState;
  final Circuit circuit;
  final CarModel localCar;
  final double canvasWidth;
  final double canvasHeight;
  final bool debugLogs;

  // Throttling per evitare spam in console (log ogni ~500ms)
  static int _lastLogMs = 0;

  _MpTrackPainter(
    this.points,
    this.spawnPoint,
    this.localCarPosition,
    this.playersState,
    this.circuit,
    this.localCar, {
    required this.canvasWidth,
    required this.canvasHeight,
    this.debugLogs = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldLog = debugLogs && (now - _lastLogMs > 500);

    final scaleX = canvasWidth / circuit.viewBoxWidth;
    final scaleY = canvasHeight / circuit.viewBoxHeight;
    final scale = min(scaleX, scaleY);

    final offsetX =
        (canvasWidth - circuit.viewBoxWidth * scale) / 2 -
        circuit.viewBoxX * scale;
    final offsetY =
        (canvasHeight - circuit.viewBoxHeight * scale) / 2 -
        circuit.viewBoxY * scale;

    // Disegna la track
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

    // Disegna spawn point
    if (spawnPoint != null) {
      final spawnPaint = Paint()..color = Colors.red;
      const spawnRadius = 5.0;
      final sx = spawnPoint!.dx * scale + offsetX;
      final sy = spawnPoint!.dy * scale + offsetY;
      canvas.drawCircle(Offset(sx, sy), spawnRadius, spawnPaint);
    }

    // Disegna le auto degli altri giocatori
    if (shouldLog) {
      print("[Painter] Remote players count: ${playersState.length} IDs=${playersState.keys.toList()}");
    }
    playersState.forEach((playerId, state) {
      if (shouldLog) {
        print("[Painter] Checking player $playerId state lap=${state['lap']} idx=${state['trackIndex']} car=${state['car']}");
      }
      
      // Skip if this is the same car as the local car
      if (state['car'] == localCar.name) {
        if (shouldLog) {
          print("[Painter] Skipping player $playerId - same car as local: ${localCar.name}");
        }
        return;
      }
      
      if (state['x'] != null && state['y'] != null) {
        final carName = state['car'] ?? 'Unknown';
        final playerName = state['name'] ?? 'Player';
        final carColor = _getCarColor(carName);
        final isDisqualified = state['disqualified'] ?? false;

        final px = (state['x'] as num).toDouble() * scale + offsetX;
        final py = (state['y'] as num).toDouble() * scale + offsetY;

        if (shouldLog) {
          final lapVal = state['lap'];
          print("[Painter] Draw player=$playerId name=$playerName car=$carName pos=(${px.toStringAsFixed(1)},${py.toStringAsFixed(1)}) lap=${lapVal ?? 'n/a'} disq=$isDisqualified");
        }

        // Draw car shadow for depth
        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(0.3)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(px + 1, py + 1), 9.0, shadowPaint);

        // Draw main car body
        final carPaint = Paint()
          ..color = isDisqualified ? Colors.grey : carColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(Offset(px, py), 9.0, carPaint);

        // Draw car border
        final borderPaint = Paint()
          ..color = isDisqualified ? Colors.red : Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;
        canvas.drawCircle(Offset(px, py), 9.0, borderPaint);

        // Draw player name above car
        final textPainter = TextPainter(
          text: TextSpan(
            text: playerName,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(px - textPainter.width / 2, py - 25),
        );

        // Draw lap indicator
        final lap = state['lap'] ?? 0;
        if (lap > 0) {
          final lapTextPainter = TextPainter(
            text: TextSpan(
              text: 'L$lap',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 8,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(1, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          lapTextPainter.layout();
          lapTextPainter.paint(
            canvas,
            Offset(px - lapTextPainter.width / 2, py + 12),
          );
        }
      } else {
        if (shouldLog) {
          print("[Painter] Player $playerId has null position: x=${state['x']}, y=${state['y']}");
        }
      }
    });

    if (shouldLog) {
      _lastLogMs = now;
    }

    // Disegna l'auto locale (sopra le altre)
    if (localCarPosition != Offset.zero) {
      final px = localCarPosition.dx * scale + offsetX;
      final py = localCarPosition.dy * scale + offsetY;

      // Draw local car shadow for depth
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px + 1, py + 1), 11.0, shadowPaint);

      // Draw main local car body
      final localCarPaint = Paint()
        ..color = localCar.color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(px, py), 11.0, localCarPaint);

      // Draw pulsing border for local car
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawCircle(Offset(px, py), 11.0, borderPaint);

      // Draw "YOU" label above local car
      final youTextPainter = TextPainter(
        text: TextSpan(
          text: 'YOU',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black,
                offset: Offset(1, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      youTextPainter.layout();
      youTextPainter.paint(
        canvas,
        Offset(px - youTextPainter.width / 2, py - 28),
      );
    }
  }

  Color _getCarColor(String carName) {
    final colorMap = {
      'Red Bull': Colors.blue,
      'Ferrari': Colors.red,
      'Mercedes': Colors.teal,
      'McLaren': Colors.orange,
      'Alpine': Colors.pink,
      'Aston Martin': Colors.green,
      'AlphaTauri': Colors.white,
      'Alfa Romeo': Colors.red,
      'Williams': Colors.blue,
      'Haas': Colors.grey,
    };

    return colorMap[carName] ?? Colors.purple;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
