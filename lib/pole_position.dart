import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'postgres_service.dart'; // importa il tuo servizio

class PolePositionPage extends StatelessWidget {
  const PolePositionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final db = PostgresService();

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
                        "Pole Positions",
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

                  // lista dei piloti da DB
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: db.getPolePositions(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: Colors.pinkAccent),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              "Errore: ${snapshot.error}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text(
                              "Nessun dato disponibile",
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        final poleData = snapshot.data!;
                        return ListView.builder(
                          itemCount: poleData.length,
                          itemBuilder: (context, index) {
                            final item = poleData[index];
                            final color = Colors.primaries[index % Colors.primaries.length];

                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withOpacity(0.8),
                                    color.withOpacity(0.4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: const Icon(
                                  Icons.flag,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                title: Text(
                                  item["pilota"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: const Text(
                                  "Pole Position totali",
                                  style: TextStyle(color: Colors.white70),
                                ),
                                trailing: Text(
                                  item["numero"].toString(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
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
