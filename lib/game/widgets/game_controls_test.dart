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

  GameController({required this.carModel});

  Future<void> loadTrackFromJson(String path) async {
    final data = await rootBundle.loadString(path);
    final jsonData = json.decode(data);

    final pathList = jsonData['path'] as List<dynamic>;
    trackPoints = pathList
        .map(
          (p) => Offset((p['x'] as num).toDouble(), (p['y'] as num).toDouble()),
        )
        .toList();

    final spawn = jsonData['spawn'];
    spawnPoint = Offset(
      (spawn['x'] as num).toDouble(),
      (spawn['y'] as num).toDouble(),
    );

    playerIndex = _findNearestIndex(spawnPoint!);
    notifyListeners();
  }

  void accelerate() {
    speed += 0.2;
    if (speed > 5) speed = 5;
    _movePlayer();
  }

  void brake() {
    speed -= 0.3;
    if (speed < 0) speed = 0;
    _movePlayer();
  }

  void _movePlayer() {
    if (trackPoints.isEmpty) return;
    playerIndex += speed.toInt();
    playerIndex %= trackPoints.length;
    notifyListeners();
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

  // metodi richiesti dallo screen
  void start() {}
  void disposeController() {}

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

    for (var pt in controller.trackPoints) {
      canvas.drawCircle(pt, 1, paint);
    }

    if (controller.spawnPoint != null) {
      paint.color = Colors.red;
      canvas.drawCircle(controller.spawnPoint!, 5, paint);
    }

    paint.color = controller.carModel.color;
    canvas.drawCircle(controller.playerPosition, 8, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
