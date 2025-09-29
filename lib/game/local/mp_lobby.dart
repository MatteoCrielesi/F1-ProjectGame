import 'package:flutter/material.dart';
import 'package:f1_project/game/models/car.dart';

class MpPlayer {
  final String id;
  String name;
  String? car; // auto attuale selezionata

  // Stato dinamico di gioco
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
  final Map<String, bool> cars = {}; // carName -> occupata?
  final Map<String, String> carAssignments = {}; // carName -> playerId

  String? selectedCircuit;

  MpLobby({required this.id, this.maxPlayers = 10, List<String>? carList}) {
    final defaultCars = allCars.map((c) => c.name).toList();
    for (var carName in (carList ?? defaultCars)) {
      cars[carName] = false;
    }
    print("[MpLobby] Lobby $id creata con auto disponibili: ${cars.keys}");
  }

  /// Aggiunge un player alla lobby
  void addPlayer(String playerId, String playerName) {
    if (players.containsKey(playerId)) {
      print("[MpLobby] Player $playerId già presente");
      return;
    }
    players[playerId] = MpPlayer(id: playerId, name: playerName);
    print(
      "[MpLobby] Player $playerId aggiunto -> players attuali: ${players.keys}",
    );
  }

  /// Libera l'auto corrente del player (quando torna alla selezione)
  void freePlayerCar(String playerId) {
    final player = players[playerId];
    if (player != null && player.car != null) {
      final carToFree = player.car!;
      cars[carToFree] = false;
      carAssignments.remove(carToFree);
      player.car = null;
      print(
        "[MpLobby] $playerId ha liberato $carToFree -> auto ora disponibile",
      );
    }
  }

  /// Prova ad assegnare un'auto - LOGICA SEMPLIFICATA
  bool tryAssignCar(String playerId, String newCar) {
    print(
      "[MpLobby] tryAssignCar chiamato: playerId=$playerId, newCar=$newCar",
    );
    print("[MpLobby] Players disponibili: ${players.keys}");

    final player = players[playerId];
    if (player == null) {
      print("[MpLobby] ERRORE: Player $playerId non trovato nella lobby!");
      print("[MpLobby] Players attuali: ${players.keys}");
      return false;
    }

    if (!cars.containsKey(newCar)) {
      print("[MpLobby] $playerId ha provato a prendere $newCar -> NON esiste");
      return false;
    }

    final currentOwner = carAssignments[newCar];

    // Se l'auto è occupata da qualcun altro, non puoi prenderla
    if (currentOwner != null && currentOwner != playerId) {
      print(
        "[MpLobby] $playerId ha provato a prendere $newCar -> già occupata da $currentOwner",
      );
      return false;
    }

    // Se il giocatore sta cercando di selezionare la stessa auto che ha già
    if (player.car == newCar) {
      print("[MpLobby] $playerId conferma la sua auto $newCar");
      return true;
    }

    // LIBERA L'AUTO PRECEDENTE se ne aveva una diversa
    if (player.car != null && player.car != newCar) {
      _freeCar(player.car!);
      print(
        "[MpLobby] $playerId ha liberato ${player.car} prima di prendere $newCar",
      );
    }

    // ASSEGNA LA NUOVA AUTO
    player.car = newCar;
    cars[newCar] = true;
    carAssignments[newCar] = playerId;

    print("[MpLobby] $playerId ha preso $newCar -> assegnazione completata");
    print("[MpLobby] Auto occupate: ${takenCars()}");
    return true;
  }

  /// Libera un'auto (quando un player cambia auto o esce)
  void _freeCar(String carName) {
    cars[carName] = false;
    carAssignments.remove(carName);
    print("[MpLobby] Auto $carName liberata");
  }

  /// Verifica se un'auto è selezionabile dal player
  bool isCarSelectable(String playerId, String carName) {
    final currentOwner = carAssignments[carName];

    // Se è occupata da qualcun altro -> non selezionabile
    if (currentOwner != null && currentOwner != playerId) {
      return false;
    }

    return true;
  }

  /// Verifica se un'auto è occupata da qualcun altro
  bool isCarTakenByOthers(String playerId, String carName) {
    final currentOwner = carAssignments[carName];
    return currentOwner != null && currentOwner != playerId;
  }

  /// Rimuove un player dalla lobby
  void removePlayer(String playerId) {
    final player = players[playerId];
    if (player != null && player.car != null) {
      _freeCar(player.car!);
      print("[MpLobby] $playerId ha lasciato ${player.car} -> auto liberata");
    }
    players.remove(playerId);
    print(
      "[MpLobby] Giocatore $playerId rimosso. Auto occupate: ${takenCars()}",
    );
  }

  List<String> takenCars() {
    return cars.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  void setCircuit(String circuitId) {
    selectedCircuit = circuitId;
    print("[MpLobby] Circuito selezionato: $circuitId");
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'maxPlayers': maxPlayers,
      'players': players.values
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
          .toList(),
      'cars': cars,
      'carAssignments': carAssignments,
      'selectedCircuit': selectedCircuit,
    };
  }
}
