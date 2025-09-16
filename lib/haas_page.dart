import 'package:flutter/material.dart';

class HaasPage extends StatelessWidget {
  const HaasPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreHaas = Color(0xFFB6BABD);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Haas F1 Team',
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
              coloreHaas.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreHaas.withOpacity(0.7),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double screenWidth = constraints.maxWidth;
            double logoSize = screenWidth * 0.2 > 120 ? 120 : screenWidth * 0.2;
            double driverImgWidth = screenWidth * 0.25 > 160 ? 160 : screenWidth * 0.25;
            double spacing = screenWidth * 0.05;
            bool showAllDates = screenWidth > 500;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/haas.png', width: logoSize, height: logoSize),
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
                  Image.asset('assets/macchine/haas.png', width: screenWidth * 0.9, fit: BoxFit.contain),
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
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/ocon.png', 'Esteban Ocon', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/bearman.png', 'Oliver Bearman', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/ocon.png', 'Esteban Ocon', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/bearman.png', 'Oliver Bearman', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('2016', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2017', style: TextStyle(color: Colors.white)),
                              Text('2018', style: TextStyle(color: Colors.white)),
                              Text('2019', style: TextStyle(color: Colors.white)),
                              Text('2020', style: TextStyle(color: Colors.white)),
                              Text('2021', style: TextStyle(color: Colors.white)),
                              Text('2022', style: TextStyle(color: Colors.white)),
                              Text('2023', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('2016', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    decoration: BoxDecoration(
                      color: coloreHaas,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/logos/haas.png',
                          height: 36,
                          fit: BoxFit.contain,
                          color: Colors.white,
                        ),
                      ],
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
        Text(name, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}
