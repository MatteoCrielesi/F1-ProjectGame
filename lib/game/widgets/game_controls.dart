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
  // track pressed keys for smoother control
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

    // map keys
    if (_pressed.contains(LogicalKeyboardKey.arrowUp) || _pressed.contains(LogicalKeyboardKey.keyW)) {
      widget.controller.accelerate();
    }
    if (_pressed.contains(LogicalKeyboardKey.arrowDown) || _pressed.contains(LogicalKeyboardKey.keyS)) {
      widget.controller.brake();
    }
    if (_pressed.contains(LogicalKeyboardKey.arrowLeft) || _pressed.contains(LogicalKeyboardKey.keyA)) {
      widget.controller.steerLeft();
    }
    if (_pressed.contains(LogicalKeyboardKey.arrowRight) || _pressed.contains(LogicalKeyboardKey.keyD)) {
      widget.controller.steerRight();
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
        // steer left / brake / steer right
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.controller.steerLeft,
              style: ElevatedButton.styleFrom(minimumSize: const Size(56, 48)),
              child: const Icon(Icons.arrow_back),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: widget.controller.brake,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700], minimumSize: const Size(56, 48)),
              child: const Icon(Icons.arrow_downward),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: widget.controller.steerRight,
              style: ElevatedButton.styleFrom(minimumSize: const Size(56, 48)),
              child: const Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ],
    );
  }
}
