import 'package:flutter/material.dart';

class HaasPage extends StatelessWidget {
  const HaasPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreHaas = Color(0xFFB6BABD);

    return Scaffold(
      backgroundColor: coloreHaas,
      appBar: AppBar(
        backgroundColor: coloreHaas,
        elevation: 0,
        title: const Text(
          'Haas F1 Team',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ⚪🔴 Logo Haas
            Image.asset('assets/logos/haas.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Haas
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/haas.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Haas
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
                    Image.asset('assets/piloti/ocon.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Esteban Ocon', style: TextStyle(color: Colors.black)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/bearman.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Oliver Bearman', style: TextStyle(color: Colors.black)),
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