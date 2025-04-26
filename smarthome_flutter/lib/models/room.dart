// lib/models/room.dart

class Room {
  final String nom;
  final int nombreCapteurs;
  final double moyenneValeur;

  Room({
    required this.nom,
    required this.nombreCapteurs,
    required this.moyenneValeur,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      nom: json['room'],
      nombreCapteurs: json['nombre'],
      moyenneValeur: (json['moyenne'] as num).toDouble(),
    );
  }
}
