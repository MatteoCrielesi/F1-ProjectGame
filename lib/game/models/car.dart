// lib/game/models/car.dart
import 'package:flutter/material.dart';

class CarModel {
  final String name;
  final Color color;
  const CarModel({required this.name, required this.color});
}

const List<CarModel> allCars = [
  CarModel(name: "McLaren", color: Color(0xFFFF8700)),
  CarModel(name: "Aston Martin", color: Color(0xFF006F62)),
  CarModel(name: "Alpine", color: Color.fromARGB(255, 243, 34, 229)),
  CarModel(name: "Ferrari", color: Color(0xFFDC0000)),
  CarModel(name: "Mercedes", color: Color(0xFF00D2BE)),
  CarModel(name: "Red Bull Racing", color: Color(0xFF1E41FF)),
  CarModel(name: "Haas", color: Color(0xFFB6BABD)),
  CarModel(name: "Racing Bulls", color: Color(0xFF00205B)),
  CarModel(name: "Kick Sauber", color: Color.fromARGB(255, 0, 255, 8)),
  CarModel(name: "Williams", color: Color(0xFF005AFF)),
];
