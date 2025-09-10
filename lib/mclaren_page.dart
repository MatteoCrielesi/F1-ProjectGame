import 'package:flutter/material.dart';

class McLarenPage extends StatelessWidget {
  const McLarenPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreMcLaren = Color(0xFFFF8700);

    return Scaffold(
      backgroundColor: coloreMcLaren,
      appBar: AppBar(
        backgroundColor: coloreMcLaren,
        elevation: 0,
        title: const Text(
          'McLaren F1 Team',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🧡 Logo McLaren
            Image.asset('assets/logos/mclaren.png', width: 100, height: 100),

            const SizedBox(height: 24),

            // 🏎️ Macchina McLaren
            const Text(
              'Vettura 2025',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Image.asset('assets/macchine/mclaren.png', width: double.infinity),

            const SizedBox(height: 32),

            // 🧑‍✈️ Piloti McLaren
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
                    Image.asset('assets/piloti/norris.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Lando Norris', style: TextStyle(color: Colors.white)),
                  ],
                ),
                const SizedBox(width: 24),
                Column(
                  children: [
                    Image.asset('assets/piloti/piastri.png', width: 120),
                    const SizedBox(height: 8),
                    const Text('Oscar Piastri', style: TextStyle(color: Colors.white)),
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