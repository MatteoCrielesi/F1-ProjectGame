import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import 'package:flutter/services.dart';

class GameControls extends StatefulWidget {
  final GameController controller;
  const GameControls({super.key, required this.controller});

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  final Set<LogicalKeyboardKey> _pressed = {};

  @override
  void initState() {
    super.initState();
    RawKeyboard.instance.addListener(_handleRawKey);
  }

  void _handleRawKey(RawKeyEvent ev) {
    final key = ev.logicalKey;
    bool isDown = ev is RawKeyDownEvent;

    if (isDown) {
      _pressed.add(key);
    } else {
      _pressed.remove(key);
    }

    // Aggiorna lo stato del controller
    widget.controller.acceleratePressed =
        _pressed.contains(LogicalKeyboardKey.arrowUp) ||
        _pressed.contains(LogicalKeyboardKey.keyW);

    widget.controller.brakePressed =
        _pressed.contains(LogicalKeyboardKey.arrowDown) ||
        _pressed.contains(LogicalKeyboardKey.keyS);
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKey);
    super.dispose();
  }

  void _pressAccelerate(bool pressed) {
    setState(() {
      widget.controller.acceleratePressed = pressed;
    });
  }

  void _pressBrake(bool pressed) {
    setState(() {
      widget.controller.brakePressed = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Accelerate button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _pressAccelerate(true),
              onTapUp: (_) => _pressAccelerate(false),
              onTapCancel: () => _pressAccelerate(false),
              child: Container(
                width: 64,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_upward, color: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Brake button
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTapDown: (_) => _pressBrake(true),
              onTapUp: (_) => _pressBrake(false),
              onTapCancel: () => _pressBrake(false),
              child: Container(
                width: 64,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.red[700],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_downward, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
