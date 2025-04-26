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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🛠 Commandes équipements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "volet", "ouvrir"),
            child: const Text('🪟 Ouvrir volet'),
          ),
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "volet", "fermer"),
            child: const Text('🪟 Fermer volet'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "lumiere", "allumer"),
            child: const Text('💡 Allumer lumière'),
          ),
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "lumiere", "eteindre"),
            child: const Text('💡 Éteindre lumière'),
          ),
          const Divider(),
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "porte", "ouvrir"),
            child: const Text('🚪 Ouvrir porte'),
          ),
          ElevatedButton(
            onPressed: () => _envoyerCommande(context, "porte", "fermer"),
            child: const Text('🚪 Fermer porte'),
          ),
        ],
      ),
    );
  }
}
