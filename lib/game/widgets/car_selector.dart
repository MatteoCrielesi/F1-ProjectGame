//import 'package:flutter/material.dart';
//import '../controllers/game_controller.dart';
//import '../models/car.dart';
//
//class CarSelector extends StatelessWidget {
//  final GameController controller;
//  const CarSelector({super.key, required this.controller});
//
//  @override
//  Widget build(BuildContext context) {
//    return GridView.builder(
//      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//        crossAxisCount: 5,
//      ),
//      itemCount: cars.length,
//      itemBuilder: (_, index) {
//        final c = cars[index];
//        final selected = c == controller.selectedCar;
//        return GestureDetector(
//          onTap: () => controller.selectCar(c),
//          child: Container(
//            margin: const EdgeInsets.all(8),
//            decoration: BoxDecoration(
//              color: c.color,
//              border: Border.all(
//                color: selected ? Colors.amber : Colors.black,
//                width: 3,
//              ),
//              borderRadius: BorderRadius.circular(8),
//            ),
//          ),
//        );
//      },
//    );
//  }
//}
//