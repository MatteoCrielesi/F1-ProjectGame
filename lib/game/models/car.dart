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
    color: Color.fromARGB(255, 255, 135, 0),
  ),
  CarModel(
    name: "Aston Martin",
    logoPath: "assets/logos/astonmartin.png",
    color: Color.fromARGB(255, 0, 111, 98),
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
    color: Color.fromARGB(255, 0, 210, 190),
  ),
  CarModel(
    name: "Red Bull Racing",
    logoPath: "assets/logos/RedBullDash.png",
    color: Color.fromARGB(255, 0, 32, 91),
  ),
  CarModel(
    name: "Haas",
    logoPath: "assets/logos/haas.png",
    color: Color.fromARGB(255, 182, 186, 189),
  ),
  CarModel(
    name: "Racing Bulls",
    logoPath: "assets/logos/racingbulls.png",
    color: Color.fromARGB(255, 130, 146, 233),
  ),
  CarModel(
    name: "Kick Sauber",
    logoPath: "assets/logos/kicksauber.png",
    color: Color.fromARGB(255, 0, 255, 8),
  ),
  CarModel(
    name: "Williams",
    logoPath: "assets/logos/williams.png",
    color: Color.fromARGB(255, 0, 90, 255),
  ),
];
