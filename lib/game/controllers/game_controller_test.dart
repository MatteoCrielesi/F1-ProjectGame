import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/car.dart';

class GameController extends ChangeNotifier {
  final CarModel carModel;

  List<Offset> trackPoints = [];
  Offset? spawnPoint;

  double speed = 0.0;
  int playerIndex = 0;

  Timer? _gameTimer;

  GameController({required this.carModel});

  /// Carica il percorso e lo spawn dal file JSON
  Future<void> loadTrackFromJson(String path) async {
    final data = await rootBundle.loadString(path);
    final jsonData = json.decode(data);

    // percorso
    final pathList = jsonData['path'] as List<dynamic>;
    trackPoints = pathList
        .map(
          (p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()),
        )
        .toList();

    // spawn
    final spawn = jsonData['spawn'] as Map<String, dynamic>;
    spawnPoint = Offset(
      (spawn['x'] as num).toDouble(),
      (spawn['y'] as num).toDouble(),
    );

    // posiziona player al punto più vicino
    playerIndex = _findNearestIndex(spawnPoint!);

    notifyListeners();
  }

  /// Aumenta la velocità
  void accelerate() {
    speed += 0.2;
    if (speed > 5) speed = 5;
  }

  /// Rallenta la macchina
  void brake() {
    speed -= 0.3;
    if (speed < 0) speed = 0;
  }

  /// Muove la macchina
  void _movePlayer() {
    if (trackPoints.isEmpty) return;

    // incremento minimo 1 punto
    int move = speed < 1 ? 1 : speed.toInt();
    playerIndex += move;
    playerIndex %= trackPoints.length;

    notifyListeners();
  }

  /// Timer per il movimento automatico
  void start() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _movePlayer();
    });
  }

  void disposeController() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  Offset get playerPosition =>
      trackPoints.isNotEmpty ? trackPoints[playerIndex] : Offset.zero;

  int _findNearestIndex(Offset point) {
    int nearest = 0;
    double minDist = double.infinity;
    for (int i = 0; i < trackPoints.length; i++) {
      double d = (trackPoints[i] - point).distanceSquared;
      if (d < minDist) {
        minDist = d;
        nearest = i;
      }
    }
    return nearest;
  }

  /// Painter per debug e visualizzazione
  CustomPainter buildDebugPainter() => _GameDebugPainter(this);
}

class _GameDebugPainter extends CustomPainter {
  final GameController controller;
  _GameDebugPainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    // percorso
    for (var pt in controller.trackPoints) {
      canvas.drawCircle(pt, 1, paint);
    }

    // spawn
    if (controller.spawnPoint != null) {
      paint.color = Colors.red;
      canvas.drawCircle(controller.spawnPoint!, 5, paint);
    }

    // macchina player
    paint.color = controller.carModel.color;
    canvas.drawCircle(controller.playerPosition, 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
