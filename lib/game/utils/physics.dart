import 'dart:math';

class Physics {
  /// Velocità massima del player per tick
  static const double maxSpeed = 3.0; // aumentata per permettere test più rapidi

  /// Incremento velocità per tick quando si accelera
  static const double acceleration = 0.15; // più veloce a salire di velocità

  /// Decremento velocità per tick quando si frena
  static const double brakeForce = 0.25;

  /// Rallentamento naturale (frizione)
  static const double frictionPerTick = 0.02;

  static double clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  static double applyAcceleration(double speed) =>
      clamp(speed + acceleration, 0, maxSpeed);

  static double applyBrake(double speed) =>
      clamp(speed - brakeForce, 0, maxSpeed);

  static double applyFriction(double speed) =>
      clamp(speed - frictionPerTick, 0, maxSpeed);

  static double degToRad(double deg) => deg * pi / 180.0;
  static double cosDeg(double deg) => cos(degToRad(deg));
  static double sinDeg(double deg) => sin(degToRad(deg));
}
