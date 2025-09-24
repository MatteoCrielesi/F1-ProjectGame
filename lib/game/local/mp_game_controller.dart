import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flame/extensions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../models/circuit.dart';
import '../models/car.dart';

class MpGameController extends ChangeNotifier {
  // Logger globale
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  Circuit circuit;
  CarModel carModel;

  List<Offset> _trackPoints = [];
  Offset? _spawnPoint;

  List<Offset> get trackPoints => _trackPoints;
  Offset? get spawnPoint => _spawnPoint;

  bool waitingForStart = true;
  bool freeMove = true;

  double speed = 0.0;
  bool disqualified = false;
  bool gameComplete = false;
  int _playerIndex = 0;

  int _playerLap = 0;
  int _previousPlayerIndex = 0;
  int? _startIndex;

  int get playerLap => _playerLap;

  Offset get carPosition =>
      _trackPoints.isNotEmpty ? _trackPoints[_playerIndex] : Offset.zero;

  bool acceleratePressed = false;
  bool brakePressed = false;

  Timer? _gameTimer;
  int tickMs = 16;

  void Function(int lap)? onLapCompleted;
  void Function(int index)? onMinorRespawn;

  void Function(Map<String, dynamic> state)? onStateUpdate;
  int _lastSent = 0;

  MpGameController({required this.circuit, required this.carModel}) {
    _logger.i("Controller creato per circuito: ${circuit.id}");
  }

  Future<void> loadTrackFromJson() async {
    _logger.i("Caricamento pista da JSON...");
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
        _logger.w("Direzione pista invertita per Belgium.");
      }

      _trackPoints = points;
      _logger.i("Caricati ${_trackPoints.length} punti dal JSON.");

      final spawn = data["spawn"];
      if (spawn != null) {
        _spawnPoint = Offset(
          (spawn["x"] as num).toDouble(),
          (spawn["y"] as num).toDouble(),
        );
        _logger.i("Spawn point trovato a $_spawnPoint");
      } else {
        _logger.w("Nessun spawn point definito nel JSON");
      }

      _applySpawnPoint();
      notifyListeners();
    } catch (e, st) {
      _logger.e('Errore caricamento JSON', error: e, stackTrace: st);
    }
  }

  void debugPrintState([String from = ""]) {
    _logger.d(
      "[${from}] pos=(${carPosition.dx.toStringAsFixed(2)}, ${carPosition.dy.toStringAsFixed(2)}) "
      "speed=${speed.toStringAsFixed(2)} lap=$_playerLap waitingForStart=$waitingForStart "
      "disqualified=$disqualified playerIndex=$_playerIndex",
    );
  }

  void respawn() {
    _logger.i("Respawn chiamato");
    _applySpawnPoint();
    waitingForStart = true;
    disqualified = false;
    debugPrintState("respawn");
    notifyListeners();
  }

  void _applySpawnPoint() {
    if (_spawnPoint == null || _trackPoints.isEmpty) {
      _logger.w("Spawn point non applicabile");
      return;
    }
    speed = 0.0;
    disqualified = false;
    _playerIndex = _findNearestIndex(_spawnPoint!);
    _previousPlayerIndex = _playerIndex;
    _playerLap = 0;
    _startIndex = _playerIndex;
    _logger.i("Respawn effettuato allo spawn point, index=$_playerIndex, lap=$_playerLap");
  }

  void tick() {
    _logger.v("Tick chiamato, playerIndex=$_playerIndex, speed=$speed");
    if (_trackPoints.isEmpty || disqualified) {
      _logger.w("Tick ignorato (pista vuota o disqualified=$disqualified)");
      notifyListeners();
      return;
    }

    _updatePlayer();
    _maybeSendState();
    notifyListeners();
  }

  void _updatePlayer() {
    _logger.v("_updatePlayer inizio, playerIndex=$_playerIndex, speed=$speed");
    if (disqualified) {
      _logger.w("Giocatore disqualificato, update ignorato");
      return;
    }

    const double maxSpeed = 2.5;
    const double accelerationStep = 0.10;
    const double brakeStep = 0.10;
    const double frictionStep = 0.05;

    if (acceleratePressed) {
      speed = (speed + accelerationStep).clamp(0, maxSpeed);
      _logger.d("Accelerazione, speed=$speed");
    } else if (brakePressed) {
      speed = (speed - brakeStep).clamp(0, maxSpeed);
      _logger.d("Frenata, speed=$speed");
    } else {
      speed = (speed - frictionStep).clamp(0, maxSpeed);
      _logger.d("Attrito applicato, speed=$speed");
    }

    speed = _applyCurvePhysics(_playerIndex, speed, maxSpeed, isPlayer: true);

    _previousPlayerIndex = _playerIndex;
    _playerIndex += speed.round();

    if (_playerIndex < 0) _playerIndex = 0;
    _playerIndex %= _trackPoints.length;

    _logger.v("_updatePlayer fine, playerIndex=$_playerIndex, previousIndex=$_previousPlayerIndex, lap=$_playerLap");

    if (_startIndex != null && _previousPlayerIndex < _startIndex! && _playerIndex >= _startIndex!) {
      _playerLap += 1;
      _logger.i("Lap completata: $_playerLap");
      onLapCompleted?.call(_playerLap);
    }
  }

  void _minorRespawn(int index) {
    _logger.i("Minor respawn a index=$index");
    _playerIndex = index;
    _previousPlayerIndex = _playerIndex;
    speed = 0.0;
    disqualified = false;

    onMinorRespawn?.call(index);
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

    double curveSeverity = deltaAngle / pi;
    double optimalSpeed = maxSpeed * (1.0 - curveSeverity * 1.2);
    optimalSpeed = optimalSpeed.clamp(0.5, 2.0);

    _logger.d("Curve physics index=$index, deltaAngle=${deltaAngle.toStringAsFixed(3)}, optimalSpeed=${optimalSpeed.toStringAsFixed(2)}, currentSpeed=${currentSpeed.toStringAsFixed(2)}");

    if (currentSpeed > optimalSpeed && isPlayer) {
      final safeIndex = (index - 5).clamp(0, _trackPoints.length - 1);
      _logger.w("Velocità eccessiva in curva, minor respawn a $safeIndex");
      _minorRespawn(safeIndex);
      return 0;
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
    _logger.d("Nearest index to point $point = $nearest");
    return nearest;
  }

  void startGame() {
    _logger.i("startGame chiamato");
    waitingForStart = false;
    disqualified = false;
    start();
    notifyListeners();
  }

  void start() {
    _logger.i("Start timer gioco, tickMs=$tickMs");
    stop();
    _gameTimer = Timer.periodic(Duration(milliseconds: tickMs), (_) => tick());
  }

  void stop() {
    _logger.i("Stop timer gioco");
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void disposeController() {
    _logger.i("disposeController chiamato");
    stop();
  }

  void _maybeSendState() {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastSent > 100) {
      final state = {
        'id': carModel.name,
        'x': carPosition.dx,
        'y': carPosition.dy,
        'speed': speed,
        'lap': _playerLap,
        'disqualified': disqualified,
        'ts': now,
      };
      _logger.d("Invio stato multiplayer: $state");
      onStateUpdate?.call(state);
      _lastSent = now;
    }
  }
}
