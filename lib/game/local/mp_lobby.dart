class MpPlayer {
  final String id;
  String name;
  String? car;

  // Stato dinamico di gioco (posizione, velocità, giro, ecc.)
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
  final Map<String, bool> cars = {}; // auto disponibili (false = libera, true = presa)

  String? selectedCircuit; // <--- nuovo campo

  MpLobby({required this.id, this.maxPlayers = 4, List<String>? carList}) {
    // inizializza auto disponibili
    for (var c in (carList ?? ["car1", "car2", "car3", "car4"])) {
      cars[c] = false;
    }
  }

  /// Prova ad assegnare un'auto a un giocatore.
  /// Restituisce true se l'auto era disponibile e assegnata correttamente.
  bool tryAssignCar(String playerId, String car) {
    if (!cars.containsKey(car) || cars[car] == true) return false;
    cars[car] = true;
    players[playerId]?.car = car;
    return true;
  }

  /// Rimuove un giocatore dalla lobby e libera la sua auto, se presente
  void removePlayer(String playerId) {
    if (!players.containsKey(playerId)) return;

    final car = players[playerId]!.car;
    if (car != null && cars.containsKey(car)) {
      cars[car] = false; // libera l'auto
    }

    players.remove(playerId);
  }

  /// Restituisce una lista di auto attualmente prese
  List<String> takenCars() {
    return cars.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  /// Imposta il circuito scelto dall'host
  void setCircuit(String circuitId) {
    selectedCircuit = circuitId;
  }

  /// Restituisce lo stato della lobby come Map, utile per invio broadcast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maxPlayers': maxPlayers,
      'players': players.values.map((p) => {
            'id': p.id,
            'name': p.name,
            'car': p.car,
            'x': p.x,
            'y': p.y,
            'speed': p.speed,
            'lap': p.lap,
            'disqualified': p.disqualified,
          }).toList(),
      'cars': cars,
      'selectedCircuit': selectedCircuit, // <--- aggiunto al broadcast
    };
  }
}
