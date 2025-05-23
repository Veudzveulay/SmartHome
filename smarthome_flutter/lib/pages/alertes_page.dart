import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/capteur.dart';
import '../widgets/sensor_card.dart';

class AlertesPage extends StatefulWidget {
  final String token;

  const AlertesPage({Key? key, required this.token}) : super(key: key);

  @override
  State<AlertesPage> createState() => _AlertesPageState();
}

class _AlertesPageState extends State<AlertesPage> {
  late Future<List<Capteur>> _alertesFuture;

  @override
  void initState() {
    super.initState();
    _chargerAlertes();
  }

  void _chargerAlertes() {
    setState(() {
      _alertesFuture = ApiService.fetchAlertes(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 Alertes détectées'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Rafraîchir",
            onPressed: _chargerAlertes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: FutureBuilder<List<Capteur>>(
          future: _alertesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('❌ Erreur : ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('✅ Aucune alerte détectée.'));
            } else {
              final alertes = snapshot.data!;
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: alertes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  return SensorCard(
                    capteur: alertes[index],
                    token: widget.token,
                    onDelete: _chargerAlertes,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}