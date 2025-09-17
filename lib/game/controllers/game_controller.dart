import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../utils/physics.dart';

class BotCar {
  Offset position;
  double speed;
  bool disqualified;
  Color color;

  BotCar({
    required this.position,
    this.speed = 0,
    this.disqualified = false,
    required this.color,
  });
}

class GameController extends ChangeNotifier {
  Circuit circuit;
  CarModel carModel;

  // --- track points da JSON ---
  List<Offset> _trackPoints = [];
  Offset? _spawnPoint;

  List<Offset> get trackPoints => _trackPoints;
  Offset? get spawnPoint => _spawnPoint;

  // stato player
  double speed = 0.0;
  bool disqualified = false;
  int _playerIndex = 0;

  Offset get carPosition =>
      _trackPoints.isNotEmpty ? _trackPoints[_playerIndex] : Offset.zero;

  // bot cars
  final List<BotCar> bots = [];
  final List<int> _botIndices = [];

  Timer? _gameTimer;
  int tickMs = 16;

  GameController({required this.circuit, required this.carModel});

  // ---------------- JSON loading ----------------
  Future<void> loadTrackFromJson() async {
    try {
      // <-- usa direttamente il path dal Circuit
      final jsonString = await rootBundle.loadString(circuit.trackJsonPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final points = (data["path"] as List)
          .map((p) => Offset(
                (p["x"] as num).toDouble(),
                (p["y"] as num).toDouble(),
              ))
          .toList();

      _trackPoints = points;

      final spawn = data["spawn"];
      if (spawn != null) {
        _spawnPoint = Offset(
          (spawn["x"] as num).toDouble(),
          (spawn["y"] as num).toDouble(),
        );
      }

      _applySpawnPoint();
      if (bots.isEmpty) _initBots();
      debugPrint("[GameController] Caricati ${_trackPoints.length} punti dal JSON.");
      notifyListeners();
    } catch (e) {
      debugPrint('[GameController] Errore caricamento JSON: $e');
    }
  }

  void _applySpawnPoint() {
    if (_spawnPoint == null || _trackPoints.isEmpty) return;
    speed = 0.0;
    disqualified = false;

    _playerIndex = _findNearestIndex(_spawnPoint!);
  }

  void _initBots() {
    bots.clear();
    _botIndices.clear();
    final rand = Random();

    for (int i = 0; i < 9 && _trackPoints.isNotEmpty; i++) {
      int idx = rand.nextInt(_trackPoints.length);
      bots.add(
        BotCar(position: _trackPoints[idx], color: allCars[i + 1].color),
      );
      _botIndices.add(idx);
    }
  }

  void accelerate() {
    if (disqualified) return;
    speed = Physics.applyAcceleration(speed);
  }

  void brake() {
    if (disqualified) return;
    speed = Physics.applyBrake(speed);
  }

  void tick() {
    if (_trackPoints.isEmpty) {
      notifyListeners();
      return;
    }

    _updateCarMovement();
    _updateBots();
    notifyListeners();
  }

  void _updateCarMovement() {
    if (disqualified) return;
    speed = Physics.applyFriction(speed);

    _playerIndex += speed.toInt();
    if (_playerIndex < 0) _playerIndex = 0;
    _playerIndex %= _trackPoints.length;
  }

  void _updateBots() {
    final rand = Random();
    for (int i = 0; i < bots.length; i++) {
      var bot = bots[i];
      if (bot.disqualified) continue;

      bot.speed = Physics.applyFriction(bot.speed);
      if (rand.nextDouble() < 0.3) {
        bot.speed = Physics.applyAcceleration(bot.speed);
      }

      _botIndices[i] += bot.speed.toInt();
      _botIndices[i] %= _trackPoints.length;
      bot.position = _trackPoints[_botIndices[i]];
    }
  }

  int _findNearestIndex(Offset point) {
    int nearest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < _trackPoints.length; i++) {
      double d = (_trackPoints[i] - point).distanceSquared;
      if (d < minDist) {
        minDist = d;
        nearest = i;
      }
    }
    return nearest;
  }

  void start() {
    stop();
    _gameTimer = Timer.periodic(Duration(milliseconds: tickMs), (_) => tick());
  }

  void stop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void disposeController() {
    stop();
  }
}
