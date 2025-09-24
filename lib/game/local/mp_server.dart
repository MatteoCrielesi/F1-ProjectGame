// mp_server.dart

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

  Future<void> start({int port = 4040}) async {
    _server = await ServerSocket.bind(InternetAddress.anyIPv4, port);
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
    switch (type) {
      case MpMessageType.join:
        {
          final pid = msg['id'];
          final name = msg['name'];
          lobby.players[pid] = MpPlayer(id: pid, name: name);
          _sockToPlayer[sock] = pid;
          _broadcastLobby();
        }
        break;

      case MpMessageType.leave:
        {
          final pid = msg['id'];
          lobby.removePlayer(pid);
          _sockToPlayer.remove(sock);
          _broadcastLobby();
        }
        break;

      case MpMessageType.carSelect:
        {
          final pid = msg['id'];
          final car = msg['car'];
          bool ok = lobby.tryAssignCar(pid, car);
          if (ok) {
            _broadcastLobby();
          } else {
            // potresti inviare un messaggio di rifiuto solo a quel client
            _sendTo(sock, {'type': 'car_select_failed', 'car': car});
          }
        }
        break;

      case MpMessageType.stateUpdate:
        {
          final data = msg['data'];
          // aggiorna lo stato locale del giocatore
          final pid = data['id'];
          final player = lobby.players[pid];
          if (player != null) {
            player.x = (data['x'] as num).toDouble();
            player.y = (data['y'] as num).toDouble();
            player.speed = (data['speed'] as num).toDouble();
            player.lap = data['lap'];
            player.disqualified = data['disqualified'];
          }
          // broadcast lo stato a tutti (compresi mittente)
          _broadcast({'type': MpMessageType.stateUpdate, 'data': data});
        }
        break;

      case MpMessageType.hostTransfer:
        {
          // Implementare se vuoi trasferire ruolo host
        }
        break;

      default:
        print("[MpServer] Messaggio tipo sconosciuto: $type");
    }
  }

  void _remove(Socket sock) {
    final pid = _sockToPlayer[sock];
    if (pid != null) {
      lobby.removePlayer(pid);
      _sockToPlayer.remove(sock);
      _broadcastLobby();
    }
    sock.destroy();
  }

  void _broadcastLobby() {
    final playersList = lobby.players.values
        .map((p) => {'id': p.id, 'name': p.name, 'car': p.car})
        .toList();

    final msg = {
      'type': MpMessageType.lobbyUpdate,
      'lobby': {
        'id': lobby.id,
        'maxPlayers': lobby.maxPlayers,
        'players': playersList,
        'cars': lobby.cars,
      },
    };
    _broadcast(msg);
    if (onLobbyChange != null) {
      onLobbyChange!(msg['lobby'] as Map<String, dynamic>);
    }
  }

  void _broadcast(Map<String, dynamic> msg) {
    final bytes = utf8.encode(jsonEncode(msg));
    for (var sock in _sockToPlayer.keys) {
      sock.add(bytes);
    }
  }

  void _sendTo(Socket sock, Map<String, dynamic> msg) {
    sock.add(utf8.encode(jsonEncode(msg)));
  }
}
