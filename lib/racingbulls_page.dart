import 'package:flutter/material.dart';

class RacingBullsPage extends StatelessWidget {
  const RacingBullsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreRacingBulls = Color(0xFF00205B);

    return Scaffold(
      backgroundColor: coloreRacingBulls,
      appBar: AppBar(
        backgroundColor: coloreRacingBulls,
        elevation: 0,
        title: const Text(
          'Visa Cash App Racing Bulls',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 💙 Logo Racing Bulls
            Image.asset('assets/logos/racing bulls.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Racing Bulls
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/racing bulls.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Racing Bulls
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
                    Image.asset('assets/piloti/hadjer.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Isack Hadjar', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/lawson.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Liam Lawson', style: TextStyle(color: Colors.white)),
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