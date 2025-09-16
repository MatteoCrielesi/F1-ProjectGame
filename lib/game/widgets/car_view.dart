import 'package:flutter/material.dart';

class CarView extends StatelessWidget {
  final Offset position;
  final Color color;
  final double angle;

  const CarView({
    super.key,
    required this.position,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 20,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
