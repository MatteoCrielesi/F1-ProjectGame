// game_controller.dart
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
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

  // mask image
  ui.Image? _maskImage;
  Uint8List? _maskPixels;
  int maskWidth = 0;
  int maskHeight = 0;

  ui.Image? get maskImage => _maskImage;

  // track points ordinati (polilinea)
  List<Offset> _trackMaskPoints = [];

  // spawn point
  Offset? _spawnMaskPoint;

  // stato player
  double speed = 0.0;
  bool disqualified = false;
  int _playerIndex = 0;
  static const int offTrackRespawnTicks = 40;
  int _offTrackTicks = 0;

  Offset get carPosition => _trackMaskPoints.isNotEmpty
      ? _trackMaskPoints[_playerIndex]
      : Offset.zero;

  // bot cars
  final List<BotCar> bots = [];
  final List<int> _botIndices = [];

  Timer? _gameTimer;
  int tickMs = 16;

  GameController({required this.circuit, required this.carModel});

  // ---------------- mask loading ----------------
  Future<void> loadMask() async {
    try {
      final bytes = await rootBundle.load(circuit.maskPath);
      final data = bytes.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      _maskImage = frame.image;
      maskWidth = _maskImage!.width;
      maskHeight = _maskImage!.height;
      final byteData = await _maskImage!.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      _maskPixels = byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Errore caricamento mask: $e');
      return;
    }

    _buildOrderedTrack();
    _initSpawnFromCircuitPercentage();
    _applySpawnPoint();
    if (bots.isEmpty) _initBots();
    notifyListeners();
  }

  // ---------------- build ordered track ----------------
  void _buildOrderedTrack() {
    _trackMaskPoints.clear();
    if (_maskPixels == null) return;

    // raccogli tutti i pixel della pista
    final allPixels = <Offset>[];
    for (int y = 0; y < maskHeight; y++) {
      for (int x = 0; x < maskWidth; x++) {
        if (_isTrackPixel(x, y)) {
          allPixels.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    if (allPixels.isEmpty) return;

    // ordina con nearest neighbor
    final ordered = <Offset>[];
    Offset current = allPixels.removeAt(0);
    ordered.add(current);

    while (allPixels.isNotEmpty) {
      // trova il più vicino
      Offset nearest = allPixels.first;
      double bestDist = (nearest - current).distanceSquared;
      for (final pt in allPixels) {
        final d = (pt - current).distanceSquared;
        if (d < bestDist) {
          bestDist = d;
          nearest = pt;
        }
      }
      ordered.add(nearest);
      allPixels.remove(nearest);
      current = nearest;
    }

    _trackMaskPoints = ordered;
    debugPrint("Track ordered points: ${_trackMaskPoints.length}");
  }

  bool _isTrackPixel(int x, int y) {
    if (x < 0 || y < 0 || x >= maskWidth || y >= maskHeight) return false;
    final idx = (y * maskWidth + x) * 4;
    final r = _maskPixels![idx];
    final g = _maskPixels![idx + 1];
    final b = _maskPixels![idx + 2];
    return r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200;
  }

  // ---------------- spawn ----------------
  void _initSpawnFromCircuitPercentage() {
    if (maskWidth == 0 || maskHeight == 0) return;
    _spawnMaskPoint = Offset(
      maskWidth * circuit.xPercentage,
      maskHeight * circuit.yPercentage,
    );
  }

  void _applySpawnPoint() {
    if (_spawnMaskPoint == null || _trackMaskPoints.isEmpty) return;
    speed = 0.0;
    disqualified = false;

    // posizioniamo il player al punto più vicino
    _playerIndex = _findNearestIndex(_spawnMaskPoint!);
  }

  void _initBots() {
    bots.clear();
    _botIndices.clear();
    final rand = Random();

    for (int i = 0; i < 9; i++) {
      int idx = rand.nextInt(_trackMaskPoints.length);
      bots.add(
        BotCar(position: _trackMaskPoints[idx], color: allCars[i + 1].color),
      );
      _botIndices.add(idx);
    }
  }

  // ---------------- controls ----------------
  void accelerate() {
    if (disqualified) return;
    speed = Physics.applyAcceleration(speed);
  }

  void brake() {
    if (disqualified) return;
    speed = Physics.applyBrake(speed);
  }

  // ---------------- tick ----------------
  void tick() {
    if (_trackMaskPoints.isEmpty) {
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
    _playerIndex %= _trackMaskPoints.length;
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
      _botIndices[i] %= _trackMaskPoints.length;
      bot.position = _trackMaskPoints[_botIndices[i]];
    }
  }

  // ---------------- helper ----------------
  int _findNearestIndex(Offset point) {
    int nearest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < _trackMaskPoints.length; i++) {
      double d = (_trackMaskPoints[i] - point).distanceSquared;
      if (d < minDist) {
        minDist = d;
        nearest = i;
      }
    }
    return nearest;
  }

  // ---------------- loop control ----------------
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

  // ---------------- debug painter ----------------
  CustomPainter buildDebugPainter() => _GameDebugPainter(this);
}

class _GameDebugPainter extends CustomPainter {
  final GameController controller;
  _GameDebugPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // track punti (grigi)
    paint.color = Colors.grey;
    paint.strokeWidth = 1;
    for (var pt in controller._trackMaskPoints) {
      canvas.drawCircle(pt, 1, paint);
    }

    // spawn
    if (controller._spawnMaskPoint != null) {
      paint.color = Colors.red;
      canvas.drawCircle(controller._spawnMaskPoint!, 6, paint);
    }

    // player
    paint.color = Colors.yellow;
    canvas.drawCircle(controller.carPosition, 8, paint);

    // bot
    for (var bot in controller.bots) {
      paint.color = bot.color;
      canvas.drawCircle(bot.position, 6, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GameDebugPainter oldDelegate) => true;
}
