import 'package:flutter/material.dart';
import 'mp_game_controller.dart';

class MpGameControls extends StatefulWidget {
  final MpGameController controller;
  final bool controlsEnabled;
  final bool isLandscape;
  final bool isLeftSide;
  final bool showBothButtons;

  const MpGameControls({
    super.key,
    required this.controller,
    required this.controlsEnabled,
    this.isLandscape = false,
    this.isLeftSide = true,
    this.showBothButtons = true,
  });

  @override
  State<MpGameControls> createState() => _MpGameControlsState();
}

class _MpGameControlsState extends State<MpGameControls> {
  @override
  Widget build(BuildContext context) {
    if (!widget.controlsEnabled) {
      return const SizedBox.shrink();
    }

    if (widget.isLandscape) {
      return _buildLandscapeControls();
    } else {
      return _buildPortraitControls();
    }
  }

  Widget _buildLandscapeControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.showBothButtons) ...[
            _ControlButton(
              icon: Icons.arrow_upward,
              onPressed: widget.controller.acceleratePressed
                  ? null
                  : () {
                      widget.controller.acceleratePressed = true;
                    },
              onReleased: () {
                widget.controller.acceleratePressed = false;
              },
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            _ControlButton(
              icon: Icons.arrow_downward,
              onPressed: widget.controller.brakePressed
                  ? null
                  : () {
                      widget.controller.brakePressed = true;
                    },
              onReleased: () {
                widget.controller.brakePressed = false;
              },
              color: Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPortraitControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _ControlButton(
          icon: Icons.arrow_upward,
          onPressed: widget.controller.acceleratePressed
              ? null
              : () {
                  widget.controller.acceleratePressed = true;
                },
          onReleased: () {
            widget.controller.acceleratePressed = false;
          },
          color: Colors.green,
          size: 60,
        ),
        _ControlButton(
          icon: Icons.arrow_downward,
          onPressed: widget.controller.brakePressed
              ? null
              : () {
                  widget.controller.brakePressed = true;
                },
          onReleased: () {
            widget.controller.brakePressed = false;
          },
          color: Colors.red,
          size: 60,
        ),
      ],
    );
  }
}

class _ControlButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final VoidCallback onReleased;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
    required this.onReleased,
    required this.color,
    this.size = 50,
  });

  @override
  State<_ControlButton> createState() => _ControlButtonState();
}

class _ControlButtonState extends State<_ControlButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          widget.onPressed!();
        }
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onReleased();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        widget.onReleased();
      },
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed
              ? widget.color.withOpacity(0.7)
              : widget.color.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(color: widget.color, width: 2),
        ),
        child: Icon(widget.icon, color: Colors.white, size: widget.size * 0.5),
      ),
    );
  }
}
