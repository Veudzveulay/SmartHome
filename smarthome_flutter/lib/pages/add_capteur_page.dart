import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddCapteurPage extends StatefulWidget {
  final String token;

  const AddCapteurPage({Key? key, required this.token}) : super(key: key);

  @override
  State<AddCapteurPage> createState() => _AddCapteurPageState();
}

class _AddCapteurPageState extends State<AddCapteurPage> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();

  Future<void> _submit() async {
    final type = _typeController.text.trim();
    final room = _roomController.text.trim();

    if (type.isEmpty || room.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    final reussi = await ApiService.ajouterCapteur(type, room, widget.token);

    if (reussi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Capteur ajouté avec succès')),
      );
      Navigator.pop(context); // Revenir à la page précédente
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Erreur ajout capteur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('➕ Ajouter un capteur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _typeController,
              decoration: const InputDecoration(labelText: 'Type (température, mouvement, etc.)'),
            ),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: 'Pièce (salon, chambre, etc.)'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Ajouter capteur'),
            ),
          ],
        ),
      ),
    );
  }
}