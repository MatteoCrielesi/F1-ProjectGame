import 'package:flutter/material.dart';
import 'scuderia.dart';

class ScuderiaCard extends StatelessWidget {
  final Scuderia scuderia;

  const ScuderiaCard({super.key, required this.scuderia});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Card(
        color: Colors.white.withAlpha((0.9 * 255).round()), 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: ListTile(
          leading: Image.asset(
            scuderia.logo,
            width: 60,
            height: 60,
          ),
          title: Text(
            scuderia.nome,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(scuderia.descrizione),
        ),
      ),
    );
  }
}
