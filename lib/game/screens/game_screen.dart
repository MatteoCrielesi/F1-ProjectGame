// lib/game/screens/game_screen.dart
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
    // load mask (async)
    controller.loadMask();

    // start game loop after a small delay to allow layout
    WidgetsBinding.instance.addPostFrameCallback((_) => _onLayoutReady());
  }

  void _onLayoutReady() {
    _updateLayoutToController();
    // if mask not loaded yet, controller.loadMask will call spawn when ready
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
      final topLeft = renderBox.localToGlobal(Offset.zero);
      controller.updateDisplayLayout(size: size, topLeftGlobal: topLeft);
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

                    // Car overlay (uses controller.carPos which is in display coords relative to the SVG container)
                    AnimatedBuilder(
                      animation: controller,
                      builder: (_, __) {
                        // we need to convert controller.carPos (display coords relative to svg widget)
                        // to absolute positioned inside this Stack. Since the svg widget is positioned with padding
                        // we placed the svg inside the Positioned.fill Container with key => controller already
                        // received displaySize relative to that container.
                        final pos = controller.carPos;
                        // clamp within area
                        final left = pos.dx;
                        final top = pos.dy;
                        return Positioned(
                          left: left,
                          top: top,
                          child: Transform.rotate(
                            angle: controller.carAngle * (3.1415926535 / 180),
                            alignment: Alignment.center,
                            child: Container(
                              width: 18,
                              height: 36,
                              decoration: BoxDecoration(
                                color: widget.car.color,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: const [
                                  BoxShadow(blurRadius: 4, color: Colors.black45, offset: Offset(1, 2)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }),
            ),

            // Controls
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
