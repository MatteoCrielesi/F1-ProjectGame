import 'dart:math' as math;
import 'package:f1_project/scuderie_page.dart';
import 'package:flutter/material.dart';
import 'package:f1_project/stats_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:f1_project/ranking_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _sweep;
  final GlobalKey _calendarButtonKey = GlobalKey();
  double? _buttonCenterY;
  Size? _lastLogicalSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureButtonY());
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scheduleReMeasure();
  }

  void _scheduleReMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureButtonY());
  }

  void _measureButtonY() {
    final ctx = _calendarButtonKey.currentContext;
    if (ctx == null) return;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return;

    final pos = box.localToGlobal(Offset.zero);
    final size = box.size;
    final topPadding = MediaQuery.of(context).padding.top;
    final centerY = pos.dy + size.height / 2.0;
    final newY = centerY - topPadding;

    if (_buttonCenterY == null || (newY - _buttonCenterY!).abs() > 0.5) {
      setState(() => _buttonCenterY = newY);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sweep.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isWide = mq.size.width >= 900;
    final isTablet = mq.size.width >= 600 && mq.size.width < 900;

    if (_lastLogicalSize != mq.size) {
      _lastLogicalSize = mq.size;
      _scheduleReMeasure();
    }

    final cards = <Widget>[
      _ScuderieCard(
        title: 'Scuderie',
        body:
            'Explore all teams, lineups,\nand liveries for the\ncurrent season.',
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ScuderiePage()),
          );
        },
      ),
      _RankingsCard(
        title: 'Classifiche',
        body: 'Keep up with driver and\nconstructor standings,\nrace by race.',
        onTap: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const RankingPage()),
          );
        },
      ),
      _StatisticsCard(
  title: 'Statistiche',
  body: 'Dive into pace, poles,\npodiums, and fastest lap\nmetrics.',
  onTap: () {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => StatistichePage()),
    );
  },
),

    ];

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0D0D),
                  Color(0xFF1A0000),
                  Color(0xFF2B0000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: const Color(0xFFE10600)),
          ),
          AnimatedBuilder(
            animation: _sweep,
            builder: (context, _) {
              if (_buttonCenterY == null) return const SizedBox.shrink();
              return CustomPaint(
                painter: _SweepPainter(
                  progress: _sweep.value,
                  overrideY: _buttonCenterY,
                ),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 16, 8, 12),
                    child: _Header(),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        if (isWide) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: cards
                                .map(
                                  (w) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: w,
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        } else if (isTablet) {
                          return GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            children: cards,
                          );
                        } else {
                          return ListView.separated(
                            itemCount: cards.length,
                            itemBuilder: (_, i) => cards[i],
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 16),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: OutlinedButton(
                      key: _calendarButtonKey,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFF131313),
                        foregroundColor: const Color(0xFFFF0600),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 22,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () {
                        debugPrint('Navigate to Calendario page');
                      },
                      child: const Text('Race Calendar'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SweepPainter extends CustomPainter {
  _SweepPainter({required this.progress, this.overrideY});
  final double progress;
  final double? overrideY;

  @override
  void paint(Canvas canvas, Size size) {
    if (overrideY == null) return;
    final y = overrideY!.clamp(0.0, size.height * 0.948);
    final bandHeight = math.max(2.0, size.height * 0.003);
    final segmentWidth = size.width * 0.25;
    final travelWidth = size.width + segmentWidth;
    final startX = -segmentWidth + progress * travelWidth;
    final rect = Rect.fromLTWH(
      startX,
      y - bandHeight / 10,
      segmentWidth,
      bandHeight,
    );

    final shader = const LinearGradient(
      colors: [Colors.transparent, Color(0xFFE10600), Colors.transparent],
      stops: [0.0, 0.5, 1.0],
    ).createShader(rect);

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.srcOver;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(bandHeight));
    canvas.drawRRect(rrect, paint);

    final basePaint = Paint()
      ..color = const Color(0x33E10600)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(16, y + bandHeight),
      Offset(size.width - 16, y + bandHeight),
      basePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SweepPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.overrideY != overrideY;
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/f1_logo.svg', height: 24),
        const SizedBox(width: 12),
        Text(
          'Formula 1',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

/// Special card for Scuderie with hover logos
class _ScuderieCard extends StatefulWidget {
  const _ScuderieCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  State<_ScuderieCard> createState() => _ScuderieCardState();
}

class _ScuderieCardState extends State<_ScuderieCard> {
  bool _hovering = false;
  String? _logo;

  final List<String> _logos = [
    'assets/logos/ferrari.png',
    'assets/logos/redbull.png',
    'assets/logos/mercedes.png',
    'assets/logos/mclaren.png',
    'assets/logos/alpine.png',
    'assets/logos/astonmartin.png',
    'assets/logos/haas.png',
    'assets/logos/williams.png',
    'assets/logos/kicksauber.png',
    'assets/logos/racingbulls.png',
  ];

  void _pickRandomLogo() {
    final rand = math.Random();
    setState(() {
      _logo = _logos[rand.nextInt(_logos.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 400;

    return MouseRegion(
      onEnter: (_) {
        _pickRandomLogo();
        setState(() => _hovering = true);
      },
      onExit: (_) => setState(() => _hovering = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        onLongPress: () {
          _pickRandomLogo();
          setState(() => _hovering = true);
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(85, 255, 4, 0),
            border: Border.all(color: const Color.fromARGB(255, 255, 6, 0)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_hovering && _logo != null)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.12,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: Image.asset(_logo!),
                    ),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: isSmall ? 13 : 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Special card for Rankings with slide-up text and podium
class _RankingsCard extends StatefulWidget {
  const _RankingsCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  State<_RankingsCard> createState() => _RankingsCardState();
}

class _RankingsCardState extends State<_RankingsCard>
    with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late final AnimationController _controller;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.2),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 400;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        if (!isSmall) _controller.forward();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        if (!isSmall) _controller.reverse();
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(85, 255, 4, 0),
            border: Border.all(color: const Color.fromARGB(255, 255, 6, 0)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Podium image
              Positioned.fill(
                child: Opacity(
                  opacity: _hovering ? 0.15 : 0.0,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: isSmall
                        ? Alignment.center
                        : Alignment.bottomCenter,
                    child: Image.asset('assets/podium.png'),
                  ),
                ),
              ),
              // Text with optional slide
              SlideTransition(
                position: _slide,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.body,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: isSmall ? 13 : 15,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatisticsCard extends StatefulWidget {
  const _StatisticsCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  State<_StatisticsCard> createState() => _StatisticsCardState();
}

class _StatisticsCardState extends State<_StatisticsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
  }

  void _startFireworks() {
    _controller.repeat();
  }

  void _stopFireworks() {
    _controller.stop();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 400;

    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        _startFireworks();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        _stopFireworks();
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: widget.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(85, 255, 4, 0),
            border: Border.all(color: const Color.fromARGB(255, 255, 6, 0)),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(20),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_hovering)
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _MultipleFireworksPainter(_controller.value),
                      );
                    },
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSmall ? 16 : 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.body,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: isSmall ? 13 : 15,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MultipleFireworksPainter extends CustomPainter {
  final double progress;
  final math.Random _rand = math.Random();

  _MultipleFireworksPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 2;

    // Disegna più fuochi (3-5 contemporanei)
    for (int f = 0; f < 4; f++) {
      final baseX = size.width * (0.2 + 0.6 * _rand.nextDouble());
      final startY = size.height;
      final peakY = size.height * (0.3 + 0.3 * _rand.nextDouble());

      if (progress < 0.4) {
        // 🚀 Razzo che sale
        final t = progress / 0.4;
        final y = startY - (startY - peakY) * t;
        paint.color = Colors.orangeAccent;
        canvas.drawCircle(
          Offset(baseX, y),
          3,
          paint..style = PaintingStyle.fill,
        );
      } else {
        // 💥 Esplosione
        final t = (progress - 0.4) / 0.6;
        final center = Offset(baseX, peakY);
        final maxRadius = size.shortestSide * 0.4;

        for (int i = 0; i < 20; i++) {
          final angle = (2 * math.pi / 20) * i;
          final dx = center.dx + maxRadius * t * math.cos(angle);
          final dy = center.dy + maxRadius * t * math.sin(angle);

          paint
            ..color = Colors.primaries[(i + f) % Colors.primaries.length]
                .withOpacity(1 - t)
            ..strokeWidth = 2 * (1 - t);
          canvas.drawLine(center, Offset(dx, dy), paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MultipleFireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Normal card for other sections
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 400;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(85, 255, 4, 0),
          border: Border.all(color: const Color.fromARGB(255, 255, 6, 0)),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmall ? 16 : 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              body,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: isSmall ? 13 : 15,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
