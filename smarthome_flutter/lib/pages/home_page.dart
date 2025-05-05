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
        title: const Text('🚨 Nouvelle alerte détectée !'),
        content: Text('Il y a $nombreAlertes nouvelle(s) anomalie(s).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ignorer'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlertesPage(token: widget.token)),
              );
            },
            child: const Text('Voir les alertes'),
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
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: const Text('🏠 Maison connectée'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'rooms':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RoomsPage(token: widget.token)));
                  break;
                case 'alertes':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => AlertesPage(token: widget.token)));
                  break;
                case 'equipements':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => EquipementsPage(token: widget.token)));
                  break;
                case 'historique':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HistoriquePage(token: widget.token)));
                  break;
                case 'seuils':
                  Navigator.push(context, MaterialPageRoute(builder: (_) => SeuilsPage(token: widget.token)));
                  break;
                case 'logout':
                  widget.onLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rooms', child: Text('🏘 Pièces')),
              const PopupMenuItem(value: 'alertes', child: Text('🚨 Alertes')),
              const PopupMenuItem(value: 'equipements', child: Text('🔧 Équipements')),
              const PopupMenuItem(value: 'historique', child: Text('🕓 Historique')),
              const PopupMenuItem(value: 'seuils', child: Text('📏 Seuils')),
              const PopupMenuItem(value: 'logout', child: Text('🔓 Déconnexion')),
            ],
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
            return RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: capteurs.length,
                itemBuilder: (context, index) {
                  return SensorCard(
                    capteur: capteurs[index],
                    token: widget.token,
                    onDelete: _refreshData,
                  );
                },
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCapteurPage(token: widget.token),
            ),
          );
          _refreshData();
        },
        label: const Text('Ajouter capteur'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}