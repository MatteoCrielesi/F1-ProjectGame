// // lib/game_page.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'game/screens/game_screen.dart';
// import 'game/models/circuit.dart';
// import 'game/models/car.dart';

// class GamePage extends StatefulWidget {
//   const GamePage({super.key});

//   @override
//   State<GamePage> createState() => _GamePageState();
// }

// class _GamePageState extends State<GamePage> {
//   final PageController _pageController = PageController(viewportFraction: 0.5);
//   int _currentPage = 0;
//   Circuit? _selectedCircuit;
//   CarModel? _selectedCar;

//   final List<Circuit> circuits = allCircuits; // from game/models/circuit.dart
//   final List<CarModel> teams = allCars; // from game/models/car.dart

//   bool _teamSelected = false;

//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _currentPage = _pageController.initialPage;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   Color.fromARGB(255, 71, 71, 71),
//                   Color.fromARGB(255, 71, 0, 0),
//                   Color.fromARGB(255, 33, 0, 0),
//                 ],
//               ),
//             ),
//           ),
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: Container(height: 3, color: Color(0xFFE10600)),
//           ),
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.only(bottom: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
//                     child: Row(
//                       children: [
//                         SvgPicture.asset('assets/f1_logo.svg', height: 24),
//                         const SizedBox(width: 12),
//                         Text(
//                           'Formula 1',
//                           style: Theme.of(context).textTheme.titleLarge
//                               ?.copyWith(fontWeight: FontWeight.w700),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white10,
//                         foregroundColor: Colors.white,
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         padding: const EdgeInsets.all(12),
//                         minimumSize: const Size(40, 40),
//                       ),
//                       onPressed: () {
//                         if (_selectedCircuit != null && !_teamSelected) {
//                           setState(() {
//                             _selectedCircuit = null;
//                           });
//                         } else if (_selectedCircuit != null && _teamSelected) {
//                           setState(() {
//                             _teamSelected = false;
//                             _selectedCar = null;
//                           });
//                         } else {
//                           Navigator.pop(context);
//                         }
//                       },
//                       child: const Icon(Icons.arrow_back),
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Expanded(
//                     child: _selectedCircuit == null
//                         ? _buildCircuitPicker()
//                         : !_teamSelected
//                         ? _buildTeamPicker()
//                         : _buildStartCard(),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCircuitPicker() {
//     return PageView.builder(
//       controller: _pageController,
//       itemCount: circuits.length,
//       onPageChanged: (index) => setState(() => _currentPage = index),
//       itemBuilder: (context, index) {
//         final circuit = circuits[index];
//         final double scale = (_currentPage == index) ? 1.0 : 0.85;

//         return AnimatedScale(
//           scale: scale,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//           child: GestureDetector(
//             onTap: () {
//               setState(() {
//                 _selectedCircuit = circuit;
//                 _currentPage = index;
//               });
//             },
//             child: SizedBox(
//               height: MediaQuery.of(context).size.height * 0.3,
//               child: Card(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(14),
//                 ),
//                 color: const Color.fromARGB(120, 255, 6, 0),
//                 margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 6),
//                     Text(
//                       circuit.displayName,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: FittedBox(
//                           fit: BoxFit.contain,
//                           child: SvgPicture.asset(
//                             circuit.svgPath,
//                             width: 240,
//                             height: 120,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildTeamPicker() {
//     return Container(
//       color: Colors.black54,
//       child: Center(
//         child: Wrap(
//           spacing: 12,
//           runSpacing: 12,
//           alignment: WrapAlignment.center,
//           children: teams.map((team) {
//             return GestureDetector(
//               onTap: () {
//                 setState(() {
//                   _teamSelected = true;
//                   _selectedCar = team;
//                 });
//               },
//               child: Container(
//                 width: 100,
//                 height: 100,
//                 decoration: BoxDecoration(
//                   color: team.color,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     team.name,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }

//   Widget _buildStartCard() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Circuito: ${_selectedCircuit!.displayName}',
//             style: const TextStyle(color: Colors.white, fontSize: 18),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             width: 120,
//             height: 80,
//             decoration: BoxDecoration(
//               color: _selectedCar?.color ?? Colors.white,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Center(
//               child: Text(
//                 _selectedCar?.name ?? '',
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: () {
//               // apri schermo di gioco
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => GameScreen(
//                     circuit: _selectedCircuit!,
//                     car: _selectedCar!,
//                   ),
//                 ),
//               );
//             },
//             child: const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
//               child: Text('Inizia Gara'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
