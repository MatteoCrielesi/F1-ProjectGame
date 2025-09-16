import 'package:flutter/material.dart';

class FerrariPage extends StatelessWidget {
  const FerrariPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreFerrari = Color(0xFFDC0000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Scuderia Ferrari',
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
              coloreFerrari.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreFerrari.withOpacity(0.7),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            double logoSize = screenWidth * 0.2;
            double carWidth = screenWidth * 0.9;
            double driverImgWidth = screenWidth * 0.25;
            final spacing = screenWidth * 0.05;

            if (logoSize > 120) logoSize = 120;
            if (driverImgWidth > 160) driverImgWidth = 160;

            final showAllDates = screenWidth > 600;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/ferrari.png',
                    width: logoSize,
                    height: logoSize,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Image.asset(
                    'assets/macchine/ferrari.png',
                    width: carWidth,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (screenWidth < 600)
                    Column(
                      children: [
                        _buildDriver('assets/piloti/leclerc.png', 'Charles Leclerc', driverImgWidth),
                        SizedBox(height: spacing),
                        _buildDriver('assets/piloti/hamilton.png', 'Lewis Hamilton', driverImgWidth),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDriver('assets/piloti/leclerc.png', 'Charles Leclerc', driverImgWidth),
                        SizedBox(width: spacing),
                        _buildDriver('assets/piloti/hamilton.png', 'Lewis Hamilton', driverImgWidth),
                      ],
                    ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1950', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('1960', style: TextStyle(color: Colors.white)),
                              Text('1970', style: TextStyle(color: Colors.white)),
                              Text('1980', style: TextStyle(color: Colors.white)),
                              Text('1990', style: TextStyle(color: Colors.white)),
                              Text('2000', style: TextStyle(color: Colors.white)),
                              Text('2010', style: TextStyle(color: Colors.white)),
                              Text('2020', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1950', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Solo logo, senza testo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    decoration: BoxDecoration(
                      color: coloreFerrari,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Image.asset(
                      'assets/logos/ferrari.png',
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 28),
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
        Text(
          name,
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }
}
