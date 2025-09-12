import 'package:flutter/material.dart';

class MercedesPage extends StatelessWidget {
  const MercedesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline
    const Color coloreTyrrell   = Color(0xFF314462);
    const Color coloreBAR       = Color(0xFF878787);
    const Color coloreHonda     = Color(0xFFDB2423);
    const Color coloreBrawn     = Color(0xFFECECEC);
    const Color coloreMercedes  = Color(0xFF00D2BE);

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
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final barHeight = 40.0;
            final spacing = 8.0;
            final minBarWidth = 40.0; // larghezza minima per evitare tagli
            final h = barHeight * 5 + spacing * 4;
            final logoSize = w * 0.2 > 120 ? 120 : w * 0.2;
            final carWidth = w * 0.9;
            final driverImgWidth = w * 0.25 < 160 ? w * 0.25 : 160;
            final pilotiSpacing = w * 0.05;
            final showAllDates = w > 480;

            // Punti timeline dalla grafica
            final bars = [
              // Tyrrell: 1970-1998
              _timelineBar(
                left: w * 0.06,
                top: 0,
                width: w * 0.42 < minBarWidth ? minBarWidth : w * 0.42,
                color: coloreTyrrell,
                logoAsset: 'assets/logos/tyrrell.png',
                barHeight: barHeight,
              ),
              // BAR: 1999-2005
              _timelineBar(
                left: w * 0.35,
                top: barHeight + spacing,
                width: w * 0.34 < minBarWidth ? minBarWidth : w * 0.34,
                color: coloreBAR,
                logoAsset: 'assets/logos/bar.png',
                barHeight: barHeight,
              ),
              // Honda: 2006-2008
              _timelineBar(
                left: w * 0.54,
                top: (barHeight + spacing) * 2,
                width: w * 0.24 < minBarWidth ? minBarWidth : w * 0.24,
                color: coloreHonda,
                logoAsset: 'assets/logos/honda.png',
                barHeight: barHeight,
              ),
              // Brawn GP: 2009
              _timelineBar(
                left: w * 0.74,
                top: (barHeight + spacing) * 3,
                width: w * 0.18 < minBarWidth ? minBarWidth : w * 0.18,
                color: coloreBrawn,
                logoAsset: 'assets/logos/brawn.png',
                barHeight: barHeight,
              ),
              // Mercedes: 2010-2024
              _timelineBar(
                left: w * 0.82,
                top: (barHeight + spacing) * 4,
                width: w * 0.15 < minBarWidth ? minBarWidth : w * 0.15,
                color: coloreMercedes,
                logoAsset: 'assets/logos/mercedes.png',
                barHeight: barHeight,
              ),
            ];

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
                            SizedBox(height: pilotiSpacing),
                            _buildDriver('assets/piloti/antonelli.png', 'Andrea Kimi Antonelli', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/russell.png', 'George Russell', driverImgWidth),
                            SizedBox(width: pilotiSpacing),
                            _buildDriver('assets/piloti/antonelli.png', 'Andrea Kimi Antonelli', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),
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
                  Container(
                    width: w,
                    height: h,
                    child: Stack(children: bars),
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

  Widget _timelineBar({
    required double left,
    required double top,
    required double width,
    required Color color,
    required String logoAsset,
    required double barHeight,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: barHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(barHeight / 2),
        ),
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Image.asset(logoAsset, height: barHeight * 0.7, fit: BoxFit.contain),
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
