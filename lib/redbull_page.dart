import 'package:flutter/material.dart';

class RedBullPage extends StatelessWidget {
  const RedBullPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreRedBull = Color(0xFF1E41FF);

    return Scaffold(
      backgroundColor: coloreRedBull,
      appBar: AppBar(
        backgroundColor: coloreRedBull,
        elevation: 0,
        title: const Text('Red Bull Racing', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔵 Logo Red Bull
            Image.asset('assets/logos/redbull.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina Red Bull
            const Text('Vettura 2025', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/redbull.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti Red Bull
            const Text('Piloti', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Image.asset('assets/piloti/verstappen.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Max Verstappen', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/tsunoda.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Yuki Tsunoda', style: TextStyle(color: Colors.white)),
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