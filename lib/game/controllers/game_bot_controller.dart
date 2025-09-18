import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/extensions.dart';
import '../models/car.dart';

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

class GameBotController {
  final List<Offset> trackPoints;

  final List<BotCar> bots = [];
  final List<int> _botIndices = [];
  final List<int> _botLaps = [];

  List<int> get botLaps => _botLaps;

  GameBotController({required this.trackPoints});

  /// Inizializza i bot in posizioni casuali
  void initBots() {
    bots.clear();
    _botIndices.clear();
    _botLaps.clear();
    final rand = Random();

    for (int i = 0; i < 9 && trackPoints.isNotEmpty; i++) {
      int idx = rand.nextInt(trackPoints.length);
      bots.add(
        BotCar(position: trackPoints[idx], color: allCars[i + 1].color),
      );
      _botIndices.add(idx);
      _botLaps.add(0);
    }
    debugPrint("[GameBotController] Bot inizializzati: ${bots.length}");
  }

  /// Aggiorna lo stato di tutti i bot
  void updateBots(double Function(
    int index,
    double currentSpeed,
    double maxSpeed, {
    bool isPlayer,
    BotCar? bot,
  }) applyCurvePhysics) {
    final rand = Random();
    for (int i = 0; i < bots.length; i++) {
      var bot = bots[i];
      if (bot.disqualified) continue;

      bot.speed = max(0, bot.speed - 0.02);

      if (rand.nextDouble() < 0.3) {
        bot.speed = min(bot.speed + 0.05, 3.0);
      }

      bot.speed = applyCurvePhysics(
        _botIndices[i],
        bot.speed,
        3.0,
        isPlayer: false,
        bot: bot,
      );

      int prevIndex = _botIndices[i];
      _botIndices[i] += bot.speed.round();
      _botIndices[i] %= trackPoints.length;
      bot.position = trackPoints[_botIndices[i]];

      if (_botIndices[i] < prevIndex) {
        _botLaps[i] += 1;
      }
    }
  }
}
