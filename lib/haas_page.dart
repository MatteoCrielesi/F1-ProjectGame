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
                  Image.asset('assets/logos/haas.png', width: logoSize, height: logoSize),

                  const SizedBox(height: 24),

                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),

                  Image.asset('assets/macchine/haas.png', width: carWidth, fit: BoxFit.contain),

                  const SizedBox(height: 32),

                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

                  // --- TIMELINE HAAS ---
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('2016', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('2024', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildTimelineBar(
                    coloreHaas,
                    'Haas F1 Team',
                    'assets/logos/haas.png',
                    left: 0.0,
                    widthFactor: 1.0,
                  ),
                  const SizedBox(height: 24),
                  // --- fine timeline ---
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimelineBar(Color color, String name, String logoAsset, {required double left, required double widthFactor}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double totalWidth = constraints.maxWidth;
        return Container(
          width: totalWidth,
          height: 40,
          child: Stack(
            children: [
              Positioned(
                left: totalWidth * left,
                child: Container(
                  height: 40,
                  width: totalWidth * widthFactor,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      Image.asset(logoAsset, height: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'Haas F1 Team',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
