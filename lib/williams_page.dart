import 'package:flutter/material.dart';

class WilliamsPage extends StatelessWidget {
  const WilliamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreWilliams = Color(0xFF005AFF);

    return Scaffold(
      backgroundColor: coloreWilliams,
      appBar: AppBar(
        backgroundColor: coloreWilliams,
        elevation: 0,
        title: const Text(
          'Williams Racing',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🟦 Logo Williams
            Image.asset('assets/logos/williams.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Williams
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/williams.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Williams
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
                    Image.asset('assets/piloti/albon.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Alex Albon', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/sainz.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Carlos Sainz', style: TextStyle(color: Colors.white)),
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