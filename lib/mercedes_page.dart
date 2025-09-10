import 'package:flutter/material.dart';

class MercedesPage extends StatelessWidget {
  const MercedesPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreMercedes = Color(0xFF00D2BE);

    return Scaffold(
      backgroundColor: coloreMercedes,
      appBar: AppBar(
        backgroundColor: coloreMercedes,
        elevation: 0,
        title: const Text(
          'Mercedes-AMG Petronas',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟦 Logo Mercedes
            Image.asset('assets/logos/mercedes.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Mercedes
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/mercedes.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Mercedes
            const Text(
              'Piloti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/piloti/russell.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('George Russel', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/antonelli.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Andrea Kimi Antonelli', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}