import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PitStopsPage extends StatelessWidget {
  const PitStopsPage({super.key});

  // Lista hardcoded dei pit stops
  final List<Map<String, dynamic>> pitData = const [
    {"pilota": "Ferrari", "numero": 444},
    {"pilota": "McLaren", "numero": 256},
    {"pilota": "Red Bull", "numero": 215},
    {"pilota": "Racing Bulls", "numero": 203},
    {"pilota": "Mercedes", "numero": 167},
    {"pilota": "Sauber", "numero": 155},
    {"pilota": "Alpine", "numero": 94},
    {"pilota": "Aston Martin", "numero": 36},
    {"pilota": "Williams", "numero": 24},
    {"pilota": "Haas", "numero": 22},
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
                        final color = Colors.primaries[index % Colors.primaries.length];

                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.9),
                                color.withOpacity(0.5),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: color.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.car_repair,
                                color: Colors.white,
                                size: 40,
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
