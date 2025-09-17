import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../widgets/game_controls.dart';

class GameScreen extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;

  const GameScreen({super.key, required this.circuit, required this.car});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);
    _initGame();
  }

  Future<void> _initGame() async {
    await controller.loadMask();
    controller.start();
  }

  @override
  void dispose() {
    controller.disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.circuit.displayName),
        backgroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        // SVG del circuito
                        SvgPicture.asset(
                          widget.circuit.svgPath,
                          fit: BoxFit.contain,
                        ),

                        // Pista + spawn + auto + bot
                        if (controller.maskImage != null)
                          FittedBox(
                            fit: BoxFit.contain,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: controller.maskWidth.toDouble(),
                              height: controller.maskHeight.toDouble(),
                              child: CustomPaint(
                                painter: controller.buildDebugPainter(),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // controlli
            Container(
              color: Colors.black87,
              padding: const EdgeInsets.all(8),
              child: GameControls(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}
