import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'tire_loader.dart'; // <-- commentata
import 'start_lights.dart'; // <-- importato nuovo widget

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _logoController;
  late final Animation<double> _logoSlide;
  bool _showLoader = false;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoSlide = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeInOutCubic,
    );

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showLoader = true);
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = RadialGradient(
      center: Alignment(0.0, -0.2),
      radius: 1.2,
      colors: [
        Color.fromARGB(255, 28, 28, 28),
        Color(0xFF1A0000),
        Color(0xFF4A0000),
        Color(0xFF8B0000),
      ],
      stops: [0.0, 0.5, 0.8, 1.0],
    );

    return Container(
      decoration: const BoxDecoration(gradient: bg),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final logoWidth = math.min(constraints.maxWidth * 0.45, 520.0);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _logoSlide,
                    builder: (context, child) {
                      final dy = -30.0 * _logoSlide.value;
                      return Transform.translate(
                        offset: Offset(0, dy),
                        child: child,
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/f1_logo.svg',
                      width: logoWidth,
                      colorFilter: const ColorFilter.mode(
                        Color(0xFFE10600),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: _showLoader
                        ? const Padding(
                            padding: EdgeInsets.only(top: 32),
                            // child: TireLoader( // <-- commentata
                            //   size: 80,
                            //   rotationPeriodMs: 1200,
                            //   colorChangePeriodMs: 800,
                            // ),
                            child: StartLights( // <-- nuovo widget
                              size: 80,
                              lightCount: 5,
                              showStartButton: true,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
