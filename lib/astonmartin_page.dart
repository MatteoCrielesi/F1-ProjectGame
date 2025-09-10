import 'package:flutter/material.dart';

class AstonMartinPage extends StatelessWidget {
  const AstonMartinPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreAstonMartin = Color(0xFF006F62);

    return Scaffold(
      backgroundColor: coloreAstonMartin,
      appBar: AppBar(
        backgroundColor: coloreAstonMartin,
        elevation: 0,
        title: const Text(
          'Aston Martin Aramco F1 Team',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💚 Logo Aston Martin
            Image.asset('assets/logos/astonmartin.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Aston Martin
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/astonmartin.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Aston Martin
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
                    Image.asset('assets/piloti/alonso.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Fernando Alonso', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/stroll.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Lance Stroll', style: TextStyle(color: Colors.white)),
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