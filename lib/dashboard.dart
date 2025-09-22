import 'package:f1_project/game_page_1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _sweep;
  Size? _lastLogicalSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sweep = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
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
    final isLandscape = mq.orientation == Orientation.landscape;
    final isWide = mq.size.width >= 900;

    if (_lastLogicalSize != mq.size) {
      _lastLogicalSize = mq.size;
    }

    final cards = <Widget>[
      _InfoCard(
        title: 'Challenge',
        icon: Icons.timer,
        type: 'challenge',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GamePage_1(selectedType: 'challenge'),
            ),
          );
        },
      ),
      _InfoCard(
        title: 'Race Bots',
        icon: null,
        type: 'bots',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GamePage_1(selectedType: 'bots'),
            ),
          );
        },
      ),
      _InfoCard(
        title: 'Local Race',
        icon: null,
        type: 'local',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const GamePage_1(selectedType: 'local'),
            ),
          );
        },
      ),
    ];

    // calcolo numero di colonne in base all'orientamento e larghezza
    int columns = 1;
    if (isWide || isLandscape) {
      columns = 3;
    } else if (mq.size.width >= 600) {
      columns = 2;
    }

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
            child: Container(height: 3, color: Color(0xFFE10600)),
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
                      builder: (context, constraints) {
                        double cardWidth =
                            (constraints.maxWidth - (columns - 1) * 16) /
                            columns;
                        double cardHeight =
                            (constraints.maxHeight -
                                ((cards.length / columns).ceil() - 1) * 16) /
                            (cards.length / columns).ceil();

                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: cards
                              .map(
                                (card) => SizedBox(
                                  width: cardWidth,
                                  height: cardHeight,
                                  child: card,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(
              'assets/f1_logo.svg',
              height: 24,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
          ],
        ),
      ],
    );
  }
}

class _InfoCard extends StatefulWidget {
  const _InfoCard({
    required this.title,
    required this.onTap,
    this.icon,
    required this.type, // <-- nuovo campo
  });

  final String title;
  final VoidCallback onTap;
  final IconData? icon;
  final String type; // "challenge", "bots", "local"

  @override
  State<_InfoCard> createState() => _InfoCardState();
}

class _InfoCardState extends State<_InfoCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 400;

    Widget iconWidget;
    if (widget.icon != null) {
      iconWidget = Icon(
        widget.icon,
        color: Colors.white,
        size: isSmall ? 32 : 36,
      );
    } else if (widget.title == 'Local Race') {
      iconWidget = SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_motorsports, size: 28, color: Colors.grey),
                const SizedBox(width: 8),
                Icon(Icons.sports_motorsports, size: 28, color: Colors.grey),
              ],
            ),
            Icon(Icons.sports_motorsports, size: 40, color: Colors.white),
          ],
        ),
      );
    } else if (widget.title == 'Race Bots') {
      iconWidget = SizedBox(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.robot, size: 25, color: Colors.grey),
                const SizedBox(width: 8),
                Icon(FontAwesomeIcons.robot, size: 25, color: Colors.grey),
              ],
            ),
            Icon(Icons.sports_motorsports, size: 40, color: Colors.white),
          ],
        ),
      );
    } else {
      iconWidget = Icon(
        Icons.help_outline,
        color: Colors.white,
        size: isSmall ? 32 : 36,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(90, 255, 6, 0),
              border: Border.all(color: const Color(0xFFFF0600)),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                iconWidget,
                const SizedBox(height: 12),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
