import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import 'package:flutter/services.dart';

class GameControls extends StatefulWidget {
  final GameController controller;
  final bool controlsEnabled;
  final bool isLandscape;
  final bool isLeftSide;
  final bool showBothButtons;
  
  const GameControls({
    super.key,
    required this.controller,
    required this.controlsEnabled,
    this.isLandscape = false,
    this.isLeftSide = true,
    this.showBothButtons = false,
  });

  @override
  State<GameControls> createState() => _GameControlsState();
}

class _GameControlsState extends State<GameControls> {
  final Set<LogicalKeyboardKey> _pressed = {};

  // Determina se siamo su mobile
  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

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
    if (!widget.controlsEnabled) return;
    
    setState(() {
      widget.controller.acceleratePressed = pressed;
    });
  }

  void _pressBrake(bool pressed) {
    if (!widget.controlsEnabled) return;
    
    setState(() {
      widget.controller.brakePressed = pressed;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Se non siamo su mobile, non mostrare i pulsanti touch
    if (!_isMobile) return const SizedBox.shrink();

    // Se showBothButtons è true, mostra entrambi i pulsanti in colonna
    if (widget.showBothButtons) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Pulsante Accelerare
          _buildControlButton(
            icon: Icons.arrow_upward,
            color: Colors.green[700]!,
            onPressed: () => _pressAccelerate(true),
            onReleased: () => _pressAccelerate(false),
          ),
          
          const SizedBox(height: 20),
          
          // Pulsante Frenare
          _buildControlButton(
            icon: Icons.arrow_downward,
            color: Colors.red[700]!,
            onPressed: () => _pressBrake(true),
            onReleased: () => _pressBrake(false),
          ),
        ],
      );
    }

    // Layout per orientamento orizzontale (singolo pulsante per lato)
    if (widget.isLandscape) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLeftSide)
            // Controllo acceleratore a sinistra
            _buildControlButton(
              icon: Icons.arrow_upward,
              color: Colors.green[700]!,
              onPressed: () => _pressAccelerate(true),
              onReleased: () => _pressAccelerate(false),
            )
          else
            // Controllo freno/retromarcia a destra
            _buildControlButton(
              icon: Icons.arrow_downward,
              color: Colors.red[700]!,
              onPressed: () => _pressBrake(true),
              onReleased: () => _pressBrake(false),
            ),
        ],
      );
    }

    // Layout per orientamento verticale (originale)
    return Column(
      children: [
        // Pulsante Accelerare
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.arrow_upward,
              color: Colors.green[700]!,
              onPressed: () => _pressAccelerate(true),
              onReleased: () => _pressAccelerate(false),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Pulsante Frenare
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.arrow_downward,
              color: Colors.red[700]!,
              onPressed: () => _pressBrake(true),
              onReleased: () => _pressBrake(false),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required VoidCallback onReleased,
  }) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      onTapCancel: onReleased,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: color.withOpacity(widget.controlsEnabled ? 0.8 : 0.3),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 32,
        ),
      ),
    );
  }
}