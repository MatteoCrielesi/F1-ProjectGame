import 'package:flutter/material.dart';

class AlpinePage extends StatelessWidget {
  const AlpinePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline
    const Color coloreToleman = Color(0xFFBBD5F5);
    const Color coloreBenetton = Color(0xFF009A44);
    const Color coloreRenault = Color(0xFFFFC800);
    const Color coloreLotus = Color(0xFF231F20);
    const Color coloreAlpine = Color.fromARGB(255, 243, 34, 229);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'BWT Alpine F1 Team',
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
              coloreAlpine.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreAlpine.withOpacity(0.7),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
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

            bool showAllDates = screenWidth > 400;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/alpine.png', width: logoSize, height: logoSize),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Image.asset('assets/macchine/alpine.png', width: carWidth, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/gasly.png', 'Pierre Gasly', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/colapinto.png', 'Franco Colapinto', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/gasly.png', 'Pierre Gasly', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/colapinto.png', 'Franco Colapinto', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1981', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('1990', style: TextStyle(color: Colors.white)),
                              Text('2000', style: TextStyle(color: Colors.white)),
                              Text('2010', style: TextStyle(color: Colors.white)),
                              Text('2020', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1981', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;
                      double h = 250; // Aumentata da 120 a 160
                      return Container(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned(
                              left: w * 0.00,
                              top: 0,
                              child: _logoTimelineBar(w * 0.13, coloreToleman, 'assets/logos/toleman.png'),
                            ),
                            Positioned(
                              left: w * 0.13,
                              top: h * 0.21,
                              child: _logoTimelineBar(w * 0.20, coloreBenetton, 'assets/logos/benetton.png'),
                            ),
                            Positioned(
                              left: w * 0.33,
                              top: h * 0.42,
                              child: _logoTimelineBar(w * 0.18, coloreRenault, 'assets/logos/renault.png'),
                            ),
                            Positioned(
                              left: w * 0.51,
                              top: h * 0.63,
                              child: _logoTimelineBar(w * 0.11, coloreLotus, 'assets/logos/lotus.png'),
                            ),
                            Positioned(
                              left: w * 0.63,
                              top: h * 0.76,
                              child: _logoTimelineBar(w * 0.09, coloreRenault, 'assets/logos/renault.png'),
                            ),
                            Positioned(
                              left: w * 0.72,
                              top: h * 0.85, // Ridotto da 0.89 a 0.85
                              child: _logoTimelineBar(
                                (w * 0.27) < 40 ? 40 : (w * 0.27),
                                coloreAlpine,
                                'assets/logos/alpine.png',
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

  Widget _logoTimelineBar(double width, Color color, String logoAsset) {
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
        child: Image.asset(logoAsset, height: 22, fit: BoxFit.contain),
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