// lib/game/screens/game_screen_test.dart
import 'package:flutter/material.dart';
import '../controllers/game_controller_test.dart';
import '../models/car.dart';
import '../models/test_cars.dart'; // contiene la macchina rossa

class GameScreenTest extends StatefulWidget {
  const GameScreenTest({super.key, required this.car});

  final CarModel car;

  @override
  State<GameScreenTest> createState() => _GameScreenTestState();
}

class _GameScreenTestState extends State<GameScreenTest> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(carModel: widget.car);
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadTrackFromJson('assets/abudhabi_track.json');
    controller.start(); // avvia il timer automatico
  }

  @override
  void dispose() {
    controller.disposeController(); // ferma il timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: CustomPaint(painter: controller.buildDebugPainter()),
            ),
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: controller.accelerate,
            child: const Icon(Icons.arrow_upward),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: controller.brake,
            child: const Icon(Icons.arrow_downward),
          ),
        ],
      ),
    );
  }
}
