import 'dart:math';

class Physics {
  static const double maxSpeed =
      1.01; // velocità massima per tick (display pixels)
  static const double acceleration = 0.05; // incremento velocità per tick
  static const double brakeForce = 0.08; // decremento velocità per freno
  static const double frictionPerTick = 0.01; // rallentamento naturale

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
