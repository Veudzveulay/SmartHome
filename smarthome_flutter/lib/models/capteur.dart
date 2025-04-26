// lib/models/capteur.dart

class Capteur {
  final int id;
  final String type;
  final double valeur;
  final String horodatage;
  final String room;

  Capteur({
    required this.id,
    required this.type,
    required this.valeur,
    required this.horodatage,
    required this.room,
  });

  // 🔄 Conversion depuis JSON
  factory Capteur.fromJson(Map<String, dynamic> json) {
    return Capteur(
      id: json['id'],
      type: json['type'],
      valeur: (json['valeur'] ?? 0).toDouble(),
      horodatage: json['horodatage'],
      room: json['room'],
    );
  }
}
