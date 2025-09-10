import 'package:flutter/material.dart';

class FerrariPage extends StatelessWidget {
  const FerrariPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreFerrari = Color(0xFFDC0000);

    return Scaffold(
      backgroundColor: coloreFerrari,
      appBar: AppBar(
        backgroundColor: coloreFerrari,
        elevation: 0,
        title: const Text(
          'Scuderia Ferrari',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔴 Logo Ferrari
            Image.asset('assets/logos/ferrari.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Ferrari
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/ferrari.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Ferrari
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
                    Image.asset('assets/piloti/leclerc.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Charles Leclerc', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/hamilton.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Lewis Hamilton', style: TextStyle(color: Colors.white)),
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