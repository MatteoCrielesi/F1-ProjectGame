import 'package:flutter/material.dart';

class RacingBullsPage extends StatelessWidget {
  const RacingBullsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colori timeline
    const Color coloreMinardi     = Color(0xFF191919);
    const Color coloreToroRosso   = Color(0xFF003399);
    const Color coloreAlphaTauri  = Color(0xFF242944);
    const Color coloreRacingBulls = Color(0xFF00205B);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Visa Cash App Racing Bulls',
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
              coloreRacingBulls.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreRacingBulls.withOpacity(0.7),
            ],
            stops: const [0.0, 0.15, 0.85, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double w = constraints.maxWidth;
              double logoSize = w * 0.2;
              double carWidth = w * 0.9;
              double driverImgWidth = w * 0.25;
              double spacing = w * 0.05;
              if (logoSize > 120) logoSize = 120;
              if (driverImgWidth > 160) driverImgWidth = 160;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, kToolbarHeight + 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/logos/racingbulls.png', width: logoSize, height: logoSize),
                    const SizedBox(height: 24),

                    const Text(
                      'Vettura 2025',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    Image.asset('assets/macchine/racingbulls.png', width: carWidth, fit: BoxFit.contain),
                    const SizedBox(height: 32),

                    const Text(
                      'Piloti',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 12),

                    w < 600
                        ? Column(
                            children: [
                              _buildDriver('assets/piloti/hadjar.png', 'Isack Hadjar', driverImgWidth),
                              SizedBox(height: spacing),
                              _buildDriver('assets/piloti/lawson.png', 'Liam Lawson', driverImgWidth),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildDriver('assets/piloti/hadjar.png', 'Isack Hadjar', driverImgWidth),
                              SizedBox(width: spacing),
                              _buildDriver('assets/piloti/lawson.png', 'Liam Lawson', driverImgWidth),
                            ],
                          ),

                    const SizedBox(height: 40),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('1985', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('1995', style: TextStyle(color: Colors.white)),
                          Text('2005', style: TextStyle(color: Colors.white)),
                          Text('2010', style: TextStyle(color: Colors.white)),
                          Text('2020', style: TextStyle(color: Colors.white)),
                          Text('2024', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Timeline a cascata, ultima barra calcolata dinamicamente
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double w = constraints.maxWidth;
                        double h = 200;

                        double leftMinardi = 0.00;
                        double widthMinardi = 0.54;
                        double topMinardi = 0.0;

                        double leftToroRosso = leftMinardi + widthMinardi;
                        double widthToroRosso = 0.28;
                        double topToroRosso = h * 0.30;

                        double leftAlphaTauri = leftToroRosso + widthToroRosso;
                        double widthAlphaTauri = 0.10;
                        double topAlphaTauri = h * 0.60;

                        double leftRacingBulls = leftAlphaTauri + widthAlphaTauri;
                        double computedWidthRacingBulls = w - (w * leftRacingBulls);
                        double topRacingBulls = h * 0.85;

                        double minWidthPx = 36;
                        double widthRacingBulls =
                            computedWidthRacingBulls < minWidthPx ? minWidthPx : computedWidthRacingBulls;

                        return Container(
                          width: w,
                          height: h,
                          child: Stack(
                            children: [
                              // Minardi
                              Positioned(
                                left: w * leftMinardi,
                                top: topMinardi,
                                child: _logoTimelineBar(
                                  width: w * widthMinardi,
                                  color: coloreMinardi,
                                  logoAsset: 'assets/logos/minardi.png',
                                ),
                              ),
                              // Toro Rosso
                              Positioned(
                                left: w * leftToroRosso,
                                top: topToroRosso,
                                child: _logoTimelineBar(
                                  width: w * widthToroRosso,
                                  color: coloreToroRosso,
                                  logoAsset: 'assets/logos/tororosso.png',
                                ),
                              ),
                              // AlphaTauri
                              Positioned(
                                left: w * leftAlphaTauri,
                                top: topAlphaTauri,
                                child: _logoTimelineBar(
                                  width: w * widthAlphaTauri,
                                  color: coloreAlphaTauri,
                                  logoAsset: 'assets/logos/alphatauri.png',
                                ),
                              ),
                              // Racing Bulls - larghezza dinamica e colore corretto
                              Positioned(
                                left: w * leftRacingBulls,
                                top: topRacingBulls,
                                child: _logoTimelineBar(
                                  width: widthRacingBulls,
                                  color: coloreRacingBulls,
                                  logoAsset: 'assets/logos/racingbulls.png',
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              );
            },
          ),
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
      width: width < 36 ? 36 : width,
      height: 32,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
      ),
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Image.asset(logoAsset, height: 22),
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
