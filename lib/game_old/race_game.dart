import 'dart:ui';
import 'package:flame/game.dart';
import 'abudhabi_track.dart';
import 'player.dart';
import 'bot.dart';

class RaceGame extends FlameGame {
  late Player player;
  final List<Bot> bots = [];

  @override
  Future<void> onLoad() async {
    await AbuDhabiTrack.load();

    player = Player(currentIndex: 0, color: 0xFFFF0000);
    bots.addAll([
      Bot(currentIndex: 20, color: 0xFF00FF00, speed: 70),
      Bot(currentIndex: 100, color: 0xFF0000FF, speed: 75),
      Bot(currentIndex: 200, color: 0xFFFFFF00, speed: 65),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    player.updatePosition(AbuDhabiTrack.points, dt);
    for (final bot in bots) {
      bot.updatePosition(AbuDhabiTrack.points, dt);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final points = AbuDhabiTrack.points;
    if (points.isEmpty) return;

    // Disegna il tracciato
    final trackPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path()..addPolygon(points, true);
    canvas.drawPath(path, trackPaint);

    // Player
    final playerPaint = Paint()..color = Color(player.color);
    final playerPos = points[player.currentIndex];
    canvas.drawCircle(playerPos, 4, playerPaint);

    // Bots
    for (final bot in bots) {
      final botPaint = Paint()..color = Color(bot.color);
      final botPos = points[bot.currentIndex];
      canvas.drawCircle(botPos, 4, botPaint);
    }
  }
}
