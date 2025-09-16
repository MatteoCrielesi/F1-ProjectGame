import 'package:flutter/material.dart';

class RedBullPage extends StatelessWidget {
  const RedBullPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreStewart   = Color(0xFF6A7695); 
    const Color coloreJaguar    = Color(0xFF1E6B52); 
    const Color coloreRedBull   = Color(0xFF1E41FF);  

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Red Bull Racing',
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
              coloreRedBull.withOpacity(0.7),
              Colors.black,
              Colors.black,
              coloreRedBull.withOpacity(0.7),
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
                  Image.asset('assets/logos/redbull.png', width: logoSize, height: logoSize),
                  const SizedBox(height: 24),
                  const Text(
                    'Vettura 2025',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Image.asset('assets/macchine/redbull.png', width: carWidth, fit: BoxFit.contain),
                  const SizedBox(height: 32),
                  const Text(
                    'Piloti',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  screenWidth < 600
                      ? Column(
                          children: [
                            _buildDriver('assets/piloti/verstappen.png', 'Max Verstappen', driverImgWidth),
                            SizedBox(height: spacing),
                            _buildDriver('assets/piloti/tsunoda.png', 'Yuki Tsunoda', driverImgWidth),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDriver('assets/piloti/verstappen.png', 'Max Verstappen', driverImgWidth),
                            SizedBox(width: spacing),
                            _buildDriver('assets/piloti/tsunoda.png', 'Yuki Tsunoda', driverImgWidth),
                          ],
                        ),
                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: showAllDates
                          ? const [
                              Text('1997', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2000', style: TextStyle(color: Colors.white)),
                              Text('2005', style: TextStyle(color: Colors.white)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ]
                          : const [
                              Text('1997', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              Text('2024', style: TextStyle(color: Colors.white)),
                            ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      double w = constraints.maxWidth;
                      double h = 120;
                      return Container(
                        width: w,
                        height: h,
                        child: Stack(
                          children: [
                            Positioned(
                              left: w * 0.00,
                              top: 0,
                              child: _logoTimelineBar(
                                width: w * 0.16 < 40 ? 40 : w * 0.16,
                                color: coloreStewart,
                                logoAsset: 'assets/logos/stewart.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.16,
                              top: h * 0.34,
                              child: _logoTimelineBar(
                                width: w * 0.17 < 40 ? 40 : w * 0.17,
                                color: coloreJaguar,
                                logoAsset: 'assets/logos/jaguar.png',
                              ),
                            ),
                            Positioned(
                              left: w * 0.33,
                              top: h * 0.68,
                              child: _logoTimelineBar(
                                width: w * 0.67 < 40 ? 40 : w * 0.67,
                                color: coloreRedBull,
                                logoAsset: 'assets/logos/redbull.png',
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
