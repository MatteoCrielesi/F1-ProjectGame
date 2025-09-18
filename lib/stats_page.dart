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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double horizontalPadding = screenWidth < 500 ? 12 : 16;
    double verticalPadding = screenHeight < 700 ? 8 : 12;

    return Scaffold(
      body: Stack(
        children: [
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
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header con logo e back
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        'assets/f1_logo.svg',
                        height: screenHeight * 0.03,
                        color: Colors.pinkAccent,
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "Formula 1",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: screenWidth < 500 ? 20 : 26,
                            ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
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
                  SizedBox(height: screenHeight * 0.02),
                  // Griglia responsive
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = screenWidth < 500
                            ? 1
                            : screenWidth < 900
                                ? 2
                                : 3;

                        double aspectRatio;
                        if (crossAxisCount == 1) {
                          aspectRatio = screenWidth / (screenHeight * 0.25);
                        } else if (crossAxisCount == 2) {
                          aspectRatio = screenWidth / (screenHeight * 0.35);
                        } else {
                          aspectRatio = screenWidth / (screenHeight * 0.45);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Dimensioni responsive
    double iconSize = screenWidth < 500 ? 36 : 40;
    double titleFontSize = screenWidth < 500 ? 16 : 18;
    double descriptionFontSize = screenWidth < 500 ? 12 : 14;
    double cardPadding = screenWidth < 500 ? 12 : 16;

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
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.s.icona, size: iconSize, color: Colors.white),
              SizedBox(height: cardPadding * 0.75),
              Text(
                widget.s.titolo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: cardPadding * 0.5),
              Text(
                widget.s.descrizione,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: descriptionFontSize, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
