import 'package:flutter/material.dart';

class AstonMartinPage extends StatelessWidget {
  const AstonMartinPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline soggetti a personalizzazione in base alla storia Aston
    const Color coloreJordan      = Color(0xFFF8E71C);   // giallo Jordan
    const Color coloreMidland     = Color(0xFF757575);   // grigio Midland
    const Color coloreSpyker      = Color(0xFFE66153);   // arancio Spyker
    const Color coloreForceIndia  = Color(0xFF48C0B0);   // verde acqua Force India
    const Color coloreRacingPoint = Color(0xFFE9B8E1);   // rosa Racing Point
    const Color coloreAstonMartin = Color(0xFF006F62);   // verde Aston Martin

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Aston Martin Aramco F1 Team',
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
              coloreAstonMartin.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreAstonMartin.withOpacity(0.7),
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

            bool showAllDates = screenWidth > 480;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/astonmartin.png', width: logoSize, height: logoSize),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Image.asset('assets/macchine/astonmartin.png', width: carWidth, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/alonso.png', 'Fernando Alonso', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/stroll.png', 'Lance Stroll', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/alonso.png', 'Fernando Alonso', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/stroll.png', 'Lance Stroll', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1991', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2005', style: TextStyle(color: Colors.white)),
                              Text('2007', style: TextStyle(color: Colors.white)),
                              Text('2008', style: TextStyle(color: Colors.white)),
                              Text('2018', style: TextStyle(color: Colors.white)),
                              Text('2020', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1991', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // TIMELINE MULTIRIGA ORDINATA (riferimento: Alpine)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;
                      double h = 250; // aumenta per evitare sovrapposizione logos
                      return Container(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            // Jordan (1991–2005)
                            Positioned(
                              left: w * 0.01,
                              top: h * 0.00,
                              child: _logoTimelineBar(w * 0.31, coloreJordan, 'assets/logos/jordan.png'),
                            ),
                            // Midland (2006)
                            Positioned(
                              left: w * 0.32,
                              top: h * 0.18,
                              child: _logoTimelineBar(w * 0.05, coloreMidland, 'assets/logos/midland.png'),
                            ),
                            // Spyker (2007)
                            Positioned(
                              left: w * 0.37,
                              top: h * 0.33,
                              child: _logoTimelineBar(w * 0.05, coloreSpyker, 'assets/logos/spyker.png'),
                            ),
                            // Force India (2008–2018)
                            Positioned(
                              left: w * 0.42,
                              top: h * 0.48,
                              child: _logoTimelineBar(w * 0.25, coloreForceIndia, 'assets/logos/forceindia.png'),
                            ),
                            // Racing Point (2019–2020)
                            Positioned(
                              left: w * 0.67,
                              top: h * 0.68,
                              child: _logoTimelineBar(w * 0.08, coloreRacingPoint, 'assets/logos/racingpoint.png'),
                            ),
                            // Aston Martin (2021–2024)
                            Positioned(
                              left: w * 0.75,
                              top: h * 0.85,
                              child: _logoTimelineBar(w * 0.22, coloreAstonMartin, 'assets/logos/astonmartin.png'),
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
