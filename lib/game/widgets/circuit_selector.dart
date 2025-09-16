//import 'package:flutter/material.dart';
//import '../controllers/game_controller.dart';
//import '../models/circuit.dart';
//
//class CircuitSelector extends StatelessWidget {
//  final GameController controller;
//  const CircuitSelector({super.key, required this.controller});
//
//  @override
//  Widget build(BuildContext context) {
//    return ListView.builder(
//      scrollDirection: Axis.horizontal,
//      itemCount: circuits.length,
//      itemBuilder: (_, index) {
//        final c = circuits[index];
//        final selected = c == controller.selectedCircuit;
//        return GestureDetector(
//          onTap: () => controller.selectCircuit(c),
//          child: Container(
//            margin: const EdgeInsets.all(8),
//            padding: const EdgeInsets.all(12),
//            decoration: BoxDecoration(
//              border: Border.all(
//                color: selected ? Colors.amber : Colors.grey,
//                width: 2,
//              ),
//              borderRadius: BorderRadius.circular(12),
//            ),
//            child: Text(c.name),
//          ),
//        );
//      },
//    );
//  }
//}
//