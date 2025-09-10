import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'scuderia.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard.dart';

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset('assets/f1_logo.svg', height: 24, color: const Color.fromARGB(255, 45, 123, 47)),
        const SizedBox(width: 12),
        Text(
          'Formula 1',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ],
    );
  }
}

class ScuderiePage extends StatefulWidget {
  const ScuderiePage({super.key});

  @override
  State<ScuderiePage> createState() => _ScuderiePageState();
}

class _ScuderiePageState extends State<ScuderiePage> {
  int index = 0;
  bool showLoghi = true;
  late Timer timer;

  final List<Scuderia> scuderie = [
    Scuderia("McLaren", "Storica rivale, oggi in risalita con giovani talenti e un progetto ambizioso.", "assets/logos/mclaren.png"),
    Scuderia("Aston Martin", "Team emergente con ambizioni crescenti, un mix di eleganza e performance.", "assets/logos/astonmartin.png"),
    Scuderia("Alpine", "Il progetto francese con Renault, in cerca di stabilità e crescita costante.", "assets/logos/alpine.png"),
    Scuderia("Ferrari", "La scuderia storica italiana con più titoli mondiali, simbolo di passione e velocità.", "assets/logos/ferrari.png"),
    Scuderia("Mercedes", "Dominante nell'era ibrida, sinonimo di precisione e innovazione tecnologica.", "assets/logos/mercedes.png"),
    Scuderia("Red Bull Racing", "Team campione con Verstappen, noto per la sua strategia aggressiva e sviluppo audace.", "assets/logos/redbull.png"),
    Scuderia("Haas", "Team americano con spirito combattivo e voglia di sorprendere.", "assets/logos/haas.png"),
    Scuderia("Racing Bulls", "Giovane scuderia con ambizioni e supporto Red Bull.", "assets/logos/racingbulls.png"),
    Scuderia("Kick Sauber", "Progetto svizzero con visione a lungo termine e design innovativo.", "assets/logos/kicksauber.png"),
    Scuderia("Williams", "Storico team britannico in cerca di nuova gloria.", "assets/logos/williams.png"),
  ];

  final Map<String, Color> coloriScuderia = {
    "McLaren": const Color(0xFFFF8700),
    "Aston Martin": const Color(0xFF006F62),
    "Alpine": const Color.fromARGB(255, 243, 34, 229),
    "Ferrari": const Color(0xFFDC0000),
    "Mercedes": const Color(0xFF00D2BE),
    "Red Bull Racing": const Color(0xFF1E41FF),
    "Haas": const Color(0xFFB6BABD),
    "Racing Bulls": const Color(0xFF00205B),
    "Kick Sauber": const Color.fromARGB(255, 0, 255, 8),
    "Williams": const Color(0xFF005AFF),
  };

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 6), (timer) async {
      setState(() => showLoghi = false);
      await Future.delayed(const Duration(milliseconds: 200));
      setState(() {
        index = (index + 1) % scuderie.length;
        showLoghi = true;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget _buildCard(Scuderia s, Color colore) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colore.withOpacity(0.85),
            colore.withOpacity(0.45),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colore.withOpacity(0.6),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(s.logo, width: 60, height: 60, fit: BoxFit.contain),
            const SizedBox(height: 12),
            Text(
              s.nome,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                s.descrizione,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int cardsPerPage = screenWidth < 500 ? 1 : screenWidth < 900 ? 2 : 3;
    final visibili = List.generate(cardsPerPage, (i) => scuderie[(index + i) % scuderie.length]);
    final int totalGroups = (scuderie.length / cardsPerPage).ceil();
    final int currentGroup = (index / cardsPerPage).floor();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Barra verde in alto
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(height: 3, color: const Color.fromARGB(255, 45, 123, 47)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 3), // Spazio per la barra verde
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black, Colors.green],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _Header(),
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
                                MaterialPageRoute(builder: (context) => const DashboardPage()),
                              );
                            },
                            child: const Icon(Icons.arrow_back),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "TEAMS",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Esplora tutte le scuderie, le formazioni e le livree della stagione attuale.",
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Expanded(
                      child: AnimatedOpacity(
                        opacity: showLoghi ? 1 : 0,
                        duration: const Duration(milliseconds: 700),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            key: ValueKey<int>(index),
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    index = (index - cardsPerPage + scuderie.length) % scuderie.length;
                                  });
                                },
                              ),
                              ...visibili.map((s) {
                                final colore = coloriScuderia[s.nome] ?? Colors.grey[800]!;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: SizedBox(
                                    width: 260,
                                    height: 260,
                                    child: _buildCard(s, colore),
                                  ),
                                );
                              }).toList(),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                                onPressed: () {
                                  setState(() {
                                    index = (index + cardsPerPage) % scuderie.length;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}