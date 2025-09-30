import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mp_lobby.dart';
import 'mp_messages.dart';

typedef OnLobbyState = void Function(Map<String, dynamic> lobbyState);
typedef OnStateBroadcast = void Function(Map<String, dynamic> stateData);

class MpServer {
  final MpLobby lobby;
  ServerSocket? _server;
  final Map<Socket, String> _sockToPlayer = {};

  OnLobbyState? onLobbyChange;
  OnStateBroadcast? onStateBroadcast;

  MpServer({required this.lobby});

  Future<void> start({int startPort = 4040}) async {
    int port = startPort;
    while (true) {
      try {
        _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
        break;
      } catch (e) {
        port++;
      }
    }
    print("[MpServer] In ascolto sulla porta $port (lobby ${lobby.id})");

    _server!.listen((sock) {
      print("[MpServer] Nuova connessione da ${sock.remoteAddress}");
      sock.listen(
        (data) => _handle(sock, utf8.decode(data)),
        onDone: () => _remove(sock),
        onError: (e) => _remove(sock),
      );
    });
  }

  void _handle(Socket sock, String raw) {
    Map msg;
    try {
      msg = jsonDecode(raw);
    } catch (e) {
      print("[MpServer] Errore parsing messaggio: $e");
      return;
    }

    final type = msg['type'];
    final pid = msg['id'];

    switch (type) {
      case MpMessageType.join:
        {
          final name = msg['name'] ?? 'Player';

          // LIBERA L'AUTO PRECEDENTE quando un player si riconnette
          lobby.freePlayerCar(pid);

          // Aggiungi il player alla lobby
          lobby.addPlayer(pid, name);
          _sockToPlayer[sock] = pid;

          print("[MpServer] Player $pid ($name) si è unito alla lobby");
          broadcastLobby();
        }
        break;

      case MpMessageType.circuitSelect:
        {
          if (_sockToPlayer[sock] == pid) {
            final circuit = msg['circuit'];
            setCircuit(circuit);
          }
        }
        break;

      case MpMessageType.leave:
        {
          lobby.removePlayer(pid);
          _sockToPlayer.remove(sock);
          print("[MpServer] Player $pid ha lasciato la lobby");
          broadcastLobby();
        }
        break;

      case MpMessageType.carSelect:
        {
          final car = msg['car'];
          bool ok = lobby.tryAssignCar(pid, car);

          if (ok) {
            print("[MpServer] Player $pid ha selezionato l'auto $car");
            broadcastLobby();
          } else {
            _sendTo(sock, {
              'type': 'car_select_failed',
              'car': car,
              'reason': 'Auto già occupata',
            });
            print(
              "[MpServer] Player $pid non può prendere $car - già occupata",
            );
          }
        }
        break;

      case MpMessageType.stateUpdate:
        {
          final data = msg['data'];
          final playerId = data['id'];
          final player = lobby.players[playerId];
          if (player != null) {
            player.x = (data['x'] as num).toDouble();
            player.y = (data['y'] as num).toDouble();
            player.speed = (data['speed'] as num).toDouble();
            player.lap = data['lap'];
            player.disqualified = data['disqualified'];
          }
          _broadcast({'type': MpMessageType.stateUpdate, 'data': data});
        }
        break;

      case 'free_car': // NUOVO: Messaggio per liberare l'auto quando si torna alla selezione
        {
          if (_sockToPlayer[sock] == pid) {
            lobby.freePlayerCar(pid);
            print("[MpServer] Player $pid ha liberato la sua auto (free_car)");
            broadcastLobby();
          } else {
            print(
              "[MpServer] ERRORE: Player $pid non autorizzato per free_car",
            );
          }
        }
        break;

      case MpMessageType.hostTransfer:
        {
          // opzionale: implementare se necessario
        }
        break;

      default:
        print("[MpServer] Messaggio tipo sconosciuto: $type");
    }
  }

  void announceLobby() async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;

    Timer.periodic(const Duration(seconds: 2), (_) {
      if (_server == null) return;

      final msg = jsonEncode({
        'id': lobby.id,
        'port': _server!.port,
        'playerCount': lobby.players.length,
        'maxPlayers': lobby.maxPlayers,
        'takenCars': lobby.takenCars(), // AGGIUNTO: auto occupate
      });

      try {
        socket.send(utf8.encode(msg), InternetAddress('255.255.255.255'), 4041);
      } catch (e) {
        print("[MpServer] Errore broadcast UDP: $e");
      }
    });
  }

  void _remove(Socket sock) {
    final pid = _sockToPlayer[sock];
    if (pid != null) {
      print("[MpServer] Connessione persa con player $pid");
      lobby.removePlayer(pid);
      _sockToPlayer.remove(sock);
      broadcastLobby();
    }
    sock.destroy();
  }

  void broadcastLobby() {
    final playersList = lobby.players.values
        .map(
          (p) => {
            'id': p.id,
            'name': p.name,
            'car': p.car,
            'x': p.x,
            'y': p.y,
            'speed': p.speed,
            'lap': p.lap,
            'disqualified': p.disqualified,
          },
        )
        .toList();

    final msg = {
      'type': MpMessageType.lobbyUpdate,
      'lobby': {
        'id': lobby.id,
        'maxPlayers': lobby.maxPlayers,
        'players': playersList,
        'cars': lobby.cars,
        'carAssignments': lobby.carAssignments, // AGGIUNTO: fondamentale!
        'takenCars': lobby.takenCars(), // AGGIUNTO: lista auto occupate
        'selectedCircuit': lobby.selectedCircuit,
      },
    };

    _broadcast(msg);
    if (onLobbyChange != null) {
      onLobbyChange!(msg['lobby'] as Map<String, dynamic>);
    }

    print(
      "[MpServer] Broadcast lobby stato - Players: ${playersList.length}, Auto occupate: ${lobby.takenCars()}",
    );
  }

  void setCircuit(String circuitId) {
    lobby.setCircuit(circuitId);
    final msg = {'type': MpMessageType.circuitSelect, 'circuit': circuitId};
    _broadcast(msg);
    broadcastLobby();
  }

  void _broadcast(Map<String, dynamic> msg) {
    if (_sockToPlayer.isEmpty) return;

    final bytes = utf8.encode(jsonEncode(msg));
    for (var sock in _sockToPlayer.keys) {
      try {
        sock.add(bytes);
      } catch (e) {
        print("[MpServer] Errore invio a socket: $e");
        // Rimuovi socket problematico
        _remove(sock);
      }
    }
  }

  void _sendTo(Socket sock, Map<String, dynamic> msg) {
    try {
      sock.add(utf8.encode(jsonEncode(msg)));
    } catch (e) {
      print("[MpServer] Errore invio a socket specifico: $e");
      _remove(sock);
    }
  }

  void close() {
    _server?.close();
    _server = null;
    print("[MpServer] Server chiuso");
  }

  void closeWithNotification() {
    final closeMsg = {'type': 'lobby_closed', 'reason': 'host_left'};
    _broadcast(closeMsg);

    Timer(Duration(milliseconds: 100), () {
      _server?.close();
      _server = null;
      print("[MpServer] Server chiuso con notifica ai client");
    });
  }

  // NUOVO: Metodo per forzare la liberazione di un'auto
  void forceFreeCar(String playerId) {
    lobby.freePlayerCar(playerId);
    print("[MpServer] Auto forzatamente liberata per player $playerId");
    broadcastLobby();
  }
}
