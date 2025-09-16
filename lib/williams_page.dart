import 'package:flutter/material.dart';

class WilliamsPage extends StatelessWidget {
  const WilliamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreWilliams = Color(0xFF005AFF);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Williams Racing',
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
              coloreWilliams.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreWilliams.withOpacity(0.7),
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

            bool showAllDates = screenWidth > 600;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/williams.png', width: logoSize, height: logoSize),
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
                  Image.asset('assets/macchine/williams.png', width: carWidth, fit: BoxFit.contain),
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
                            _buildDriver('assets/piloti/albon.png', 'Alex Albon', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/sainz.png', 'Carlos Sainz', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/albon.png', 'Alex Albon', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/sainz.png', 'Carlos Sainz', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1977', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('1980', style: TextStyle(color: Colors.white)),
                              Text('1990', style: TextStyle(color: Colors.white)),
                              Text('2000', style: TextStyle(color: Colors.white)),
                              Text('2010', style: TextStyle(color: Colors.white)),
                              Text('2020', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1977', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Timeline barra unica con logo
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    height: 48,
                    decoration: BoxDecoration(
                      color: coloreWilliams,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/logos/williams.png',
                          height: 36,
                          color: Colors.white,
                          fit: BoxFit.contain,
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
