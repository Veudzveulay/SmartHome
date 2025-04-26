// lib/models/action_historique.dart

class ActionHistorique {
  final int id;
  final String action;
  final String horodatage;

  ActionHistorique({
    required this.id,
    required this.action,
    required this.horodatage,
  });

  factory ActionHistorique.fromJson(Map<String, dynamic> json) {
    return ActionHistorique(
      id: json['id'],
      action: json['action'],
      horodatage: json['horodatage'],
    );
  }
}
