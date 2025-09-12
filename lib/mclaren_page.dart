import 'package:flutter/material.dart';

class McLarenPage extends StatelessWidget {
  const McLarenPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreMcLaren = Color(0xFFFF8700);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'McLaren F1 Team',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              coloreMcLaren.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreMcLaren.withOpacity(0.7),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double logoSize = screenWidth * 0.2;
            double carWidth = screenWidth * 0.9;
            double driverImgWidth = screenWidth * 0.25;
            double spacing = screenWidth * 0.05;
            if (logoSize > 120) logoSize = 120;
            if (driverImgWidth > 160) driverImgWidth = 160;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/mclaren.png', width: logoSize, height: logoSize, color: coloreMcLaren),

                  const SizedBox(height: 24),

                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  Image.asset('assets/macchine/mclaren.png', width: carWidth, fit: BoxFit.contain),

                  const SizedBox(height: 32),

                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/norris.png', 'Lando Norris', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/piastri.png', 'Oscar Piastri', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/norris.png', 'Lando Norris', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/piastri.png', 'Oscar Piastri', driverImgWidth),
                          ],
                        ),

                  const SizedBox(height: 40),

                  // --- TIMELINE McLAREN ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('1950', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('1960', style: TextStyle(color: Colors.white)),
                        Text('1970', style: TextStyle(color: Colors.white)),
                        Text('1980', style: TextStyle(color: Colors.white)),
                        Text('1990', style: TextStyle(color: Colors.white)),
                        Text('2000', style: TextStyle(color: Colors.white)),
                        Text('2010', style: TextStyle(color: Colors.white)),
                        Text('2020', style: TextStyle(color: Colors.white)),
                        Text('2024', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Container(
                      height: 40,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: coloreMcLaren,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Image.asset('assets/logos/mclaren.png', height: 30, color: Colors.white),
                          const SizedBox(width: 14),
                          const Text(
                            'McLaren',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDriver(String image, String name, double width) {
    return Column(
      children: [
        Image.asset(image, width: width),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
