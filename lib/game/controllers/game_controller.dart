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

  final List<int> _botLaps = [];

  List<int> get botLaps => _botLaps;

  List<Offset> _trackPoints = [];
  Offset? _spawnPoint;

  List<Offset> get trackPoints => _trackPoints;
  Offset? get spawnPoint => _spawnPoint;

  double speed = 0.0;
  bool disqualified = false;
  int _playerIndex = 0;

  int _playerLap = 0;
  int _previousPlayerIndex = 0;

  int get playerLap => _playerLap;

  Offset get carPosition =>
      _trackPoints.isNotEmpty ? _trackPoints[_playerIndex] : Offset.zero;

  final List<BotCar> bots = [];
  final List<int> _botIndices = [];

  bool acceleratePressed = false;
  bool brakePressed = false;

  Timer? _gameTimer;
  int tickMs = 16;

  GameController({required this.circuit, required this.carModel});

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
    _botLaps.clear();
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

    const double maxSpeed = 2.5;
    const double accelerationStep = 0.10;
    const double brakeStep = 0.10;
    const double frictionStep = 0.05;

    if (acceleratePressed) {
      speed = (speed + accelerationStep).clamp(0, maxSpeed);
    } else if (brakePressed) {
      speed = (speed - brakeStep).clamp(0, maxSpeed);
    } else {
      speed = (speed - frictionStep).clamp(0, maxSpeed);
    }

    speed = _applyCurvePhysics(
      _playerIndex,
      speed,
      maxSpeed,
      isPlayer: true,
      bot: null,
    );

    _playerIndex += speed.round();
    if (_playerIndex < 0) _playerIndex = 0;
    _playerIndex %= _trackPoints.length;
  }

  double _applyCurvePhysics(
    int index,
    double currentSpeed,
    double maxSpeed, {
    bool isPlayer = false,
    BotCar? bot,
  }) {
    if (_trackPoints.length < 3) return currentSpeed;

    final prev = _trackPoints[(index - 3) % _trackPoints.length];
    final curr = _trackPoints[index];
    final next = _trackPoints[(index + 3) % _trackPoints.length];

    final v1 = (curr - prev);
    final v2 = (next - curr);

    final angle1 = atan2(v1.dy, v1.dx);
    final angle2 = atan2(v2.dy, v2.dx);

    double deltaAngle = (angle2 - angle1).abs();
    if (deltaAngle > pi) deltaAngle = 2 * pi - deltaAngle;

    const double minCurveAngle = 0.15;
    if (deltaAngle < minCurveAngle) return currentSpeed;

    double curveSeverity = deltaAngle / pi;
    double optimalSpeed = maxSpeed * (1.0 - curveSeverity * 1.2);
    optimalSpeed = optimalSpeed.clamp(0.5, 2.0);

    bool crash = false;
    if (currentSpeed > 2.0 && deltaAngle > 0.3) {
      crash = true;
    } else if (currentSpeed > 2.3 && deltaAngle > 0.2) {
      crash = true;
    } else if (currentSpeed > 2.5) {
      crash = true;
    }

    if (crash) {
      if (isPlayer) {
        disqualified = true;
        stop();
      } else if (bot != null) {
        bot.disqualified = true;
        bot.speed = 0;
      }
      return 0;
    }

    if (currentSpeed > optimalSpeed * 1.5) {
      return currentSpeed * 0.4;
    } else if (currentSpeed > optimalSpeed * 1.2) {
      return currentSpeed * 0.7;
    }

    return currentSpeed;
  }

  void _updateBots() {
    final rand = Random();
    for (int i = 0; i < bots.length; i++) {
      var bot = bots[i];
      if (bot.disqualified) continue;

      bot.speed = max(0, bot.speed - 0.02);

      if (rand.nextDouble() < 0.3) {
        bot.speed = min(bot.speed + 0.05, 3.0);
      }

      // 🔧 anche i bot si possono schiantare
      bot.speed = _applyCurvePhysics(
        _botIndices[i],
        bot.speed,
        3.0,
        isPlayer: false,
        bot: bot,
      );

      int prevIndex = _botIndices[i];
      _botIndices[i] += bot.speed.round();
      _botIndices[i] %= _trackPoints.length;
      bot.position = _trackPoints[_botIndices[i]];

      if (_botIndices[i] < prevIndex) {
        _botLaps[i] += 1;
      }
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
