// lib/widgets/sensor_card.dart

import 'package:flutter/material.dart';
import '../models/capteur.dart';

class SensorCard extends StatelessWidget {
  final Capteur capteur;

  const SensorCard({Key? key, required this.capteur}) : super(key: key);

  Color _getColor() {
    if (capteur.type.toLowerCase() == 'température') {
      if (capteur.valeur > 30) return Colors.redAccent;
      if (capteur.valeur < 18) return Colors.blueAccent;
      return Colors.green;
    }
    return Colors.grey;
  }

  IconData _getIcon() {
    switch (capteur.type.toLowerCase()) {
      case 'température':
        return Icons.thermostat;
      case 'mouvement':
        return Icons.directions_run;
      case 'fumée':
        return Icons.smoke_free;
      default:
        return Icons.sensors;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(
          _getIcon(),
          color: _getColor(),
          size: 32,
        ),
        title: Text(
          '${capteur.type} - ${capteur.room}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Valeur : ${capteur.valeur.toStringAsFixed(2)}'),
            Text(
              capteur.horodatage,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}