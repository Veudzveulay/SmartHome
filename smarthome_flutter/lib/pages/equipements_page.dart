import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EquipementsPage extends StatelessWidget {
  final String token;
  final VoidCallback? onRefreshHistorique;

  const EquipementsPage({
    Key? key,
    required this.token,
    this.onRefreshHistorique,
  }) : super(key: key);

  Future<void> _envoyerCommande(BuildContext context, String equipement, String action) async {
    final reussi = await ApiService.envoyerCommande(equipement, action, token);
    final snackBar = SnackBar(
      content: Text(reussi ? '✅ $equipement : $action' : '❌ Erreur en envoyant la commande'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (reussi && onRefreshHistorique != null) {
      onRefreshHistorique!();
    }
  }

  Widget _buildCard(BuildContext context, String title, List<Map<String, dynamic>> actions) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: actions.map((action) {
                return ElevatedButton.icon(
                  onPressed: () => _envoyerCommande(
                    context,
                    action['equipement'],
                    action['action'],
                  ),
                  icon: Icon(action['icon']),
                  label: Text(action['label']),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛠 Commandes équipements')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCard(context, "🪟 Volets", [
              {'label': 'Ouvrir', 'action': 'ouvrir', 'equipement': 'volet', 'icon': Icons.open_in_new},
              {'label': 'Fermer', 'action': 'fermer', 'equipement': 'volet', 'icon': Icons.close},
            ]),
            _buildCard(context, "💡 Lumières", [
              {'label': 'Allumer', 'action': 'allumer', 'equipement': 'lumiere', 'icon': Icons.lightbulb},
              {'label': 'Éteindre', 'action': 'eteindre', 'equipement': 'lumiere', 'icon': Icons.lightbulb_outline},
            ]),
            _buildCard(context, "🚪 Porte", [
              {'label': 'Ouvrir', 'action': 'ouvrir', 'equipement': 'porte', 'icon': Icons.door_front_door},
              {'label': 'Fermer', 'action': 'fermer', 'equipement': 'porte', 'icon': Icons.door_back_door},
            ]),
          ],
        ),
      ),
    );
  }
}