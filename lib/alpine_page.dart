import 'package:flutter/material.dart';

class AlpinePage extends StatelessWidget {
  const AlpinePage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreAlpine = Color.fromARGB(255, 243, 34, 229);

    return Scaffold(
      backgroundColor: coloreAlpine,
      appBar: AppBar(
        backgroundColor: coloreAlpine,
        elevation: 0,
        title: const Text(
          'BWT Alpine F1 Team',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💜 Logo Alpine
            Image.asset('assets/logos/alpine.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Alpine
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/alpine.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Alpine
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
                    Image.asset('assets/piloti/gasly.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Pierre Gasly', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/colapinto.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Franco Colapinto', style: TextStyle(color: Colors.white)),
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