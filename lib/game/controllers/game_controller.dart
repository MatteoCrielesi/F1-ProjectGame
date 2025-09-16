// lib/game/controllers/game_controller.dart
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../utils/physics.dart';

class GameController extends ChangeNotifier {
  // selected
  Circuit circuit;
  CarModel carModel;

  // visual/display mapping (set by CircuitView when layout is ready)
  Size displaySize = Size.zero; // widget size where svg is drawn
  Offset displayTopLeftGlobal = Offset.zero; // global offset of the widget
  double displayToMaskScaleX = 1.0;
  double displayToMaskScaleY = 1.0;

  // mask image data
  ui.Image? _maskImage;
  Uint8List? _maskPixels; // rgba bytes
  int maskWidth = 0;
  int maskHeight = 0;

  // car state in display coordinates
  Offset carPos = Offset.zero; // position in display coordinates (left/top)
  double carAngle = 0.0; // degrees (0 = right)
  double speed = 0.0;

  // game loop
  Timer? _gameTimer;
  int tickMs = 16; // ~60 Hz

  // off-track handling
  bool _isOffTrack = false;
  int _offTrackTicks = 0;
  static const int offTrackRespawnTicks = 40; // after ~40 ticks respawn
  Offset _lastOnTrackPos = Offset.zero;

  GameController({required this.circuit, required this.carModel});

  // ---------- mask loading ----------
  Future<void> loadMask() async {
    final bytes = await rootBundle.load(circuit.maskPath);
    final data = bytes.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    _maskImage = frame.image;
    maskWidth = _maskImage!.width;
    maskHeight = _maskImage!.height;
    final byteData = await _maskImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
    _maskPixels = byteData!.buffer.asUint8List();
    // compute scale if display is already known
    _updateScale();
    // compute a reasonable spawn point if display known
    if (displaySize != Size.zero) {
      _initSpawnAtCenterTrack();
    }
    notifyListeners();
  }

  // Called by CircuitView when SVG widget is laid out and positioned
  void updateDisplayLayout({required Size size, required Offset topLeftGlobal}) {
    displaySize = size;
    displayTopLeftGlobal = topLeftGlobal;
    _updateScale();
    if (_maskImage != null) {
      _initSpawnAtCenterTrack();
    }
  }

  void _updateScale() {
    if (_maskImage == null || displaySize == Size.zero) return;
    displayToMaskScaleX = maskWidth / displaySize.width;
    displayToMaskScaleY = maskHeight / displaySize.height;
  }

  // ---------- spawn: find nearest black pixel to center ----------
  void _initSpawnAtCenterTrack() {
    // find center display coords mapped to mask
    final centerDisplay = Offset(displaySize.width / 2, displaySize.height / 2);
    final centerMask = _displayToMask(centerDisplay);
    final start = _findNearestTrackPixel(centerMask.dx.toInt(), centerMask.dy.toInt(), maxRadius: 400);
    if (start != null) {
      carPos = _maskToDisplay(Offset(start.dx.toDouble(), start.dy.toDouble()));
      _lastOnTrackPos = carPos;
    } else {
      // fallback: center
      carPos = centerDisplay;
      _lastOnTrackPos = carPos;
    }
    speed = 0;
    carAngle = 0;
    notifyListeners();
  }

  // spiral search for nearest black pixel in mask around (mx,my)
  Offset? _findNearestTrackPixel(int mx, int my, {int maxRadius = 200}) {
    if (_maskPixels == null) return null;
    bool isTrack(int x, int y) {
      if (x < 0 || y < 0 || x >= maskWidth || y >= maskHeight) return false;
      final idx = (y * maskWidth + x) * 4;
      final r = _maskPixels![idx];
      final g = _maskPixels![idx + 1];
      final b = _maskPixels![idx + 2];
      // consider pixel track if dark (close to black)
      final brightness = (r + g + b) / 3;
      return brightness < 80; // threshold
    }

    if (isTrack(mx, my)) return Offset(mx.toDouble(), my.toDouble());

    for (int r = 1; r <= maxRadius; r++) {
      for (int dx = -r; dx <= r; dx++) {
        final xs = [mx + dx, mx - dx];
        final ys = [my + r, my - r];
        for (final x in xs) {
          for (final y in ys) {
            if (x >= 0 && y >= 0 && x < maskWidth && y < maskHeight) {
              if (isTrack(x, y)) return Offset(x.toDouble(), y.toDouble());
            }
          }
        }
      }
    }
    return null;
  }

  // ---------- coordinate transforms ----------
  // display coords (0..displaySize) -> mask coords (0..maskWidth/height)
  Offset _displayToMask(Offset display) {
    final mx = (display.dx * displayToMaskScaleX).clamp(0, maskWidth - 1).toDouble();
    final my = (display.dy * displayToMaskScaleY).clamp(0, maskHeight - 1).toDouble();
    return Offset(mx, my);
  }

  // mask coords -> display coords
  Offset _maskToDisplay(Offset mask) {
    final dx = (mask.dx / displayToMaskScaleX).clamp(0, displaySize.width).toDouble();
    final dy = (mask.dy / displayToMaskScaleY).clamp(0, displaySize.height).toDouble();
    return Offset(dx, dy);
  }

  // ---------- collision / onTrack sampling ----------
  bool _isOnTrackAtDisplayPoint(Offset displayPoint) {
    if (_maskPixels == null || displaySize == Size.zero) return true;
    final maskPt = _displayToMask(displayPoint);
    final x = maskPt.dx.toInt();
    final y = maskPt.dy.toInt();
    if (x < 0 || y < 0 || x >= maskWidth || y >= maskHeight) return false;
    final idx = (y * maskWidth + x) * 4;
    final r = _maskPixels![idx];
    final g = _maskPixels![idx + 1];
    final b = _maskPixels![idx + 2];
    final brightness = (r + g + b) / 3;
    return brightness < 100; // threshold
  }

  // sample multiple points around car (center + front left + front right + rear)
  bool _isCarOnTrack() {
    final center = carPos;
    // define car size in display coords (visual). tweak as needed
    final carHalfWidth = 10.0;
    final carHalfLength = 20.0;
    final angleRad = Physics.degToRad(carAngle);

    List<Offset> samplePoints = [];

    // center
    samplePoints.add(center);

    // front center
    final front = Offset(
      center.dx + Physics.cosDeg(carAngle) * carHalfLength,
      center.dy + Physics.sinDeg(carAngle) * carHalfLength,
    );
    samplePoints.add(front);

    // rear center
    final rear = Offset(
      center.dx - Physics.cosDeg(carAngle) * (carHalfLength / 1.6),
      center.dy - Physics.sinDeg(carAngle) * (carHalfLength / 1.6),
    );
    samplePoints.add(rear);

    // front-left
    final fl = Offset(
      front.dx - Physics.sinDeg(carAngle) * (carHalfWidth),
      front.dy + Physics.cosDeg(carAngle) * (carHalfWidth),
    );
    // front-right
    final fr = Offset(
      front.dx + Physics.sinDeg(carAngle) * (carHalfWidth),
      front.dy - Physics.cosDeg(carAngle) * (carHalfWidth),
    );
    samplePoints.add(fl);
    samplePoints.add(fr);

    // sample them
    int onTrackCount = 0;
    for (final p in samplePoints) {
      if (_isOnTrackAtDisplayPoint(p)) onTrackCount++;
    }

    // consider on track if majority of samples are on track
    return onTrackCount >= (samplePoints.length / 2).ceil();
  }

  // ---------- movement & controls ----------
  void accelerate() {
    speed = Physics.applyAcceleration(speed);
  }

  void brake() {
    speed = Physics.applyBrake(speed);
  }

  void steerLeft() {
    carAngle -= Physics.steerSpeedDeg;
    if (carAngle <= -360) carAngle += 360;
  }

  void steerRight() {
    carAngle += Physics.steerSpeedDeg;
    if (carAngle >= 360) carAngle -= 360;
  }

  // should be called each tick
  void tick() {
    // apply friction
    speed = Physics.applyFriction(speed);

    // apply movement based on angle
    final dx = Physics.cosDeg(carAngle) * speed;
    final dy = Physics.sinDeg(carAngle) * speed;
    carPos = Offset(carPos.dx + dx, carPos.dy + dy);

    // boundary check display
    if (carPos.dx < 0) carPos = Offset(0, carPos.dy);
    if (carPos.dy < 0) carPos = Offset(carPos.dx, 0);
    if (carPos.dx > displaySize.width) carPos = Offset(displaySize.width, carPos.dy);
    if (carPos.dy > displaySize.height) carPos = Offset(carPos.dx, displaySize.height);

    // on track check
    final onTrack = _isCarOnTrack();
    if (onTrack) {
      _isOffTrack = false;
      _offTrackTicks = 0;
      _lastOnTrackPos = carPos;
    } else {
      // off track handling
      if (!_isOffTrack) {
        _isOffTrack = true;
        _offTrackTicks = 0;
      } else {
        _offTrackTicks++;
        // progressive penalty: slow down
        speed = speed * 0.85;
        if (_offTrackTicks >= offTrackRespawnTicks) {
          // respawn near last on-track
          carPos = _lastOnTrackPos;
          speed = 0;
          _isOffTrack = false;
          _offTrackTicks = 0;
        }
      }
    }

    notifyListeners();
  }

  // ---------- game loop start/stop ----------
  void start() {
    stop();
    _gameTimer = Timer.periodic(Duration(milliseconds: tickMs), (_) => tick());
  }

  void stop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  void disposeController() {
    stop();
  }
}
