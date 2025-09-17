// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../controllers/game_controller.dart';
// import '../models/circuit.dart';
// import '../models/car.dart';
// import '../widgets/game_controls_1.dart';

// class GameScreen extends StatefulWidget {
//   final Circuit circuit;
//   final CarModel car;

//   const GameScreen({super.key, required this.circuit, required this.car});

//   @override
//   State<GameScreen> createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   late GameController controller;
//   final GlobalKey _circuitKey = GlobalKey();

//   @override
//   void initState() {
//     super.initState();
//     controller = GameController(circuit: widget.circuit, carModel: widget.car);
//     _initGame();
//   }

//   Future<void> _initGame() async {
//     // Attendere caricamento mask
//     await controller.loadMask();

//     // Assicurarsi che la layout sia pronto
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final renderBox =
//           _circuitKey.currentContext?.findRenderObject() as RenderBox?;
//       if (renderBox != null && renderBox.hasSize) {
//         final size = renderBox.size;
//         controller.updateDisplayLayout(size: size);
//       }

//       // Avvia il loop di gioco
//       controller.start();
//     });
//   }

//   @override
//   void dispose() {
//     controller.disposeController();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       appBar: AppBar(
//         title: Text(widget.circuit.displayName),
//         backgroundColor: Colors.black87,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Expanded(
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   return Stack(
//                     children: [
//                       // Circuit SVG (scaled to fit)
//                       Positioned.fill(
//                         child: Container(
//                           key: _circuitKey,
//                           padding: const EdgeInsets.all(8),
//                           child: SvgPicture.asset(
//                             widget.circuit.svgPath,
//                             fit: BoxFit.contain,
//                             alignment: Alignment.center,
//                           ),
//                         ),
//                       ),

//                       // Car overlay: puntino colorato
//                       AnimatedBuilder(
//                         animation: controller,
//                         builder: (_, __) {
//                           final pos = controller.carPosition;
//                           return Positioned(
//                             left: pos.dx - 5, // centrare il puntino
//                             top: pos.dy - 5,
//                             child: Container(
//                               width: 10,
//                               height: 10,
//                               decoration: BoxDecoration(
//                                 color: widget.car.color,
//                                 shape: BoxShape.circle,
//                                 boxShadow: const [
//                                   BoxShadow(
//                                     blurRadius: 2,
//                                     color: Colors.black38,
//                                     offset: Offset(1, 1),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             // Controls (accelerate / brake only)
//             // Container(
//             //   color: Colors.black87,
//             //   padding: const EdgeInsets.all(8),
//             //   child: GameControls(controller: controller),
//             // ),
//           ],
//         ),
//       ),
//     );
//   }
// }
