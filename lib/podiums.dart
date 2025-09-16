import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'postgres_service.dart';

class PodiumsPage extends StatefulWidget {
  const PodiumsPage({super.key});

  @override
  State<PodiumsPage> createState() => _PodiumsPageState();
}

class _PodiumsPageState extends State<PodiumsPage> {
  late Future<List<Map<String, dynamic>>> _podiumsFuture;
  final PostgresService _dbService = PostgresService();

  @override
  void initState() {
    super.initState();
    _podiumsFuture = _loadPodiums();
  }

  Future<List<Map<String, dynamic>>> _loadPodiums() async {
    final results = await _dbService.getPodiumsTotals();
    return results;
  }

  @override
  void dispose() {
    _dbService.close();
    super.dispose();
  }

  Color _getColorForIndex(int index) {
    // Colori personalizzati per i primi piloti
    final colors = [
      Colors.purple,
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.blue,
      Colors.green,
    ];
    return colors[index % colors.length];
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
                        "Podiums",
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
                  // lista dei piloti con podi
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: _podiumsFuture,
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

                        final podiumData = snapshot.data!;
                        return ListView.builder(
                          itemCount: podiumData.length,
                          itemBuilder: (context, index) {
                            final item = podiumData[index];
                            final color = _getColorForIndex(index);

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
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item["pilota"] ?? "N/A",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Podi totali",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    (item["podi_totali"] ?? 0).toString(),
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
