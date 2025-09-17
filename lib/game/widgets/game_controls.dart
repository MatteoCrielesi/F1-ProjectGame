// lib/game/widgets/game_controls.dart
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
    if (ev is RawKeyDownEvent) {
      if (!_pressed.contains(key)) _pressed.add(key);
    } else if (ev is RawKeyUpEvent) {
      _pressed.remove(key);
    }

    // solo su/giù
    if (_pressed.contains(LogicalKeyboardKey.arrowUp) || _pressed.contains(LogicalKeyboardKey.keyW)) {
      widget.controller.accelerate();
    } else {
      // optional: you may want to let it coast if not pressed
    }

    if (_pressed.contains(LogicalKeyboardKey.arrowDown) || _pressed.contains(LogicalKeyboardKey.keyS)) {
      widget.controller.brake();
    }
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // accelerate
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.controller.accelerate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                minimumSize: const Size(64, 48),
              ),
              child: const Icon(Icons.arrow_upward),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // brake
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.controller.brake,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], minimumSize: const Size(120, 48)),
              child: const Icon(Icons.arrow_downward),
            ),
          ],
        ),
      ],
    );
  }
}
