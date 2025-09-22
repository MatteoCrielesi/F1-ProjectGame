// lib/game/models/car.dart
import 'package:flutter/material.dart';

class CarModel {
  final String name;
  final Color color;
  final String logoPath;
  const CarModel({
    required this.name,
    required this.color,
    required this.logoPath,
  }) : assert(name != ''),
       assert(logoPath != '');
}

const List<CarModel> allCars = [
  CarModel(
    name: "McLaren",
    logoPath: "assets/logos/mclaren_swoosh.png",
    color: Color(0xFFFF8700),
  ),
  CarModel(
    name: "Aston Martin",
    logoPath: "assets/logos/astonmartin.png",
    color: Color(0xFF006F62),
  ),
  CarModel(
    name: "Alpine",
    logoPath: "assets/logos/AlpineDash.png",
    color: Color.fromARGB(255, 243, 34, 229),
  ),
  CarModel(
    name: "Ferrari",
    logoPath: "assets/logos/ferrari.png",
    color: Color.fromARGB(255, 150, 6, 6),
  ),
  CarModel(
    name: "Mercedes",
    logoPath: "assets/logos/mercedes.png",
    color: Color(0xFF00D2BE),
  ),
  CarModel(
    name: "Red Bull Racing",
    logoPath: "assets/logos/RedBullDash.png",
    color: Color(0xFF1E41FF),
  ),
  CarModel(
    name: "Haas",
    logoPath: "assets/logos/haas.png",
    color: Color(0xFFB6BABD),
  ),
  CarModel(
    name: "Racing Bulls",
    logoPath: "assets/logos/racingbulls.png",
    color: Color(0xFF00205B),
  ),
  CarModel(
    name: "Kick Sauber",
    logoPath: "assets/logos/kicksauber.png",
    color: Color.fromARGB(255, 0, 255, 8),
  ),
  CarModel(
    name: "Williams",
    logoPath: "assets/logos/williams.png",
    color: Color(0xFF005AFF),
  ),
];
