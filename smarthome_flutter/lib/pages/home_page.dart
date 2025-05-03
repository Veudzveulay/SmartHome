// lib/pages/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/capteur.dart';
import '../widgets/sensor_card.dart';
import 'rooms_page.dart';
import 'alertes_page.dart';
import 'equipements_page.dart';
import 'historique_page.dart';
import 'add_capteur_page.dart';
import 'seuils_page.dart';

class HomePage extends StatefulWidget {
  final String token;
  final VoidCallback onLogout;

  const HomePage({Key? key, required this.token, required this.onLogout}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Capteur>> _capteursFuture;
  Timer? _alerteTimer;
  int dernierNombreAlertes = 0;

  @override
  void initState() {
    super.initState();
    _capteursFuture = ApiService.fetchCapteurs(widget.token);
    _startAlerteMonitoring();
  }

  void _startAlerteMonitoring() {
    _alerteTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final alertes = await ApiService.fetchAlertes(widget.token);
      if (alertes.length > dernierNombreAlertes) {
        _afficherAlerte(alertes.length - dernierNombreAlertes);
      }
      dernierNombreAlertes = alertes.length;
    });
  }

  void _afficherAlerte(int nombreAlertes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🚨 Alerte détectée !'),
        content: Text('Il y a $nombreAlertes anomalie(s) détectée(s).'),
        actions: [
          TextButton(
            child: const Text('Voir'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertesPage(token: widget.token),
                ),
              );
            },
          ),
          TextButton(
            child: const Text('Ignorer'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _alerteTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshData() async {
    setState(() {
      _capteursFuture = ApiService.fetchCapteurs(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏠 Maison connectée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Rafraîchir",
            onPressed: _refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.map),
            tooltip: "Voir les pièces",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomsPage(token: widget.token),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.warning_amber_rounded),
            tooltip: "Voir les alertes",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlertesPage(token: widget.token),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_remote),
            tooltip: "Commandes",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EquipementsPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: "Historique",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoriquePage(token: widget.token),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Déconnexion",
            onPressed: widget.onLogout,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: "Configurer les seuils",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeuilsPage(token: widget.token),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Capteur>>(
        future: _capteursFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun capteur trouvé.'));
          } else {
            final capteurs = snapshot.data!;
            return ListView.builder(
              itemCount: capteurs.length,
              itemBuilder: (context, index) {
                return SensorCard(
                  capteur: capteurs[index],
                  token: widget.token,
                  onDelete: _refreshData,
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddCapteurPage(token: widget.token),
            ),
          );
          _refreshData();
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter un capteur',
      ),
    );
  }
}