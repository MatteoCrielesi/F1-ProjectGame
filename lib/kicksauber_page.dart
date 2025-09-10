import 'package:flutter/material.dart';

class KickSauberPage extends StatelessWidget {
  const KickSauberPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreKickSauber = Color.fromARGB(255, 0, 255, 8);

    return Scaffold(
      backgroundColor: coloreKickSauber,
      appBar: AppBar(
        backgroundColor: coloreKickSauber,
        elevation: 0,
        title: const Text(
          'Kick Sauber F1 Team',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💚 Logo Kick Sauber
            Image.asset('assets/logos/kicksauber.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Kick Sauber
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/kicksauber.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Kick Sauber
            const Text(
              'Piloti',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/piloti/hulkenberg.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Nico Hulkenberg', style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/bortoleto.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Gabriel Bortoleto', style: TextStyle(color: Colors.black)),
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