import 'package:flutter/material.dart';

class MercedesPage extends StatelessWidget {
  const MercedesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline
    const Color coloreTyrrell = Color(0xFF314462);
    const Color coloreBAR = Color(0xFF878787);
    const Color coloreHonda = Color(0xFFDB2423);
    const Color coloreBrawn = Color(0xFFECECEC);
    const Color coloreMercedes = Color(0xFF00D2BE);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mercedes-AMG Petronas',
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
              coloreMercedes.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreMercedes.withOpacity(0.7),
            ],
            stops: const [0.0, 0.1, 0.9, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double w = constraints.maxWidth;
            double logoSize = w * 0.2;
            double carWidth = w * 0.9;
            double driverImgWidth = w * 0.25;
            double spacing = w * 0.05;
            if (logoSize > 120) logoSize = 120;
            if (driverImgWidth > 160) driverImgWidth = 160;

            bool showAllDates = w > 400;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/mercedes.png', width: logoSize, height: logoSize),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Image.asset('assets/macchine/mercedes.png', width: carWidth, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  w < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/russell.png', 'George Russell', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/antonelli.png', 'Andrea Kimi Antonelli', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/russell.png', 'George Russell', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/antonelli.png', 'Andrea Kimi Antonelli', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  // Date timeline
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1970', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('1997', style: TextStyle(color: Colors.white)),
                              Text('2005', style: TextStyle(color: Colors.white)),
                              Text('2008', style: TextStyle(color: Colors.white)),
                              Text('2009', style: TextStyle(color: Colors.white)),
                              Text('2010', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1970', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TIMELINE stile Alpine
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;
                      double h = 250;
                      return Container(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned(
                              left: w * 0.00,
                              top: 0,
                              child: _logoTimelineBar(w * 0.20, coloreTyrrell, 'assets/logos/tyrrell.png'),
                            ),
                            Positioned(
                              left: w * 0.20,
                              top: h * 0.22,
                              child: _logoTimelineBar(w * 0.18, coloreBAR, 'assets/logos/bar.png'),
                            ),
                            Positioned(
                              left: w * 0.38,
                              top: h * 0.44,
                              child: _logoTimelineBar(w * 0.16, coloreHonda, 'assets/logos/honda.png'),
                            ),
                            Positioned(
                              left: w * 0.54,
                              top: h * 0.66,
                              child: _logoTimelineBar(w * 0.12, coloreBrawn, 'assets/logos/brawn.png'),
                            ),
                            Positioned(
                              left: w * 0.66,
                              top: h * 0.80,
                              child: _logoTimelineBar(
                                (w * 0.30) < 40 ? 40 : (w * 0.30),
                                coloreMercedes,
                                'assets/logos/mercedes.png',
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
