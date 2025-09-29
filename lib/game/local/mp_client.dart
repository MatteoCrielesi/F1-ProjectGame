import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'mp_messages.dart';

typedef OnLobbyUpdate = void Function(Map<String, dynamic> lobbyData);
typedef OnCircuitSelect = void Function(String circuitId);
typedef OnCarSelectFailed = void Function(String carName);
typedef OnLobbyClosed = void Function(String reason);
typedef OnStateUpdate = void Function(Map<String, dynamic> stateData);

class MpClient {
  final String id;
  final String name;
  Socket? _socket;
  Timer? _pingTimer;

  OnLobbyUpdate? onLobbyUpdate;
  OnCircuitSelect? onCircuitSelect;
  OnCarSelectFailed? onCarSelectFailed;
  OnLobbyClosed? onLobbyClosed;
  OnStateUpdate? onStateUpdate;

  Function(String id, String ip, int port, int playerCount, int maxPlayers)?
  onLobbyFound;

  MpClient({required this.id, required this.name});

  Future<void> connect(String ip, {int port = 4040}) async {
    try {
      _socket = await Socket.connect(ip, port, timeout: Duration(seconds: 5));

      // Invia messaggio di join immediatamente
      _socket!.write(
        jsonEncode({'type': MpMessageType.join, 'id': id, 'name': name}),
      );

      _socket!.listen(
        (data) => _handle(utf8.decode(data)),
        onDone: () => _onDisconnect(),
        onError: (e) => _onError(e),
      );

      // Avvia ping per mantenere connessione
      _startPing();

      print("[MpClient] Connesso a $ip:$port come $id");
    } catch (e) {
      print("[MpClient] Errore connessione: $e");
      rethrow;
    }
  }

  void _handle(String raw) {
    try {
      final msg = jsonDecode(raw);
      final type = msg['type'];

      switch (type) {
        case MpMessageType.lobbyUpdate:
          if (onLobbyUpdate != null) {
            onLobbyUpdate!(msg['lobby'] as Map<String, dynamic>);
          }
          break;

        case MpMessageType.circuitSelect:
          if (onCircuitSelect != null) {
            onCircuitSelect!(msg['circuit'] as String);
          }
          break;

        case MpMessageType.stateUpdate:
          if (onStateUpdate != null) {
            onStateUpdate!(msg['data'] as Map<String, dynamic>);
          }
          break;

        case 'car_select_failed':
          if (onCarSelectFailed != null) {
            onCarSelectFailed!(msg['car'] as String);
          }
          break;

        case 'lobby_closed':
          if (onLobbyClosed != null) {
            onLobbyClosed!(msg['reason'] as String);
          }
          break;

        default:
          print("[MpClient] Messaggio sconosciuto: $type");
      }
    } catch (e) {
      print("[MpClient] Errore gestione messaggio: $e");
    }
  }

  void selectCar(String carName) {
    if (_socket != null) {
      _socket!.write(
        jsonEncode({'type': MpMessageType.carSelect, 'id': id, 'car': carName}),
      );
      print("[MpClient] Inviata selezione auto: $carName");
    }
  }

  // NUOVO: Metodo per liberare l'auto
  void freeCar() {
    if (_socket != null) {
      try {
        _socket!.write(jsonEncode({'type': 'free_car', 'id': id}));
        print("[MpClient] Inviato messaggio free_car al server");
      } catch (e) {
        print("[MpClient] Errore invio free_car: $e");
      }
    }
  }

  void leave() {
    if (_socket != null) {
      _socket!.write(jsonEncode({'type': MpMessageType.leave, 'id': id}));
      _socket!.close();
    }
    _pingTimer?.cancel();
    print("[MpClient] Disconnesso dalla lobby");
  }

  void _startPing() {
    _pingTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      if (_socket != null) {
        _socket!.write(jsonEncode({'type': 'ping', 'id': id}));
      }
    });
  }

  void _onDisconnect() {
    print("[MpClient] Disconnesso dal server");
    _pingTimer?.cancel();
    if (onLobbyClosed != null) {
      onLobbyClosed!('disconnected');
    }
  }

  void _onError(error) {
    print("[MpClient] Errore socket: $error");
    _pingTimer?.cancel();
  }

  void listenForLobbies(
    Function(String id, String ip, int port, int playerCount, int maxPlayers)
    onFound,
  ) {
    this.onLobbyFound = onFound;

    RawDatagramSocket.bind(InternetAddress.anyIPv4, 4041).then((socket) {
      socket.listen((RawSocketEvent event) {
        if (event == RawSocketEvent.read) {
          final datagram = socket.receive();
          if (datagram != null) {
            try {
              final message = utf8.decode(datagram.data);
              final data = jsonDecode(message);

              if (data['id'] != null) {
                final id = data['id'] as String;
                final ip = datagram.address.address;
                final port = data['port'] as int;
                final playerCount = data['playerCount'] as int? ?? 0;
                final maxPlayers = data['maxPlayers'] as int? ?? 4;

                if (onLobbyFound != null) {
                  onLobbyFound!(id, ip, port, playerCount, maxPlayers);
                }
              }
            } catch (e) {
              print("[MpClient] Errore parsing broadcast: $e");
            }
          }
        }
      });
    });
  }

  void sendStateUpdate(Map<String, dynamic> stateData) {
    if (_socket != null) {
      _socket!.write(
        jsonEncode({'type': MpMessageType.stateUpdate, 'data': stateData}),
      );
    }
  }
}
