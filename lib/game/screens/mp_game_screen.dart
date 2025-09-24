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
        });
      };

      client!.onStateUpdate = (state) {
        _logger.d("Aggiornamento stato ricevuto dal server: $state");
        // aggiornamento degli altri giocatori
      };

      gameController.onStateUpdate = (state) {
        _logger.d("Invio stato multiplayer dal controller al server: $state");
        client!.sendState(state);
      };

      client!.connect(widget.hostAddress);
      _logger.i("Client connesso a ${widget.hostAddress}");
    }

    gameController.loadTrackFromJson().then((_) {
      _logger.i("Pista caricata, aggiornamento UI");
      setState(() {});
    });
  }

  @override
  void dispose() {
    _logger.i("MpGameScreen dispose");
    gameController.disposeController();
    client?.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.v("Build MpGameScreen");
    return Scaffold(
      appBar: AppBar(title: Text("Multiplayer Game: ${widget.mode}")),
      body: Column(
        children: [
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
                  child: Text(
                    "Rendering del gioco: Posizione auto = (${gameController.carPosition.dx.toStringAsFixed(1)}, ${gameController.carPosition.dy.toStringAsFixed(1)})",
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

    return Column(
      children: [
        Text(
          "Lobby: ${lobby['id']}  (${players.length}/${lobby['maxPlayers']})",
        ),
        Wrap(
          children: players.map((p) {
            final pid = p['id'];
            final name = p['name'];
            final car = p['car'];
            return Card(
              child: ListTile(
                title: Text(name),
                subtitle: Text("Auto: ${car ?? 'non scelta'}"),
                onTap: () {
                  _logger.d("Tap su player $pid");
                  if (widget.mode == MpMode.client && client != null) {
                    _logger.i("Client seleziona auto car1");
                    client!.selectCar("car1");
                  }
                },
              ),
            );
          }).toList(),
        ),
        Wrap(
          spacing: 8,
          children: cars.entries.map((e) {
            final car = e.key;
            final occupied = e.value as bool;
            return ElevatedButton(
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
                        lobbyModel?.tryAssignCar("host", car);
                        _logger.i("Host assegna auto $car a host");
                        server?.onLobbyChange?.call({
                          'players': lobbyModel!.players.values.map((p) {
                            return {'id': p.id, 'name': p.name, 'car': p.car};
                          }).toList(),
                          'cars': lobbyModel!.cars,
                        });
                      }
                    },
              child: Text(car),
            );
          }).toList(),
        ),
      ],
    );
  }
}
