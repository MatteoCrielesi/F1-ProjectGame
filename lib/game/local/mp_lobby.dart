// mp_lobby.dart

class MpPlayer {
  final String id;
  String name;
  String? car;
  // Lo stato dinamico di gioco (posizione, velocità, giro)
  double? x;
  double? y;
  double? speed;
  int? lap;
  bool? disqualified;

  MpPlayer({
    required this.id,
    required this.name,
    this.car,
    this.x,
    this.y,
    this.speed,
    this.lap,
    this.disqualified,
  });
}

class MpLobby {
  final String id;
  final int maxPlayers;
  final Map<String, MpPlayer> players = {};
  final Map<String, bool> cars = {}; // auto disponibili

  MpLobby({ required this.id, this.maxPlayers = 4, List<String>? carList }) {
    for (var c in (carList ?? ["car1","car2","car3","car4"])) {
      cars[c] = false;
    }
  }

  bool tryAssignCar(String playerId, String car) {
    if (cars.containsKey(car) && cars[car] == false) {
      cars[car] = true;
      players[playerId]?.car = car;
      return true;
    }
    return false;
  }

  void removePlayer(String playerId) {
    if (players.containsKey(playerId)) {
      final car = players[playerId]!.car;
      if (car != null && cars.containsKey(car)) {
        cars[car] = false;
      }
      players.remove(playerId);
    }
  }
}
