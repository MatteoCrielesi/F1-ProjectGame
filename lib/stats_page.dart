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
  final String descrizione;
  final IconData icona;
  final Color colore;
  final bool glow;
  final bool sweep;
  final bool fireworks;

  Statistica(
    this.titolo,
    this.descrizione,
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
    Statistica("Pole Positions", "Pole position conquistate.", Icons.flag, Colors.blue, glow: true),
    Statistica("Giri Veloci", "Chi ha fatto il giro più veloce.", Icons.speed, Colors.orange, sweep: true),
    Statistica("Podiums", "Quanti podi ha ottenuto ciascun pilota.", Icons.emoji_events, Colors.amber, fireworks: true),
    Statistica("Pit Stops", "Numero e velocità dei pit stop.", Icons.build, Colors.green),
    Statistica("DNF", "Numero di ritiri nella stagione.", Icons.error_outline, Colors.red),
    Statistica("Record Tracks", "Record dei giri su ciascun circuito.", Icons.track_changes, Colors.purpleAccent, glow: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // sfondo gradient
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
                  // header con logo e back
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
                  // griglia responsive
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = constraints.maxWidth < 500
                            ? 1
                            : constraints.maxWidth < 900
                                ? 2
                                : 3;
                        double aspectRatio = crossAxisCount == 1 ? 2.5 : 1.2;

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
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
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

  void _onTap(BuildContext context) {
    switch (widget.s.titolo) {
      case "Pole Positions":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PolePositionPage()));
        break;
      case "Giri Veloci":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FastestLapPage()));
        break;
      case "Podiums":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PodiumsPage()));
        break;
      case "Pit Stops":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const PitStopsPage()));
        break;
      case "DNF":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DNFPage()));
        break;
      case "Record Tracks":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RecordTracksPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: () => _onTap(context),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
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
              Icon(widget.s.icona, size: 40, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                widget.s.titolo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.s.descrizione,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
