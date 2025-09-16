import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dashboard.dart';

class GamePage_1 extends StatefulWidget {
  const GamePage_1({super.key});

  @override
  State<GamePage_1> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage_1> {
  final PageController _pageController = PageController(viewportFraction: 0.5);
  int _currentPage = 0;
  String? _selectedCircuit;
  Color? _selectedTeamColor;

  final List<Map<String, String>> circuits = [
    {"name": "Abudhabi", "asset": "assets/circuiti/abudhabi.svg"},
    {"name": "Australia", "asset": "assets/circuiti/australia.svg"},
    {"name": "Austria", "asset": "assets/circuiti/austria.svg"},
    {"name": "Azerbaijan", "asset": "assets/circuiti/azerbaijan.svg"},
    {"name": "Bahrain", "asset": "assets/circuiti/bahrain.svg"},
    {"name": "Belgium", "asset": "assets/circuiti/belgium.svg"},
    {"name": "Brazil", "asset": "assets/circuiti/brazil.svg"},
    {"name": "Canada", "asset": "assets/circuiti/canada.svg"},
    {"name": "Great Britain", "asset": "assets/circuiti/greatbritain.svg"},
    {"name": "Hungary", "asset": "assets/circuiti/hungary.svg"},
    {"name": "Italy Imola", "asset": "assets/circuiti/italyimola.svg"},
    {"name": "Italy Monza", "asset": "assets/circuiti/italymonza.svg"},
    {"name": "Japan", "asset": "assets/circuiti/japan.svg"},
    {"name": "Mexico", "asset": "assets/circuiti/mexico.svg"},
    {"name": "Monaco", "asset": "assets/circuiti/monaco.svg"},
    {"name": "Netherlands", "asset": "assets/circuiti/netherlands.svg"},
    {"name": "Qatar", "asset": "assets/circuiti/qatar.svg"},
    {"name": "Saudi Arabia", "asset": "assets/circuiti/saudiarabia.svg"},
    {"name": "Shanghai", "asset": "assets/circuiti/shanghai.svg"},
    {"name": "Singapore", "asset": "assets/circuiti/singapore.svg"},
    {"name": "Spain", "asset": "assets/circuiti/spain.svg"},
    {"name": "USA Cota", "asset": "assets/circuiti/usacota.svg"},
    {"name": "USA Miami", "asset": "assets/circuiti/usamiami.svg"},
    {"name": "USA Vegas", "asset": "assets/circuiti/usavegas.svg"},
  ];

  final List<Map<String, dynamic>> teams = [
    {"name": "McLaren", "color": Color(0xFFFF8700)},
    {"name": "Aston Martin", "color": Color(0xFF006F62)},
    {"name": "Alpine", "color": Color.fromARGB(255, 243, 34, 229)},
    {"name": "Ferrari", "color": Color(0xFFDC0000)},
    {"name": "Mercedes", "color": Color(0xFF00D2BE)},
    {"name": "Red Bull Racing", "color": Color(0xFF1E41FF)},
    {"name": "Haas", "color": Color(0xFFB6BABD)},
    {"name": "Racing Bulls", "color": Color(0xFF00205B)},
    {"name": "Kick Sauber", "color": Color.fromARGB(255, 0, 255, 8)},
    {"name": "Williams", "color": Color(0xFF005AFF)},
  ];

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
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(height: 3, color: Color(0xFFE10600)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        SvgPicture.asset('assets/f1_logo.svg', height: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Formula 1',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
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
                        if (_selectedCircuit != null && !_teamSelected) {
                          setState(() {
                            _selectedCircuit = null;
                          });
                        } else if (_selectedCircuit != null && _teamSelected) {
                          setState(() {
                            _teamSelected = false;
                            _selectedTeamColor = null;
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
                  if (_selectedCircuit == null)
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: circuits.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, index) {
                          final circuit = circuits[index];
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
                                  _selectedCircuit = circuit["asset"];
                                  _currentPage = index;
                                });
                              },
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.3,
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
                                        circuit["name"]!,
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
                                              circuit["asset"]!,
                                              colorFilter: null,
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
                  else if (!_teamSelected)
                    Expanded(
                      child: Container(
                        color: Colors.black54,
                        child: Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: teams.map((team) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _teamSelected = true;
                                    _selectedTeamColor = team['color'];
                                  });
                                },
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: team['color'],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      team['name'],
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
                  //else
                    //TODO
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
