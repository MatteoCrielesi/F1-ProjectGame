import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:f1_project/dashboard.dart';

class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula 1 Classifiche',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: Theme.of(context).textTheme.apply(
              fontFamily: 'Roboto',
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const ClassifichePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ClassifichePage extends StatefulWidget {
  const ClassifichePage({super.key});

  @override
  State<ClassifichePage> createState() => _ClassifichePageState();
}

class _ClassifichePageState extends State<ClassifichePage>
    with SingleTickerProviderStateMixin {
  int selectedYear = 2024;
  late final AnimationController _controller;

  final ScrollController _driverScrollController = ScrollController();
  final ScrollController _constructorScrollController = ScrollController();

  final Map<int, Map<String, Color>> teamColorsByYear = {
    2023: {
      'Red Bull Racing': const Color.fromARGB(255, 11, 70, 137),
      'Ferrari': const Color.fromARGB(255, 212, 44, 44),
      'Mercedes': const Color.fromARGB(255, 0, 161, 155),
      'McLaren': const Color.fromARGB(255, 253, 148, 19),
      'Aston Martin': const Color.fromARGB(255, 2, 102, 50),
      'Alpine': const Color.fromARGB(255, 255, 153, 240),
      'Williams': const Color.fromARGB(255, 63, 168, 255),
      'Alpha Tauri': const Color.fromARGB(255, 22, 28, 95),
      'Alfa Romeo': const Color.fromARGB(255, 150, 0, 0),
      'Haas': const Color.fromARGB(241, 117, 117, 117),
    },
    2024: {
      'Red Bull Racing': const Color.fromARGB(255, 11, 70, 137),
      'Ferrari': const Color.fromARGB(255, 212, 44, 44),
      'Mercedes': const Color.fromARGB(255, 0, 161, 155),
      'McLaren': const Color.fromARGB(255, 253, 148, 19),
      'Aston Martin': const Color.fromARGB(255, 2, 102, 50),
      'Alpine': const Color.fromARGB(255, 255, 153, 240),
      'Williams': const Color.fromARGB(255, 63, 168, 255),
      'RB': const Color.fromARGB(255, 22, 28, 95),
      'Sauber': const Color.fromARGB(255, 0, 255, 60),
      'Haas': const Color.fromARGB(241, 117, 117, 117),
    },
  };

  Map<int, List<Driver>> driversByYear = {
    2023: [
      const Driver(rank: 1, name: 'Max Verstappen', points: 575, team: 'Red Bull Racing'),
      const Driver(rank: 2, name: 'Sergio Perez', points: 285, team: 'Red Bull Racing'),
      const Driver(rank: 3, name: 'Lewis Hamilton', points: 234, team: 'Mercedes'),
      const Driver(rank: 4, name: 'Fernando Alonso', points: 206, team: 'Aston Martin'),
      const Driver(rank: 5, name: 'Charles Leclerc', points: 206, team: 'Ferrari'),
      const Driver(rank: 6, name: 'Lando Norris', points: 205, team: 'McLaren'),
      const Driver(rank: 7, name: 'Carlos Sainz', points: 200, team: 'Ferrari'),
      const Driver(rank: 8, name: 'George Russell', points: 175, team: 'Mercedes'),
      const Driver(rank: 9, name: 'Oscar Piastri', points: 97, team: 'McLaren'),
      const Driver(rank: 10, name: 'Lance Stroll', points: 74, team: 'Aston Martin'),
      const Driver(rank: 11, name: 'Pierre Gasly', points: 62, team: 'Alpine'),
      const Driver(rank: 12, name: 'Esteban Ocon', points: 58, team: 'Alpine'),
      const Driver(rank: 13, name: 'Alexander Albon', points: 27, team: 'Williams'),
      const Driver(rank: 14, name: 'Yuki Tsunoda', points: 17, team: 'Alpha Tauri'),
      const Driver(rank: 15, name: 'Valtteri Bottas', points: 10, team: 'Alfa Romeo'),
      const Driver(rank: 16, name: 'Nico Hulkenberg', points: 9, team: 'Haas'),
      const Driver(rank: 17, name: 'Zhou Guanyu', points: 6, team: 'Alfa Romeo'),
      const Driver(rank: 18, name: 'Daniel Ricciardo', points: 6, team: 'Alpha Tauri'),
      const Driver(rank: 19, name: 'Kevin Magnussen', points: 3, team: 'Haas'),
      const Driver(rank: 20, name: 'Liam Lawson', points: 2, team: 'Alpha Tauri'),
      const Driver(rank: 21, name: 'Logan Sargeant', points: 0, team: 'Williams'),
      const Driver(rank: 22, name: 'Nick De Vries', points: 0, team: 'Alpha Tauri'),
    ],
    2024: [
      const Driver(rank: 1, name: 'Max Verstappen', points: 437, team: 'Red Bull Racing'),
      const Driver(rank: 2, name: 'Lando Norris', points: 374, team: 'McLaren'),
      const Driver(rank: 3, name: 'Charles Leclerc', points: 356, team: 'Ferrari'),
      const Driver(rank: 4, name: 'Oscar Piastri', points: 292, team: 'McLaren'),
      const Driver(rank: 5, name: 'Carlos Sainz', points: 290, team: 'Ferrari'),
      const Driver(rank: 6, name: 'George Russell', points: 245, team: 'Mercedes'),
      const Driver(rank: 7, name: 'Lewis Hamilton', points: 223, team: 'Mercedes'),
      const Driver(rank: 8, name: 'Sergio Perez', points: 152, team: 'Red Bull Racing'),
      const Driver(rank: 9, name: 'Fernando Alonso', points: 70, team: 'Aston Martin'),
      const Driver(rank: 10, name: 'Pierre Gasly', points: 42, team: 'Alpine'),
      const Driver(rank: 11, name: 'Nico Hulkenberg', points: 41, team: 'Haas'),
      const Driver(rank: 12, name: 'Yuki Tsunoda', points: 30, team: 'RB'),
      const Driver(rank: 13, name: 'Lance Stroll', points: 24, team: 'Aston Martin'),
      const Driver(rank: 14, name: 'Esteban Ocon', points: 23, team: 'Alpine'),
      const Driver(rank: 15, name: 'Kevin Magnussen', points: 16, team: 'Haas'),
      const Driver(rank: 16, name: 'Alexander Albon', points: 12, team: 'Williams'),
      const Driver(rank: 17, name: 'Daniel Ricciardo', points: 12, team: 'RB'),
      const Driver(rank: 18, name: 'Oliver Bearman', points: 7, team: 'Haas'),
      const Driver(rank: 19, name: 'Franco Colapinto', points: 5, team: 'Williams'),
      const Driver(rank: 20, name: 'Liam Lawson', points: 4, team: 'RB'),
      const Driver(rank: 21, name: 'Zhou Guanyu', points: 4, team: 'Sauber'),
      const Driver(rank: 22, name: 'Valtteri Bottas', points: 0, team: 'Sauber'),
      const Driver(rank: 23, name: 'Logan Sargeant', points: 0, team: 'Williams'),
      const Driver(rank: 24, name: 'Jack Doohan', points: 0, team: 'Alpine'),
    ],
  };

  Map<int, List<Constructor>> constructorsByYear = {
    2023: [
      const Constructor(rank: 1, name: 'Red Bull Racing', points: 860),
      const Constructor(rank: 2, name: 'Mercedes', points: 409),
      const Constructor(rank: 3, name: 'Ferrari', points: 406),
      const Constructor(rank: 4, name: 'McLaren', points: 302),
      const Constructor(rank: 5, name: 'Aston Martin', points: 280),
      const Constructor(rank: 6, name: 'Alpine', points: 120),
      const Constructor(rank: 7, name: 'Williams', points: 28),
      const Constructor(rank: 8, name: 'Alpha Tauri', points: 25),
      const Constructor(rank: 9, name: 'Alfa Romeo', points: 16),
      const Constructor(rank: 10, name: 'Haas', points: 12),
    ],
    2024: [
      const Constructor(rank: 1, name: 'McLaren', points: 666),
      const Constructor(rank: 2, name: 'Ferrari', points: 652),
      const Constructor(rank: 3, name: 'Red Bull Racing', points: 589),
      const Constructor(rank: 4, name: 'Mercedes', points: 468),
      const Constructor(rank: 5, name: 'Aston Martin', points: 94),
      const Constructor(rank: 6, name: 'Alpine', points: 65),
      const Constructor(rank: 7, name: 'Haas', points: 58),
      const Constructor(rank: 8, name: 'RB', points: 46),
      const Constructor(rank: 9, name: 'Williams', points: 17),
      const Constructor(rank: 10, name: 'Sauber', points: 4),
    ],
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _driverScrollController.dispose();
    _constructorScrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final drivers = driversByYear[selectedYear]!;
    final constructors = constructorsByYear[selectedYear]!;
    final teamColors = teamColorsByYear[selectedYear]!;

    return Scaffold(
      body: Stack(
        children: [
          // 🌌 Sfondo gradiente nero → blu
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D0D0D), Color(0xFF001A33), Color(0xFF002B5C)],
              ),
            ),
          ),
          // 🔵 Barra blu in alto
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(height: 3, color: Color(0xFF007BFF)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔝 Header F1 logo + titolo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const _Header(),
                ),
                // 🔽 Row freccia back + combobox anno
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const DashboardPage()),
                          );
                        },
                        child: const Icon(Icons.arrow_back),
                      ),
                      DropdownButton<int>(
                        dropdownColor: Colors.black87,
                        padding: const EdgeInsets.only(right: 12.0),
                        value: selectedYear,
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: driversByYear.keys
                            .map(
                              (year) => DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              ),
                            )
                            .toList(),
                        onChanged: (year) {
                          setState(() {
                            selectedYear = year!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // ✅ Cards scrollabili
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 800;
                        return isWide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildDriverStandings(drivers, teamColors)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildConstructorStandings(constructors, teamColors)),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(child: _buildDriverStandings(drivers, teamColors)),
                                  const SizedBox(height: 12),
                                  Expanded(child: _buildConstructorStandings(constructors, teamColors)),
                                ],
                              );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏁 Driver Standings
  Widget _buildDriverStandings(List<Driver> drivers, Map<String, Color> teamColors) {
    return Card(
      color: const Color(0xFF131313),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF007BFF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Driver Championship',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007BFF),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _driverScrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.separated(
                  controller: _driverScrollController,
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white24,
                  ),
                  itemBuilder: (_, index) {
                    final d = drivers[index];
                    return _buildAnimatedRow(d.rank, d.name, d.team, d.points, teamColors);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🏁 Constructor Standings
  Widget _buildConstructorStandings(List<Constructor> constructors, Map<String, Color> teamColors) {
    return Card(
      color: const Color(0xFF131313),
      elevation: 2,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF007BFF), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Constructor Championship',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF007BFF),
                ),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _constructorScrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.separated(
                  controller: _constructorScrollController,
                  itemCount: constructors.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    thickness: 0.5,
                    color: Colors.white24,
                  ),
                  itemBuilder: (_, index) {
                    final c = constructors[index];
                    return _buildAnimatedRow(c.rank, c.name, c.name, c.points, teamColors);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🟦 Riga animata standings
  Widget _buildAnimatedRow(int rank, String title, String team, int points, Map<String, Color> teamColors) {
    final baseColor = teamColors[team] ?? Colors.grey;
    final isDark = baseColor.computeLuminance() < 0.5;
    final textColor = isDark ? Colors.white : Colors.black87;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: AnimatedBuilder(
        key: ValueKey('$rank-$title-$team-$points-${selectedYear}'),
        animation: _controller,
        builder: (context, child) {
          final pulse = 0.85 + 0.15 * _controller.value;
          final animatedColor = HSLColor.fromColor(baseColor)
              .withLightness((HSLColor.fromColor(baseColor).lightness * pulse).clamp(0.0, 1.0))
              .toColor();

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
            margin: const EdgeInsets.symmetric(vertical: 2.0),
            decoration: BoxDecoration(
              color: animatedColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  child: Text(
                    rank.toString(),
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColor)),
                      if (title != team)
                        Text(team, style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.8))),
                    ],
                  ),
                ),
                Container(
                  width: 60,
                  padding: const EdgeInsets.only(right: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(points.toString(), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
                      const Text('points', style: TextStyle(fontSize: 9, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// 🏁 Header stile Dashboard
class _Header extends StatelessWidget {
  const _Header();

 Widget build(BuildContext context) {
  return Row(
    children: [
      SvgPicture.asset(
        'assets/f1_logo.svg',
        height: 24,
        color: const Color.fromARGB(255, 2, 71, 150), // Colore blu scuro
      ),
      const SizedBox(width: 12),
      Text(
        'Formula 1',
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(
              fontWeight: FontWeight.w700, 
              color: const Color.fromARGB(255, 255, 255, 255), // Colore blu scuro
            ),
      ),
    ],
  );
}

}

// 🏎 Modelli
class Driver {
  final int rank;
  final String name;
  final int points;
  final String team;
  const Driver({required this.rank, required this.name, required this.points, required this.team});
}

class Constructor {
  final int rank;
  final String name;
  final int points;
  const Constructor({required this.rank, required this.name, required this.points});
}
