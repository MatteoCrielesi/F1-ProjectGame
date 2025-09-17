// lib/game/utils/physics.dart
import 'dart:math';

class Physics {
  static const double maxSpeed = 10.0; // in display pixels per tick (tweak)
  static const double acceleration = 0.5;
  static const double brakeForce = 1.0;
  static const double frictionPerTick = 0.05;

  static double clamp(double v, double min, double max) => v < min ? min : (v > max ? max : v);

  static double applyAcceleration(double speed) => clamp(speed + acceleration, 0, maxSpeed);
  static double applyBrake(double speed) => clamp(speed - brakeForce, 0, maxSpeed);
  static double applyFriction(double speed) => clamp(speed - frictionPerTick, 0, maxSpeed);

  static double degToRad(double deg) => deg * pi / 180.0;
  static double cosDeg(double deg) => cos(degToRad(deg));
  static double sinDeg(double deg) => sin(degToRad(deg));
}
