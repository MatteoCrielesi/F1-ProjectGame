import 'package:flutter/material.dart';

class KickSauberPage extends StatelessWidget {
  const KickSauberPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline storica Kick Sauber (Sauber → BMW Sauber → Sauber → Alfa Romeo → Kick Sauber)
    const Color coloreSauber      = Color(0xFFD5D7DE); // Grigio Sauber
    const Color coloreBMW         = Color(0xFF003263); // Blu BMW Sauber
    const Color coloreAlfaRomeo   = Color(0xFF991F28); // Rosso Alfa Romeo
    const Color coloreKickSauber  = Color.fromARGB(255, 0, 255, 8); // Verde Kick

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Kick Sauber F1 Team',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              coloreKickSauber.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreKickSauber.withOpacity(0.7),
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

            bool showAllDates = screenWidth > 420;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/logos/kicksauber.png',
                    width: logoSize,
                    height: logoSize,
                    color: coloreKickSauber,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Image.asset('assets/macchine/kicksauber.png', width: carWidth, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/hulkenberg.png', 'Nico Hulkenberg', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/bortoleto.png', 'Gabriel Bortoleto', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/hulkenberg.png', 'Nico Hulkenberg', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/bortoleto.png', 'Gabriel Bortoleto', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  // Date responsive
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1993', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2006', style: TextStyle(color: Colors.white)),
                              Text('2010', style: TextStyle(color: Colors.white)),
                              Text('2018', style: TextStyle(color: Colors.white)),
                              Text('2022', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1993', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;
                      double h = 300;
                      return Container(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned(
                              left: w * 0.00,
                              top: 0,
                              child: _logoTimelineBar(
                                width: w * 0.28 < 40 ? 40 : w * 0.28,
                                color: coloreSauber,
                                logoAsset: 'assets/logos/sauber.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.28,
                              top: h * 0.28,
                              child: _logoTimelineBar(
                                width: w * 0.15 < 40 ? 40 : w * 0.15,
                                color: coloreBMW,
                                logoAsset: 'assets/logos/bmw.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.43,
                              top: h * 0.52,
                              child: _logoTimelineBar(
                                width: w * 0.22 < 40 ? 40 : w * 0.22,
                                color: coloreSauber,
                                logoAsset: 'assets/logos/sauber.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.65,
                              top: h * 0.74,
                              child: _logoTimelineBar(
                                width: w * 0.16 < 40 ? 40 : w * 0.16,
                                color: coloreAlfaRomeo,
                                logoAsset: 'assets/logos/alfaromeo.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.81,
                              top: h * 0.89,
                              child: _logoTimelineBar(
                                width: w * 0.19 < 40 ? 40 : w * 0.19,
                                color: coloreKickSauber,
                                logoAsset: 'assets/logos/kicksauber.png',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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

  Widget _logoTimelineBar({
    required double width,
    required Color color,
    required String logoAsset,
  }) {
    return Container(
      width: width < 40 ? 40 : width,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Image.asset(
          logoAsset,
          height: 22,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              Icon(Icons.image_not_supported, color: Colors.white),
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
