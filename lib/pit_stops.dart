import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PitStopsPage extends StatelessWidget {
  const PitStopsPage({super.key});

  // Lista hardcoded dei pit stops
  final List<Map<String, dynamic>> pitData = const [
    {"pilota": "Ferrari", "numero": 444},
    {"pilota": "McLaren", "numero": 256},
    {"pilota": "Red Bull Racing", "numero": 215}, // nome corretto come in ScuderiePage
    {"pilota": "Racing Bulls", "numero": 203},
    {"pilota": "Mercedes", "numero": 167},
    {"pilota": "Kick Sauber", "numero": 155}, // uniformato
    {"pilota": "Alpine", "numero": 94},
    {"pilota": "Aston Martin", "numero": 36},
    {"pilota": "Williams", "numero": 24},
    {"pilota": "Haas", "numero": 22},
  ];

  // Mappa scuderia → logo
  String _getLogoPath(String team) {
    final logos = {
      "Ferrari": "assets/logos/ferrari.png",
      "McLaren": "assets/logos/mclaren.png",
      "Red Bull Racing": "assets/logos/redbull.png",
      "Racing Bulls": "assets/logos/racingbulls.png",
      "Mercedes": "assets/logos/mercedes.png",
      "Kick Sauber": "assets/logos/kicksauber.png",
      "Alpine": "assets/logos/alpine.png",
      "Aston Martin": "assets/logos/astonmartin.png",
      "Williams": "assets/logos/williams.png",
      "Haas": "assets/logos/haas.png",
    };

    return logos[team] ?? "assets/f1_logo.svg"; // fallback
  }

  // Mappa scuderia → colore ufficiale
  Color _getTeamColor(String team) {
    final coloriScuderia = {
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

    return coloriScuderia[team] ?? Colors.grey;
  }

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
                  // header con logo e pulsante back
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
                        "Pit Stop Championship",
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(12),
                          minimumSize: const Size(40, 40),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // lista dei pit stop
                  Expanded(
                    child: ListView.builder(
                      itemCount: pitData.length,
                      itemBuilder: (context, index) {
                        final item = pitData[index];
                        final colore = _getTeamColor(item["pilota"]);

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colore.withOpacity(0.9),
                                colore.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: colore.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // logo della scuderia
                              Image.asset(
                                _getLogoPath(item["pilota"]),
                                width: 50,
                                height: 50,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  item["pilota"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Text(
                                item["numero"].toString(),
                                style: const TextStyle(
                                  fontSize: 24,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
