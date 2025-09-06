import 'dart:async';
import 'package:flutter/material.dart';
import 'scuderia.dart';

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
  Scuderia("Mercedes", "Dominante nell’era ibrida, sinonimo di precisione e innovazione tecnologica.", "assets/logos/mercedes.png"),
  Scuderia("Red Bull Racing", "Team campione con Verstappen, noto per la sua strategia aggressiva e sviluppo audace.", "assets/logos/redbull.png"),
  Scuderia("Haas", "Team americano con spirito combattivo e voglia di sorprendere.", "assets/logos/haas.png"),
  Scuderia("Racing Bulls", "Giovane scuderia con ambizioni e supporto Red Bull.", "assets/logos/racingbulls.png"),
  Scuderia("Kick Sauber", "Progetto svizzero con visione a lungo termine e design innovativo.", "assets/logos/kicksauber.png"),
  Scuderia("Williams", "Storico team britannico in cerca di nuova gloria.", "assets/logos/williams.png"),

  /*Scuderia("Alfa Romeo", "Storico marchio italiano, ha chiuso il suo capitolo in F1 dopo sei anni di collaborazione con Sauber.", "assets/logos/alfaromeo.png"),
  Scuderia("AlphaTauri", "Ex Toro Rosso, ha rappresentato il marchio moda Red Bull fino al rebranding come Racing Bulls.", "assets/logos/alphatauri.png"),*/
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

  /*"Alfa Romeo": const Color(0xFF720000),
  "AlphaTauri": const Color(0xFF1C1C3C),*/
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

  @override
  Widget build(BuildContext context) {
    final visibili = List.generate(3, (i) => scuderie[(index + i) % scuderie.length]);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.green],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
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
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AnimatedOpacity(
              opacity: showLoghi ? 1 : 0,
              duration: const Duration(seconds: 1),
              child: Row(
                key: ValueKey<int>(index),
                mainAxisAlignment: MainAxisAlignment.center,
                children: visibili.map((s) {
                  final colore = coloriScuderia[s.nome] ?? Colors.grey[800]!;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
                      width: 280,
                      height: 260,
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(s.logo, width: 60, height: 60),
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
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}