import 'dart:ui';
import 'dart:math';

class Bot {
  int currentIndex;
  double speed;
  final double randomness;
  final int color;
  final Random _rng = Random();

  Bot({
    required this.currentIndex,
    required this.color,
    this.speed = 60,
    this.randomness = 0.1,
  });

  void updatePosition(List<Offset> path, double dt) {
    if (path.isEmpty) return;
    // Velocità con piccola variazione casuale
    final actualSpeed = speed * (1 + (randomness * (_rng.nextDouble() - 0.5)));
    final step = (actualSpeed * dt).clamp(0, path.length.toDouble());
    currentIndex = (currentIndex + step.toInt()) % path.length;
  }
}
