import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'game/screens/game_screen.dart';
import 'game/models/circuit.dart';
import 'game/models/car.dart';
import 'dashboard.dart';

class GamePage_1 extends StatefulWidget {
  const GamePage_1({super.key});

  @override
  State<GamePage_1> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage_1> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentPage = 0;
  Circuit? _selectedCircuit;
  CarModel? _selectedTeam;

  bool _teamSelected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _currentPage = _pageController.initialPage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // sfondo gradiente
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 71, 71, 71),
                  Color.fromARGB(255, 71, 0, 0),
                  Color.fromARGB(255, 33, 0, 0),
                ],
              ),
            ),
          ),
          // barra rossa
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Color(0xFFE10600)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // logo e titolo
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      SvgPicture.asset('assets/f1_logo.svg', height: 24),
                      const SizedBox(width: 12),
                      Text(
                        'Formula 1',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // pulsante back
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      minimumSize: const Size(40, 40),
                    ),
                    onPressed: () {
                      if (_teamSelected) {
                        setState(() {
                          _teamSelected = false;
                          _selectedTeam = null;
                        });
                      } else if (_selectedCircuit != null) {
                        setState(() {
                          _selectedCircuit = null;
                        });
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 20),
                // selezione circuito
                if (_selectedCircuit == null)
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: allCircuits.length,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                      },
                      itemBuilder: (context, index) {
                        final circuit = allCircuits[index];
                        final double scale = (_currentPage == index)
                            ? 1.0
                            : 0.85;

                        return AnimatedScale(
                          scale: scale,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCircuit = circuit;
                                _currentPage = index;
                              });
                            },
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.3,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                color: const Color.fromARGB(120, 255, 6, 0),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 6),
                                    Text(
                                      circuit.displayName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: SvgPicture.asset(
                                            circuit.svgPath,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                // selezione team
                else if (!_teamSelected)
                  Expanded(
                    child: Container(
                      color: Colors.black54,
                      child: Center(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: allCars.map((car) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _teamSelected = true;
                                  _selectedTeam = car;
                                });
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: car.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    car.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  )
                // gioco attivo
                else
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // SVG circuito di sfondo
                        SvgPicture.asset(
                          _selectedCircuit!.svgPath,
                          fit: BoxFit.contain,
                        ),
                        // widget GameScreen con pista e auto
                        GameScreen(
                          circuit: _selectedCircuit!,
                          car: _selectedTeam!,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
