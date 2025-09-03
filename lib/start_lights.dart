import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class StartLights extends StatefulWidget {
  const StartLights({
    super.key,
    this.size,
    this.lightCount = 5,
    this.initialDelay = const Duration(milliseconds: 400),
    this.interval = const Duration(milliseconds: 700),
    this.lightsOutHold = const Duration(milliseconds: 300),
    this.onSequenceComplete,
    this.showStartButton = true,
    this.offColor = const Color(0xFF1C1C1C),
    this.onColor = const Color(0xFFE10600),
    this.glowColor = const Color(0x55E10600),
    this.shadowColor = const Color(0x88000000),
    this.borderColor = const Color(0xFF2A2A2A),
    this.backgroundColor = Colors.transparent,
  });

  final double? size;
  final int lightCount;
  final Duration initialDelay;
  final Duration interval;
  final Duration lightsOutHold;
  final VoidCallback? onSequenceComplete;
  final bool showStartButton;

  final Color offColor;
  final Color onColor;
  final Color glowColor;
  final Color shadowColor;
  final Color borderColor;
  final Color backgroundColor;

  @override
  State<StartLights> createState() => _StartLightsState();
}

class _StartLightsState extends State<StartLights>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  int _lit = 0; // quante luci sono accese
  bool _running = false;
  bool _showLights = false; // stato: mostro luci o bottone
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startSequence() {
    if (_running) return;
    setState(() {
      _running = true;
      _lit = 0;
      _showLights = true; // compare le luci, sparisce il bottone
    });

    // Initial delay
    _timer = Timer(widget.initialDelay, () {
      int step = 0;

      void nextStep() {
        if (!mounted) return;
        step++;
        if (step <= widget.lightCount) {
          setState(() => _lit = step);
          _timer = Timer(widget.interval, nextStep);
        } else {
          // Tutte accese → dopo hold spente
          _timer = Timer(widget.lightsOutHold, () {
            if (!mounted) return;
            setState(() {
              _lit = 0;
              _running = false;
              // ⚠️ NON resetto _showLights, restano spente e visibili
            });
            widget.onSequenceComplete?.call();
          });
        }
      }

      nextStep();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final shortest = c.biggest.shortestSide;
        final totalSize =
            (widget.size ?? (shortest * 0.25)).clamp(160.0, 520.0);
        final lightDiameter = totalSize / 5;
        final width = lightDiameter * widget.lightCount;
        final height = lightDiameter;

        final lights = List<Widget>.generate(widget.lightCount, (i) {
          final isOn = (i < _lit);
          return _LightBulb(
            diameter: lightDiameter,
            isOn: isOn,
            onColor: widget.onColor,
            offColor: widget.offColor,
            glowColor: widget.glowColor,
            borderColor: widget.borderColor,
            shadowColor: widget.shadowColor,
            pulseValue: _pulse.value,
          );
        });

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_showLights) // quando sono visibili, niente bottone
              Container(
                width: width,
                height: height,
                padding: EdgeInsets.all(lightDiameter * 0.06),
                decoration: BoxDecoration(
                  color: widget.backgroundColor,
                  borderRadius: BorderRadius.circular(lightDiameter * 0.15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: lights,
                ),
              )
            else if (widget.showStartButton) // bottone visibile solo prima
              SizedBox(
                height: math.max(36, lightDiameter * 0.32),
                child: FilledButton(
                  onPressed: _running ? null : _startSequence,
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith(
                      (s) => _running
                          ? Colors.grey.shade700
                          : const Color(0xFFE10600),
                    ),
                    foregroundColor: WidgetStateProperty.all(Colors.white),
                    padding: WidgetStateProperty.all(
                      EdgeInsets.symmetric(horizontal: lightDiameter * 0.4),
                    ),
                  ),
                  child: Text(_running ? 'Starting…' : 'Start'),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LightBulb extends StatelessWidget {
  const _LightBulb({
    required this.diameter,
    required this.isOn,
    required this.onColor,
    required this.offColor,
    required this.glowColor,
    required this.borderColor,
    required this.shadowColor,
    required this.pulseValue,
  });

  final double diameter;
  final bool isOn;
  final Color onColor;
  final Color offColor;
  final Color glowColor;
  final Color borderColor;
  final Color shadowColor;
  final double pulseValue;

  @override
  Widget build(BuildContext context) {
    final color = isOn ? onColor : offColor;
    final glow = isOn
        ? glowColor.withOpacity(0.45 + 0.25 * pulseValue)
        : Colors.transparent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          if (isOn)
            BoxShadow(
              color: glow,
              blurRadius: diameter * (0.25 + 0.25 * pulseValue),
              spreadRadius: diameter * (0.05 + 0.03 * pulseValue),
            ),
          BoxShadow(
            color: shadowColor,
            blurRadius: diameter * 0.12,
            offset: Offset(0, diameter * 0.06),
          ),
        ],
        border: Border.all(color: borderColor, width: diameter * 0.06),
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.95,
          colors: isOn
              ? [Colors.white.withOpacity(0.22), color]
              : [Colors.white.withOpacity(0.05), color],
        ),
      ),
    );
  }
}




//import 'dart:async';
//import 'dart:math' as math;
//import 'package:flutter/material.dart';
//
//class StartLights extends StatefulWidget {
//  const StartLights({
//    super.key,
//    this.size,
//    this.lightCount = 5,
//    this.initialDelay = const Duration(milliseconds: 400),
//    this.interval = const Duration(milliseconds: 700),
//    this.lightsOutHold = const Duration(milliseconds: 300),
//    this.onSequenceComplete,
//    this.showStartButton = true,
//    this.offColor = const Color(0xFF1C1C1C),
//    this.onColor = const Color(0xFFE10600),
//    this.glowColor = const Color(0x55E10600),
//    this.shadowColor = const Color(0x88000000),
//    this.borderColor = const Color(0xFF2A2A2A),
//    this.backgroundColor = Colors.transparent,
//  });
//
//  final double? size;
//  final int lightCount;
//  final Duration initialDelay;
//  final Duration interval;
//  final Duration lightsOutHold;
//  final VoidCallback? onSequenceComplete;
//  final bool showStartButton;
//
//  final Color offColor;
//  final Color onColor;
//  final Color glowColor;
//  final Color shadowColor;
//  final Color borderColor;
//  final Color backgroundColor;
//
//  @override
//  State<StartLights> createState() => _StartLightsState();
//}
//
//class _StartLightsState extends State<StartLights>
//    with TickerProviderStateMixin {
//  late final AnimationController _pulse;
//  int _lit = 0; // quante luci sono accese
//  bool _running = false;
//  bool _showLights = false; // <-- nuovo stato
//  Timer? _timer;
//
//  @override
//  void initState() {
//    super.initState();
//    _pulse = AnimationController(
//      vsync: this,
//      duration: const Duration(milliseconds: 900),
//    )..repeat(reverse: true);
//  }
//
//  @override
//  void dispose() {
//    _pulse.dispose();
//    _timer?.cancel();
//    super.dispose();
//  }
//
//  void _startSequence() {
//    if (_running) return;
//    setState(() {
//      _running = true;
//      _lit = 0;
//      _showLights = true; // compare solo le luci, il bottone sparisce
//    });
//
//    // Initial delay
//    _timer = Timer(widget.initialDelay, () {
//      int step = 0;
//
//      void nextStep() {
//        if (!mounted) return;
//        step++;
//        if (step <= widget.lightCount) {
//          setState(() => _lit = step);
//          _timer = Timer(widget.interval, nextStep);
//        } else {
//          // Tutte accese → dopo hold spente
//          _timer = Timer(widget.lightsOutHold, () {
//            if (!mounted) return;
//            setState(() {
//              _lit = 0;
//              _running = false;
//              // ⚠️ NON metto più _showLights = false
//            });
//            widget.onSequenceComplete?.call();
//          });
//        }
//      }
//
//      nextStep();
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return LayoutBuilder(
//      builder: (context, c) {
//        final shortest = c.biggest.shortestSide;
//        final totalSize =
//            (widget.size ?? (shortest * 0.25)).clamp(160.0, 520.0);
//        final lightDiameter = totalSize / 5;
//        final spacing = lightDiameter * 0.15;
//        final width = (lightDiameter * widget.lightCount) +
//            (spacing * (widget.lightCount - 1));
//        final height = lightDiameter;
//
//        final lights = List<Widget>.generate(widget.lightCount, (i) {
//          final isOn = (i < _lit);
//          return _LightBulb(
//            diameter: lightDiameter,
//            isOn: isOn,
//            onColor: widget.onColor,
//            offColor: widget.offColor,
//            glowColor: widget.glowColor,
//            borderColor: widget.borderColor,
//            shadowColor: widget.shadowColor,
//            pulseValue: _pulse.value,
//          );
//        });
//
//        return Column(
//          mainAxisSize: MainAxisSize.min,
//          children: [
//            if (_showLights) // quando sono visibili, niente bottone
//              Container(
//                width: width,
//                height: height,
//                padding: EdgeInsets.all(lightDiameter * 0.06),
//                decoration: BoxDecoration(
//                  color: widget.backgroundColor,
//                  borderRadius: BorderRadius.circular(lightDiameter * 0.15),
//                ),
//                child: Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                  children: [
//                    for (int i = 0; i < lights.length; i++) ...[
//                      lights[i],
//                      if (i < lights.length - 1) SizedBox(width: spacing),
//                    ],
//                  ],
//                ),
//              )
//            else if (widget.showStartButton) // bottone visibile solo prima
//              SizedBox(
//                height: math.max(36, lightDiameter * 0.32),
//                child: FilledButton(
//                  onPressed: _running ? null : _startSequence,
//                  style: ButtonStyle(
//                    backgroundColor: WidgetStateProperty.resolveWith(
//                      (s) => _running
//                          ? Colors.grey.shade700
//                          : const Color(0xFFE10600),
//                    ),
//                    foregroundColor: WidgetStateProperty.all(Colors.white),
//                    padding: WidgetStateProperty.all(
//                      EdgeInsets.symmetric(horizontal: lightDiameter * 0.4),
//                    ),
//                  ),
//                  child: Text(_running ? 'Starting…' : 'Start'),
//                ),
//              ),
//          ],
//        );
//      },
//    );
//  }
//}
//
//class _LightBulb extends StatelessWidget {
//  const _LightBulb({
//    required this.diameter,
//    required this.isOn,
//    required this.onColor,
//    required this.offColor,
//    required this.glowColor,
//    required this.borderColor,
//    required this.shadowColor,
//    required this.pulseValue,
//  });
//
//  final double diameter;
//  final bool isOn;
//  final Color onColor;
//  final Color offColor;
//  final Color glowColor;
//  final Color borderColor;
//  final Color shadowColor;
//  final double pulseValue;
//
//  @override
//  Widget build(BuildContext context) {
//    final color = isOn ? onColor : offColor;
//    final glow = isOn
//        ? glowColor.withOpacity(0.45 + 0.25 * pulseValue)
//        : Colors.transparent;
//
//    return AnimatedContainer(
//      duration: const Duration(milliseconds: 200),
//      curve: Curves.easeOut,
//      width: diameter,
//      height: diameter,
//      decoration: BoxDecoration(
//        shape: BoxShape.circle,
//        color: color,
//        boxShadow: [
//          if (isOn)
//            BoxShadow(
//              color: glow,
//              blurRadius: diameter * (0.25 + 0.25 * pulseValue),
//              spreadRadius: diameter * (0.05 + 0.03 * pulseValue),
//            ),
//          BoxShadow(
//            color: shadowColor,
//            blurRadius: diameter * 0.12,
//            offset: Offset(0, diameter * 0.06),
//          ),
//        ],
//        border: Border.all(color: borderColor, width: diameter * 0.06),
//        gradient: RadialGradient(
//          center: const Alignment(-0.3, -0.3),
//          radius: 0.95,
//          colors: isOn
//              ? [Colors.white.withOpacity(0.22), color]
//              : [Colors.white.withOpacity(0.05), color],
//        ),
//      ),
//    );
//  }
//}