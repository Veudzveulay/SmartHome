import 'package:flutter/material.dart';
import '../models/seuil.dart';
import '../services/api_service.dart';

class SeuilsPage extends StatefulWidget {
  final String token;

  const SeuilsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<SeuilsPage> createState() => _SeuilsPageState();
}

class _SeuilsPageState extends State<SeuilsPage> {
  late Future<List<Seuil>> _seuilsFuture;
  List<String> _typesDisponibles = [];
  String? _selectedType;
  final _formKey = GlobalKey<FormState>();
  final _valeurController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _chargerSeuils();
    _chargerTypes();
  }

  void _chargerSeuils() {
    setState(() {
      _seuilsFuture = ApiService.fetchSeuils(widget.token);
    });
  }

  void _chargerTypes() async {
    try {
      final types = await ApiService.fetchTypesCapteurs(widget.token);
      setState(() {
        _typesDisponibles = types;
        if (_typesDisponibles.isNotEmpty) {
          _selectedType = _typesDisponibles.first;
        }
      });
    } catch (e) {
      print("❌ Erreur chargement des types : $e");
    }
  }

  void _ajouterOuModifierSeuil() async {
    if (_formKey.currentState!.validate() && _selectedType != null) {
      final type = _selectedType!.toLowerCase();
      final valeur = double.parse(_valeurController.text);

      final success = await ApiService.setSeuil(type, valeur, widget.token);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Seuil mis à jour")),
        );
        _valeurController.clear();
        _chargerSeuils();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Erreur lors de l’envoi")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📏 Paramétrage des seuils")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type de capteur'),
                        items: _typesDisponibles.map((type) {
                          return DropdownMenuItem(value: type, child: Text(type));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedType = val),
                        validator: (val) =>
                            val == null || val.isEmpty ? "Type requis" : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _valeurController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Valeur seuil'),
                        validator: (value) {
                          if (value == null || value.isEmpty) return "Valeur requise";
                          final numValue = double.tryParse(value);
                          if (numValue == null) return "Doit être un nombre";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _ajouterOuModifierSeuil,
                          icon: const Icon(Icons.save),
                          label: const Text("Enregistrer"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "🔍 Seuils existants",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Expanded(
              child: FutureBuilder<List<Seuil>>(
                future: _seuilsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("❌ Erreur : ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Aucun seuil défini"));
                  } else {
                    final seuils = snapshot.data!;
                    return ListView.separated(
                      itemCount: seuils.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final s = seuils[index];
                        return ListTile(
                          leading: const Icon(Icons.tune),
                          title: Text("${s.type}"),
                          subtitle: Text("Seuil : ${s.valeur}"),
                          trailing: const Icon(Icons.warning_amber),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}