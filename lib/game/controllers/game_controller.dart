import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flame/extensions.dart';
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

  // input player
  bool acceleratePressed = false;
  bool brakePressed = false;

  Timer? _gameTimer;
  int tickMs = 16;

  GameController({required this.circuit, required this.carModel});

  // ---------------- JSON loading ----------------
  Future<void> loadTrackFromJson() async {
    try {
      final jsonString = await rootBundle.loadString(circuit.trackJsonPath);
      final data = json.decode(jsonString) as Map<String, dynamic>;

      final points = (data["path"] as List)
          .map(
            (p) =>
                Offset((p["x"] as num).toDouble(), (p["y"] as num).toDouble()),
          )
          .toList();

      // Inverti direzione per il circuito Belgium
      if (circuit.id.toLowerCase() == "belgium") {
        points.reverse();
        debugPrint("[GameController] Direzione pista invertita per Belgium.");
      }

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
      debugPrint(
        "[GameController] Caricati ${_trackPoints.length} punti dal JSON.",
      );
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
    debugPrint("[GameController] Respawn effettuato allo spawn point.");
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
    debugPrint("[GameController] Bot inizializzati: ${bots.length}");
  }

  void tick() {
    if (_trackPoints.isEmpty || disqualified) {
      notifyListeners();
      return;
    }

    _updatePlayer();
    _updateBots();
    notifyListeners();
  }

  void _updatePlayer() {
    if (disqualified) return;

    // 🔧 Velocità più reattiva
    const double maxSpeed = 5.0;
    const double accelerationStep = 0.2;
    const double brakeStep = 0.3;
    const double frictionStep = 0.1;

    if (acceleratePressed) {
      speed = (speed + accelerationStep).clamp(0, maxSpeed);
    } else if (brakePressed) {
      speed = (speed - brakeStep).clamp(0, maxSpeed);
    } else {
      speed = (speed - frictionStep).clamp(0, maxSpeed);
    }

    _applyCurvePhysics(maxSpeed);

    _playerIndex += speed.round();
    if (_playerIndex < 0) _playerIndex = 0;
    _playerIndex %= _trackPoints.length;
  }

  void _applyCurvePhysics(double maxSpeed) {
    if (_trackPoints.length < 3) return;

    final prev = _trackPoints[(_playerIndex - 3) % _trackPoints.length];
    final curr = _trackPoints[_playerIndex];
    final next = _trackPoints[(_playerIndex + 3) % _trackPoints.length];

    final v1 = (curr - prev);
    final v2 = (next - curr);

    final angle1 = atan2(v1.dy, v1.dx);
    final angle2 = atan2(v2.dy, v2.dx);
    
    double deltaAngle = (angle2 - angle1).abs();
    if (deltaAngle > pi) deltaAngle = 2 * pi - deltaAngle;

    // 🔧 SOGLIA PIÙ BASSA per rilevare più curve
    const double minCurveAngle = 0.15;
    if (deltaAngle < minCurveAngle) {
      // Rettilineo - nessun controllo di curva
      return;
    }

    // 🔧 CALCOLO VELOCITÀ OTTIMALE molto severo per le curve
    double curveSeverity = deltaAngle / pi;
    double optimalSpeed = maxSpeed * (1.0 - curveSeverity * 1.2);
    optimalSpeed = optimalSpeed.clamp(1.0, maxSpeed);

    debugPrint("[Curve] Angolo: ${(deltaAngle * 180/pi).toStringAsFixed(1)}°, Ottimale: ${optimalSpeed.toStringAsFixed(2)}, Attuale: ${speed.toStringAsFixed(2)}");

    // 🔥 SCHIANTO PER VELOCITÀ ALTA IN CURVA - SISTEMA SEMPLIFICATO
    if (speed > 3.5 && deltaAngle > 0.3) {
      // Se velocità > 3.5 E curva > ~17 gradi → SCHIANTO
      debugPrint("[Curve] SCHIANTO! Velocità troppo alta (${speed.toStringAsFixed(2)}) in curva stretta (${(deltaAngle * 180/pi).toStringAsFixed(1)}°).");
      disqualified = true;
      stop();
      return;
    }
    else if (speed > 4.0 && deltaAngle > 0.2) {
      // Se velocità > 4.0 E curva > ~11 gradi → SCHIANTO
      debugPrint("[Curve] SCHIANTO! Velocità pericolosa (${speed.toStringAsFixed(2)}) in curva (${(deltaAngle * 180/pi).toStringAsFixed(1)}°).");
      disqualified = true;
      stop();
      return;
    }
    else if (speed > 4.5) {
      // Se velocità > 4.5 in QUALSIASI curva → SCHIANTO
      debugPrint("[Curve] SCHIANTO! Velocità folle (${speed.toStringAsFixed(2)}) in qualsiasi curva.");
      disqualified = true;
      stop();
      return;
    }

    // SISTEMA DI RIDUZIONE VELOCITÀ PER CURVE
    if (speed > optimalSpeed * 1.5) {
      // ⚠️ PERICOLO DI SCHIANTO - riduzione drastica
      speed = speed * 0.4;
      debugPrint("[Curve] PERICOLO SCHIANTO! Velocità ridotta a ${speed.toStringAsFixed(2)}.");
    } 
    else if (speed > optimalSpeed * 1.2) {
      // 🟡 TROPPO VELOCE - riduzione moderata
      speed = speed * 0.7;
      debugPrint("[Curve] Troppo veloce in curva. Rallenta!");
    }
  }

  void _updateBots() {
    final rand = Random();
    for (int i = 0; i < bots.length; i++) {
      var bot = bots[i];
      if (bot.disqualified) continue;

      bot.speed = max(0, bot.speed - 0.05);
      if (rand.nextDouble() < 0.3) {
        bot.speed = min(bot.speed + 0.1, 5.0);
      }

      _botIndices[i] += bot.speed.round();
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