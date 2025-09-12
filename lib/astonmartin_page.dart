import 'package:flutter/material.dart';

class AstonMartinPage extends StatelessWidget {
  const AstonMartinPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreAstonMartin = Color(0xFF006F62);

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
