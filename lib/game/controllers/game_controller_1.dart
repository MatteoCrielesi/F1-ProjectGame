import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../models/circuit.dart';
import '../models/car.dart';
import '../utils/physics.dart';

class GameController extends ChangeNotifier {
  Circuit circuit;
  CarModel carModel;

  // display mapping
  Size displaySize = Size.zero;
  double displayToMaskScaleX = 1.0;
  double displayToMaskScaleY = 1.0;

  // mask image
  ui.Image? _maskImage;
  Uint8List? _maskPixels;
  int maskWidth = 0;
  int maskHeight = 0;

  // track points
  List<Offset> _trackMaskPoints = [];
  List<Offset> trackPointsDisplay = [];

  // car state
  double _progress = 0.0;
  double speed = 0.0;
  bool disqualified = false;
  Offset _lastGoodPos = Offset.zero;
  int _offTrackTicks = 0;
  static const int offTrackRespawnTicks = 40;

  Timer? _gameTimer;
  int tickMs = 16;

  GameController({required this.circuit, required this.carModel});

  // ---------------- mask loading ----------------
  Future<void> loadMask() async {
    try {
      final bytes = await rootBundle.load(circuit.maskPath);
      final data = bytes.buffer.asUint8List();
      final codec = await ui.instantiateImageCodec(data);
      final frame = await codec.getNextFrame();
      _maskImage = frame.image;
      maskWidth = _maskImage!.width;
      maskHeight = _maskImage!.height;
      final byteData = await _maskImage!.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      _maskPixels = byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint('Errore caricamento mask: $e');
      return;
    }

    _updateScale();
    _buildTrackCenterlineFromMask();
    if (displaySize != Size.zero) {
      _mapTrackToDisplay();
    }
    _initSpawnAtRedPixel();
    notifyListeners();
  }

  void updateDisplayLayout({required Size size}) {
    displaySize = size;
    _updateScale();
    if (_trackMaskPoints.isNotEmpty) {
      _mapTrackToDisplay();
    }
  }

  void _updateScale() {
    if (_maskImage == null || displaySize == Size.zero) return;
    displayToMaskScaleX = maskWidth / displaySize.width;
    displayToMaskScaleY = maskHeight / displaySize.height;
  }

  // ---------------- build track centerline ----------------
  void _buildTrackCenterlineFromMask() {
    _trackMaskPoints.clear();
    if (_maskPixels == null) return;

    bool isTrackPixel(int x, int y) {
      if (x < 0 || y < 0 || x >= maskWidth || y >= maskHeight) return false;
      final idx = (y * maskWidth + x) * 4;
      final r = _maskPixels![idx];
      final g = _maskPixels![idx + 1];
      final b = _maskPixels![idx + 2];
      // grigio = percorso
      return r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200;
    }

    for (int y = 0; y < maskHeight; y++) {
      for (int x = 0; x < maskWidth; x++) {
        if (isTrackPixel(x, y)) {
          _trackMaskPoints.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }

    debugPrint("Track pixels extracted: ${_trackMaskPoints.length}");
  }

  // ---------------- map track to display ----------------
  void _mapTrackToDisplay() {
    trackPointsDisplay = _trackMaskPoints
        .map((m) => _maskToDisplay(m))
        .toList();
  }

  // ---------------- spawn on first red pixel ----------------
  void _initSpawnAtRedPixel() {
    if (_maskPixels == null) return;

    for (int y = 0; y < maskHeight; y++) {
      for (int x = 0; x < maskWidth; x++) {
        final idx = (y * maskWidth + x) * 4;
        final r = _maskPixels![idx];
        final g = _maskPixels![idx + 1];
        final b = _maskPixels![idx + 2];

        if (r > 150 && g < 100 && b < 100) {
          final start = _maskToDisplay(Offset(x.toDouble(), y.toDouble()));
          _lastGoodPos = start;
          _progress = 0.0;
          speed = 0.0;
          disqualified = false;
          notifyListeners();
          return;
        }
      }
    }
  }

  Offset _maskToDisplay(Offset mask) {
    return Offset(
      (mask.dx / displayToMaskScaleX).clamp(0, displaySize.width),
      (mask.dy / displayToMaskScaleY).clamp(0, displaySize.height),
    );
  }

  Offset get carPosition {
    if (trackPointsDisplay.isEmpty)
      return Offset(displaySize.width / 2, displaySize.height / 2);
    return _lastGoodPos;
  }

  // ---------------- controls ----------------
  void accelerate() {
    if (disqualified) return;
    speed = Physics.applyAcceleration(speed);
  }

  void brake() {
    if (disqualified) return;
    speed = Physics.applyBrake(speed);
  }

  // ---------------- tick ----------------
  void tick() {
    if (disqualified || trackPointsDisplay.isEmpty) {
      notifyListeners();
      return;
    }

    // friction
    speed = Physics.applyFriction(speed);

    // move car along track
    Offset pos = _lastGoodPos + Offset(speed, 0); // placeholder, lineare

    // check curve speed rules (placeholder)
    double optimalSpeed = Physics.maxSpeed * 0.7;
    if (speed < optimalSpeed * 0.6) {
      // low speed
    } else if ((speed - optimalSpeed).abs() <= optimalSpeed * 0.15) {
      speed = min(Physics.maxSpeed, speed + 0.3);
    } else if (speed < optimalSpeed * 1.2) {
      speed *= 0.92;
    } else if (speed < optimalSpeed * 1.5) {
      _handleOffTrack();
      notifyListeners();
      return;
    } else {
      disqualified = true;
      notifyListeners();
      return;
    }

    if (!_isDisplayPointOnTrack(pos)) {
      _offTrackTicks++;
      speed *= 0.7;
      if (_offTrackTicks >= offTrackRespawnTicks) {
        _respawnToLastGood();
      }
    } else {
      _lastGoodPos = pos;
      _offTrackTicks = 0;
    }

    notifyListeners();
  }

  bool _isDisplayPointOnTrack(Offset displayPoint) {
    if (_maskPixels == null) return true;
    final maskPt = Offset(
      (displayPoint.dx * displayToMaskScaleX).clamp(0, maskWidth - 1),
      (displayPoint.dy * displayToMaskScaleY).clamp(0, maskHeight - 1),
    );
    final x = maskPt.dx.toInt();
    final y = maskPt.dy.toInt();
    final idx = (y * maskWidth + x) * 4;
    final r = _maskPixels![idx];
    final g = _maskPixels![idx + 1];
    final b = _maskPixels![idx + 2];

    // grigio = percorso
    return r > 100 && r < 200 && g > 100 && g < 200 && b > 100 && b < 200;
  }

  void _handleOffTrack() {
    _respawnToLastGood();
    speed = 0.05;
  }

  void _respawnToLastGood() {
    _offTrackTicks = 0;
    speed = 0.0;
  }

  // ---------------- loop control ----------------
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
