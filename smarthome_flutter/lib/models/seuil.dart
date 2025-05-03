class Seuil {
  final String type;
  final double valeur;

  Seuil({required this.type, required this.valeur});

  factory Seuil.fromJson(Map<String, dynamic> json) {
    return Seuil(
      type: json['type'],
      valeur: json['valeur'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'valeur': valeur,
  };
}