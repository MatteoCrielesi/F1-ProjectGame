import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../controllers/game_controller.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../widgets/game_controls.dart';
import 'dart:async';

class GameScreen extends StatefulWidget {
  final Circuit circuit;
  final CarModel car;

  const GameScreen({super.key, required this.circuit, required this.car});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;
  final GlobalKey _circuitKey = GlobalKey();
  Timer? _ensureLayoutTimer;

  @override
  void initState() {
    super.initState();
    controller = GameController(circuit: widget.circuit, carModel: widget.car);
    controller.loadMask();

    // start game loop after layout ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLayoutReady());
  }

  void _onLayoutReady() {
    _updateLayoutToController();
    controller.start();

    // sometimes layout changes (orientation) — poll few times
    _ensureLayoutTimer?.cancel();
    int attempts = 0;
    _ensureLayoutTimer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      attempts++;
      _updateLayoutToController();
      if (attempts > 8) {
        t.cancel();
      }
    });
  }

  void _updateLayoutToController() {
    final renderBox = _circuitKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize) {
      final size = renderBox.size;
      controller.updateDisplayLayout(size: size); // solo size, topLeftGlobal rimosso
    }
  }

  @override
  void dispose() {
    controller.disposeController();
    _ensureLayoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.circuit.displayName),
        backgroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(builder: (context, constraints) {
                return Stack(
                  children: [
                    // Circuit SVG (scaled to fit)
                    Positioned.fill(
                      child: Container(
                        key: _circuitKey,
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          widget.circuit.svgPath,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),

                    // Car overlay: puntino colorato
                    AnimatedBuilder(
                      animation: controller,
                      builder: (_, __) {
                        final pos = controller.carPosition;
                        return Positioned(
                          left: pos.dx - 5, // centrare il puntino
                          top: pos.dy - 5,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: widget.car.color,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(blurRadius: 2, color: Colors.black38, offset: Offset(1, 1)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ),

            // Controls (accelerate / brake only)
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
