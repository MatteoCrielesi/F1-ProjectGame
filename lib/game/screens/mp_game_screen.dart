import 'package:flutter/material.dart';
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
        _logger.d("Aggiornamento lobby ricevuto dal server: $lobbyMap");
        _updateLobbyState(lobbyMap);
      };

      server!.onStateBroadcast = (stateData) {
        _logger.d("Stato broadcast ricevuto: $stateData");
        _updatePlayerState(stateData);
      };

      server!.start();
      _logger.i("Server avviato");

      // Host locale
      lobbyModel!.players["host"] = MpPlayer(id: "host", name: "HostPlayer");
      _logger.d("Host locale aggiunto alla lobby");

      gameController.onStateUpdate = (state) {
        _logger.d("Invio stato multiplayer dal controller al server: $state");
        server!.onStateBroadcast?.call(state);
      };
    } else if (widget.mode == MpMode.client) {
      _logger.i("Modalità client selezionata");
      client = MpClient(id: widget.playerId, name: "PlayerClient");

      client!.onLobbyUpdate = (lobbyMap) {
        _logger.d("Aggiornamento lobby ricevuto dal client: $lobbyMap");
        _updateLobbyState(lobbyMap);
      };

      client!.onStateUpdate = (state) {
        _logger.d("Aggiornamento stato ricevuto dal server: $state");
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
        _logger.d("Invio stato multiplayer dal controller al server: $state");
        client!.sendStateUpdate(state);
      };

      client!.connect(widget.hostAddress);
      _logger.i("Client connesso a ${widget.hostAddress}");
    }

    gameController.loadTrackFromJson().then((_) {
      _logger.i("Pista caricata, aggiornamento UI");
      setState(() {});
    });
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
              _playersState[playerId] = {
                'x': playerData['x'],
                'y': playerData['y'],
                'car': playerData['car'],
                'speed': playerData['speed'],
                'lap': playerData['lap'],
                'disqualified': playerData['disqualified'],
              };
            }
          }
        }
      }
    });
  }

  void _updatePlayerState(Map<String, dynamic> stateData) {
    final playerId = stateData['id'];
    if (playerId != widget.playerId) {
      setState(() {
        _playersState[playerId] = stateData;
      });
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
  }

  @override
  void dispose() {
    _logger.i("MpGameScreen dispose");
    gameController.disposeController();
    client?.leave();
    server?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.v("Build MpGameScreen");

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyServerImFree();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Multiplayer: ${widget.circuit.displayName}"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        actions: [
          if (!_gameStarted)
            IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: startGame,
              tooltip: "Avvia partita",
            ),
        ],
      ),
      body: Column(
        children: [
          // Informazioni lobby
          if (latestLobbyState != null) _buildLobbyView(latestLobbyState!),

          // Area di gioco principale
          Expanded(
            child: Stack(
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, constraints.maxHeight),
                        painter: _MpTrackPainter(
                          gameController.trackPoints,
                          gameController.spawnPoint,
                          gameController.carPosition,
                          _playersState,
                          widget.circuit,
                          widget.carModel,
                          canvasWidth: constraints.maxWidth,
                          canvasHeight: constraints.maxHeight,
                        ),
                      );
                    },
                  ),
                ),

                // Controlli di gioco
                if (_gameStarted)
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: MpGameControls(
                      controller: gameController,
                      controlsEnabled:
                          _gameStarted && !gameController.disqualified,
                      isLandscape: true,
                      isLeftSide: false,
                      showBothButtons: true,
                    ),
                  ),

                // Informazioni partita
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Lap: ${gameController.playerLap}",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          "Speed: ${gameController.speed.toStringAsFixed(1)}",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        Text(
                          "Players: ${_playersState.length + 1}",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLobbyView(Map<String, dynamic> lobby) {
    _logger.v("Build lobby view: $lobby");
    final players = lobby['players'] as List<dynamic>;
    final cars = lobby['cars'] as Map<String, dynamic>;

    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border.all(color: const Color.fromARGB(255, 145, 145, 145)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Lobby: ${lobby['id']}  (${players.length}/${lobby['maxPlayers']})",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: players.map((p) {
              final pid = p['id'];
              final name = p['name'];
              final car = p['car'];
              final isReady = car != null;

              return Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isReady ? Colors.green[50] : Colors.grey[100],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "$name${car != null ? ' ($car)' : ''}",
                  style: TextStyle(
                    fontSize: 12,
                    color: isReady ? Colors.green[800] : Colors.grey[600],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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

  _MpTrackPainter(
    this.points,
    this.spawnPoint,
    this.localCarPosition,
    this.playersState,
    this.circuit,
    this.localCar, {
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
    playersState.forEach((playerId, state) {
      if (state['x'] != null && state['y'] != null) {
        final carName = state['car'] ?? 'Unknown';
        final carColor = _getCarColor(carName);

        final carPaint = Paint()
          ..color = carColor
          ..style = PaintingStyle.fill;

        final px = (state['x'] as num).toDouble() * scale + offsetX;
        final py = (state['y'] as num).toDouble() * scale + offsetY;

        // Disegna cerchio per l'auto
        canvas.drawCircle(Offset(px, py), 8.0, carPaint);

        // Etichetta con nome giocatore
        // final textPainter = TextPainter(
        //   text: TextSpan(
        //     text: carName,
        //     style: TextStyle(color: Colors.white, fontSize: 10),
        //   ),
        //   textDirection: TextDirection.ltr,
        // );
        // textPainter.layout();
        // textPainter.paint(canvas, Offset(px - textPainter.width / 2, py - 15));
      }
    });

    // Disegna l'auto locale (sopra le altre)
    if (localCarPosition != Offset.zero) {
      final localCarPaint = Paint()
        ..color = localCar.color
        ..style = PaintingStyle.fill;

      final px = localCarPosition.dx * scale + offsetX;
      final py = localCarPosition.dy * scale + offsetY;

      // Auto locale più grande
      canvas.drawCircle(Offset(px, py), 10.0, localCarPaint);

      // Bordo per distinguerla
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(Offset(px, py), 10.0, borderPaint);
    }
  }

  Color _getCarColor(String carName) {
    // Mappa colori di default per auto conosciute
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
