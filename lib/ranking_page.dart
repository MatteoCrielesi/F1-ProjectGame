import 'package:flutter/material.dart';


class RankingPage extends StatelessWidget {
  const RankingPage({super.key});

    @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula 1 Classifiche',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
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
  int selectedYear = 2023;
  late final AnimationController _controller;

  // 👇 Add scroll controllers
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

  Color darken(Color color, [double amount = .1]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final drivers = driversByYear[selectedYear]!;
    final constructors = constructorsByYear[selectedYear]!;
    final teamColors = teamColorsByYear[selectedYear]!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 40, 20, 15),
              color: Colors.blue[900],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'RANKINGS',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(width: 20),
                      DropdownButton<int>(
                        dropdownColor: Colors.blue[900],
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
                  const SizedBox(height: 6),
                  Text(
                    'Keep up with driver and constructor standings, race by race.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildDriverStandings(drivers, teamColors)),
                            const SizedBox(width: 10),
                            Expanded(child: _buildConstructorStandings(constructors, teamColors)),
                          ],
                        )
                      : Column(
                          children: [
                            _buildDriverStandings(drivers, teamColors),
                            const SizedBox(height: 10),
                            _buildConstructorStandings(constructors, teamColors),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverStandings(List<Driver> drivers, Map<String, Color> teamColors) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Driver Championship',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
            Container(
              height: 420,
              child: Scrollbar(
                controller: _driverScrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.separated(
                  controller: _driverScrollController,
                  itemCount: drivers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
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

  Widget _buildConstructorStandings(List<Constructor> constructors, Map<String, Color> teamColors) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                'Constructor Championship',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900]),
              ),
            ),
            Container(
              height: 420,
              child: Scrollbar(
                controller: _constructorScrollController,
                thumbVisibility: true,
                thickness: 6,
                radius: const Radius.circular(3),
                child: ListView.separated(
                  controller: _constructorScrollController,
                  itemCount: constructors.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, thickness: 0.5),
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
          final pulse = 0.8 + 0.2 * _controller.value;
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

class Driver {
  final int rank;
  final String name;
  final int points;
  final String team;

  const Driver({
    required this.rank,
    required this.name,
    required this.points,
    required this.team,
  });
}

class Constructor {
  final int rank;
  final String name;
  final int points;

  const Constructor({
    required this.rank,
    required this.name,
    required this.points,
  });
}