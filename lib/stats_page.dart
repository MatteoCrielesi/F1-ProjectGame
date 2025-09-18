import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'pole_position.dart';
import 'fast_laps.dart';
import 'podiums.dart';
import 'dashboard.dart';
import 'pit_stops.dart';
import 'dnf.dart';
import 'record_tracks.dart';

class Statistica {
  final String titolo;
  final IconData icona;
  final Color colore;
  final bool glow;
  final bool sweep;
  final bool fireworks;

  Statistica(
    this.titolo,
    this.icona,
    this.colore, {
    this.glow = false,
    this.sweep = false,
    this.fireworks = false,
  });
}

class StatistichePage extends StatelessWidget {
  StatistichePage({super.key});

  final List<Statistica> stats = [
    Statistica("Pole Positions", Icons.flag, Colors.blue, glow: true),
    Statistica("Giri Veloci", Icons.speed, Colors.orange, sweep: true),
    Statistica("Podiums", Icons.emoji_events, Colors.amber, fireworks: true),
    Statistica("Pit Stops", Icons.build, Colors.green),
    Statistica("DNF", Icons.error_outline, Colors.red),
    Statistica("Track Records", Icons.track_changes, Colors.purpleAccent, glow: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Sfondo gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.pinkAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con logo e back
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/f1_logo.svg',
                        height: 24,
                        color: Colors.pinkAccent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Formula 1",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white10,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(40, 40),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const DashboardPage()),
                          );
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Griglia responsive
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount;
                        double aspectRatio;

                        if (constraints.maxWidth < 350) {
                          crossAxisCount = 1;
                          aspectRatio = 2.8;
                        } else if (constraints.maxWidth < 500) {
                          crossAxisCount = 1;
                          aspectRatio = 2.5;
                        } else if (constraints.maxWidth < 900) {
                          crossAxisCount = 2;
                          aspectRatio = 1.2;
                        } else {
                          crossAxisCount = 3;
                          aspectRatio = 1.2;
                        }

                        return GridView.builder(
                          itemCount: stats.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (context, i) => AnimatedCard(s: stats[i]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  final Statistica s;
  const AnimatedCard({super.key, required this.s});

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _scale = Tween(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _controller.forward();
  void _onTapUp(_) => _controller.reverse();
  void _onTapCancel() => _controller.reverse();

  void _onTap(BuildContext context) {
    final Map<String, Widget> pages = {
      "Pole Positions": const PolePositionPage(),
      "Giri Veloci": const FastestLapPage(),
      "Podiums": const PodiumsPage(),
      "Pit Stops": const PitStopsPage(),
      "DNF": const DNFPage(),
      "Track Records": const RecordTracksPage(),
    };
    final page = pages[widget.s.titolo];
    if (page != null) Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: () => _onTap(context),
      child: ScaleTransition(
        scale: _scale,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dimensioni dinamiche per testo e icone
            double iconSize = constraints.maxWidth * 0.25;
            double fontSize = constraints.maxWidth * 0.12;
            fontSize = fontSize.clamp(14, 20);
            iconSize = iconSize.clamp(24, 48);

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.s.colore.withOpacity(0.85),
                    widget.s.colore.withOpacity(0.45),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  if (widget.s.glow)
                    BoxShadow(
                      color: widget.s.colore.withOpacity(0.6),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                ],
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.s.icona, size: iconSize, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    widget.s.titolo,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
