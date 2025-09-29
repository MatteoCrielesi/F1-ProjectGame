import 'dart:convert';
import 'dart:io';

import 'mp_messages.dart';

typedef OnLobbyUpdate = void Function(Map<String, dynamic> lobby);
typedef OnStateUpdate = void Function(Map<String, dynamic> stateData);
typedef OnCircuitSelect =
    void Function(String circuitId); // <--- nuovo callback
typedef OnLobbyClosed = void Function(String reason);
typedef OnCarSelectFailed = void Function(String carName);

class MpClient {
  Socket? _sock;
  final String id;
  final String name;
  OnLobbyUpdate? onLobbyUpdate;
  OnStateUpdate? onStateUpdate;
  OnCircuitSelect? onCircuitSelect; // <--- nuovo
  OnLobbyClosed? onLobbyClosed;
  OnCarSelectFailed? onCarSelectFailed;

  MpClient({required this.id, required this.name});

  Future<void> connect(String host, {int port = 4040}) async {
    _sock = await Socket.connect(host, port);
    print("[MpClient] Connesso a $host:$port");
    _send({'type': MpMessageType.join, 'id': id, 'name': name});

    _sock!.listen(
      (data) {
        final raw = utf8.decode(data);
        Map msg;
        try {
          msg = jsonDecode(raw);
        } catch (e) {
          print("[MpClient] Errore parsing: $e");
          return;
        }

        final type = msg['type'];
        switch (type) {
          case MpMessageType.lobbyUpdate:
            if (onLobbyUpdate != null) {
              onLobbyUpdate!(msg['lobby']);
            }
            // Aggiorna circuito se presente
            if (msg['lobby'] != null &&
                msg['lobby']['selectedCircuit'] != null) {
              onCircuitSelect?.call(msg['lobby']['selectedCircuit']);
            }
            break;

          case MpMessageType.circuitSelect: // nuovo messaggio diretto
            final circuit = msg['circuit'] as String;
            onCircuitSelect?.call(circuit);
            break;

          case MpMessageType.stateUpdate:
            if (onStateUpdate != null) {
              onStateUpdate!(msg['data']);
            }
            break;

          case 'lobby_closed': // <--- nuovo caso
            final reason = msg['reason'] as String;
            print("[MpClient] Lobby chiusa dal host: $reason");

            _sock?.destroy();
            onLobbyClosed?.call(reason);
            break;

          case 'car_select_failed':
            final car = msg['car'] as String;
            onCarSelectFailed?.call(car);
            break;

          default:
            print("[MpClient] Tipo messaggio sconosciuto: $type");
        }
      },
      onDone: () {
        print("[MpClient] Connessione chiusa");
      },
      onError: (e) {
        print("[MpClient] Errore socket: $e");
      },
    );
  }

  void selectCar(String car) {
    _send({'type': MpMessageType.carSelect, 'id': id, 'car': car});
  }

  void sendState(Map<String, dynamic> stateData) {
    _send({'type': MpMessageType.stateUpdate, 'data': stateData});
  }

  void leave() {
    _send({'type': MpMessageType.leave, 'id': id});
    _sock?.destroy();
  }

  void _send(Map<String, dynamic> msg) {
    _sock?.add(utf8.encode(jsonEncode(msg)));
  }

  // Nel metodo listenForLobbies, aggiorna il parsing del messaggio UDP
  void listenForLobbies(
    void Function(
      String id,
      String ip,
      int port,
      int playerCount,
      int maxPlayers,
    )
    onFound,
  ) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 4041);
    socket.broadcastEnabled = true;

    socket.listen((event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg;
        while ((dg = socket.receive()) != null) {
          try {
            final msg = jsonDecode(utf8.decode(dg!.data));
            final id = msg['id'] as String;
            final port = msg['port'] as int;
            final ip = dg!.address.address;
            final playerCount = msg['playerCount'] as int? ?? 0; // ← AGGIUNTO
            final maxPlayers = msg['maxPlayers'] as int? ?? 4; // ← AGGIUNTO

            onFound(id, ip, port, playerCount, maxPlayers);
          } catch (e) {
            print("[MpClient] Errore parsing UDP: $e");
          }
        }
      }
    });
  }
}
