import 'dart:ui';

class Player {
  int currentIndex;
  double speed;
  final int color;

  Player({required this.currentIndex, required this.color, this.speed = 80});

  void accelerate() {
    speed += 10;
    if (speed > 200) speed = 200;
  }

  void brake() {
    speed -= 10;
    if (speed < 0) speed = 0;
  }

  void updatePosition(List<Offset> path, double dt) {
    if (path.isEmpty) return;
    final step = (speed * dt).clamp(0, path.length.toDouble());
    currentIndex = (currentIndex + step.toInt()) % path.length;
  }
}
