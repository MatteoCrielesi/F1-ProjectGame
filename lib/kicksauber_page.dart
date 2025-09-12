import 'package:flutter/material.dart';

class KickSauberPage extends StatelessWidget {
  const KickSauberPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color coloreKickSauber = Color.fromARGB(255, 0, 255, 8);

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
              coloreKickSauber.withOpacity(0.7), // bordo sinistro sfumato verde
              Colors.black,                       // centro nero dominante
              Colors.black,                       // centro nero dominante
              coloreKickSauber.withOpacity(0.7), // bordo destro sfumato verde
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
              padding: EdgeInsets.fromLTRB(
                16,
                kToolbarHeight + 24,
                16,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('assets/logos/kicksauber.png', width: logoSize, height: logoSize, color: coloreKickSauber,),

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