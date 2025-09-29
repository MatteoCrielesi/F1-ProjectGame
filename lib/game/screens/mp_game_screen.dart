import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../local/mp_server.dart';
import '../local/mp_client.dart';
import '../local/mp_lobby.dart';
import '../local/mp_game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';

enum MpMode { host, client, none }

class MpGameScreen extends StatefulWidget {
  final MpMode mode;
  final String lobbyId;
  final String hostAddress;
  final Circuit circuit;
  final CarModel carModel;

  const MpGameScreen({
    Key? key,
    this.mode = MpMode.none,
    this.lobbyId = "",
    this.hostAddress = "",
    required this.circuit,
    required this.carModel,
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
        });
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
      client = MpClient(
        id: "client_${DateTime.now().millisecondsSinceEpoch}",
        name: "PlayerClient",
      );

      client!.onLobbyUpdate = (lobbyMap) {
        _logger.d("Aggiornamento lobby ricevuto dal client: $lobbyMap");
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
        });
      };

      // RIMOSSO: onStateUpdate non esiste nel client
      // client!.onStateUpdate = (state) {
      //   _logger.d("Aggiornamento stato ricevuto dal server: $state");
      //   // aggiornamento degli altri giocatori
      // };

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

  /// NOTIFICA IL SERVER CHE STAI LIBERANDO L'AUTO
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
    
    // NOTIFICA IL SERVER CHE STAI LIBERANDO L'AUTO QUANDO ENTRi IN QUESTA SCHERMATA
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifyServerImFree();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("Multiplayer Game: ${widget.mode}"),
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // AGGIUNTA: Messaggio informativo
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              border: Border.all(color: Colors.blue),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info, color: Colors.blueAccent, size: 16),
                SizedBox(width: 8),
                Text(
                  "La tua auto precedente è stata liberata",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          if (latestLobbyState != null) _buildLobbyView(latestLobbyState!),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _logger.d("Tap rilevato sul gioco");
                if (widget.mode == MpMode.host) {
                  _logger.i("Host avvia il gioco");
                  gameController.startGame();
                }
              },
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Rendering del gioco multiplayer",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Posizione auto: (${gameController.carPosition.dx.toStringAsFixed(1)}, ${gameController.carPosition.dy.toStringAsFixed(1)})",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Modalità: ${widget.mode}",
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 20),
                      if (_takenCars.isNotEmpty) ...[
                        Text(
                          "Auto occupate:",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _takenCars.map((carName) {
                            return Chip(
                              label: Text(carName),
                              backgroundColor: Colors.red[100],
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
      padding: EdgeInsets.all(16),
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
          SizedBox(height: 12),
          Text(
            "Giocatori:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: players.map((p) {
              final pid = p['id'];
              final name = p['name'];
              final car = p['car'];
              return Card(
                color: car != null ? Colors.green[50] : Colors.grey[100],
                elevation: 2,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: car != null ? Colors.green[800] : Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Auto: ${car ?? 'non scelta'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: car != null ? Colors.green[600] : Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            "Seleziona auto:",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cars.entries.map((e) {
              final car = e.key;
              final occupied = e.value as bool;
              final isTaken = _takenCars.contains(car);
              
              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: occupied ? Colors.grey[400] : Colors.blue[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: occupied
                    ? null
                    : () {
                        _logger.d(
                          "Click sul pulsante auto $car (occupied=$occupied)",
                        );
                        if (widget.mode == MpMode.client) {
                          client?.selectCar(car);
                          _logger.i("Client seleziona auto $car");
                        } else if (widget.mode == MpMode.host) {
                          final success = lobbyModel?.tryAssignCar("host", car) ?? false;
                          if (success) {
                            _logger.i("Host assegna auto $car a host");
                            server?.broadcastLobby();
                          } else {
                            _logger.w("Host non può assegnare auto $car - già occupata");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Impossibile selezionare $car!"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: Text(
                  car,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12),
          if (_takenCars.isNotEmpty) ...[
            Text(
              "Auto già selezionate: ${_takenCars.join(', ')}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }
}