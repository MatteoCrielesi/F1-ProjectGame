import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/circuit.dart';
import '../models/car.dart';

class GameController extends ChangeNotifier {
  Circuit circuit;
  CarModel carModel;

  List<Offset> _trackPoints = [];
  Offset? _spawnPoint;

  List<Offset> get trackPoints => _trackPoints;
  Offset? get spawnPoint => _spawnPoint;

  bool waitingForStart = true;

  double speed = 0.0;
  bool disqualified = false;
  int _playerIndex = 0;

  int _playerLap = 0;
  int _previousPlayerIndex = 0;
  int? _startIndex; // 📍 indice della linea di partenza/arrivo

  int get playerLap => _playerLap;

  Offset get carPosition =>
      _trackPoints.isNotEmpty ? _trackPoints[_playerIndex] : Offset.zero;

  bool acceleratePressed = false;
  bool brakePressed = false;

  Timer? _gameTimer;
  int tickMs = 16;

  void Function(int lap)? onLapCompleted;
  void Function(int index)? onMinorRespawn;

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
      debugPrint(
        "[GameController] Caricati ${_trackPoints.length} punti dal JSON.",
      );
      notifyListeners();
    } catch (e) {
      debugPrint('[GameController] Errore caricamento JSON: $e');
    }
  }

  void respawn() {
    _applySpawnPoint();
    waitingForStart = true;
    notifyListeners();
  }

  void _applySpawnPoint() {
    if (_spawnPoint == null || _trackPoints.isEmpty) return;
    speed = 0.0;
    disqualified = false;
    _playerIndex = _findNearestIndex(_spawnPoint!);
    _previousPlayerIndex = _playerIndex;
    _playerLap = 0;

    // 📍 salvo l’indice di partenza/arrivo
    _startIndex = _playerIndex;

    debugPrint("[GameController] Respawn effettuato allo spawn point.");
  }

  void tick() {
    if (_trackPoints.isEmpty || disqualified) {
      notifyListeners();
      return;
    }

    _updatePlayer();
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

    speed = _applyCurvePhysics(_playerIndex, speed, maxSpeed, isPlayer: true);

    _previousPlayerIndex = _playerIndex;
    _playerIndex += speed.round();

    if (_playerIndex < 0) _playerIndex = 0;
    _playerIndex %= _trackPoints.length;

    // 🔔 Controllo lap completato (passaggio linea di partenza)
    if (_startIndex != null) {
      if (_previousPlayerIndex < _startIndex! && _playerIndex >= _startIndex!) {
        _playerLap += 1;
        debugPrint("[GameController] Lap completato ($_playerLap)");
        if (onLapCompleted != null) {
          onLapCompleted!(_playerLap);
        }
      }
    }
  }

  void _minorRespawn(int index) {
    _playerIndex = index;
    _previousPlayerIndex = _playerIndex;
    speed = 0.0;
    disqualified = false;

    debugPrint("[GameController] Minor respawn effettuato (index: $index).");
    if (onMinorRespawn != null) {
      onMinorRespawn!(index);
    }
    notifyListeners();
  }

  double _applyCurvePhysics(
    int index,
    double currentSpeed,
    double maxSpeed, {
    bool isPlayer = false,
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

    debugPrint(
      "[GameController] Curva rilevata: deltaAngle=${deltaAngle.toStringAsFixed(3)} speed=${currentSpeed.toStringAsFixed(2)}",
    );

    double curveSeverity = deltaAngle / pi;
    double optimalSpeed = maxSpeed * (1.0 - curveSeverity * 1.2);
    optimalSpeed = optimalSpeed.clamp(0.5, 2.0);

    bool crash = false;
    bool needRespawn = false;

    if (currentSpeed > 2.0 && deltaAngle > 0.3) {
      crash = true;
    } else if (currentSpeed > 2.3 && deltaAngle > 0.2) {
      crash = true;
    } else if (currentSpeed > 2.5) {
      crash = true;
    } else if (currentSpeed > optimalSpeed) {
      needRespawn = true;
    }

    if (crash) {
      if (isPlayer) {
        debugPrint("[GameController] Crash! Giocatore squalificato.");
        disqualified = true;
        stop();
        waitingForStart = false;
        notifyListeners();
      }
      return 0;
    }

    if (needRespawn && isPlayer) {
      final safeIndex = (index - 5).clamp(0, _trackPoints.length - 1);
      _minorRespawn(safeIndex);
      return 0;
    }

    if (currentSpeed > optimalSpeed * 1.5) {
      return currentSpeed * 0.4;
    } else if (currentSpeed > optimalSpeed * 1.2) {
      return currentSpeed * 0.7;
    }

    return currentSpeed;
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

  void startGame() {
    waitingForStart = false;
    disqualified = false;
    start();
    notifyListeners();
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
