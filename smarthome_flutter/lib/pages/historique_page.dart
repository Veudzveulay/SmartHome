// lib/pages/historique_page.dart

import 'package:flutter/material.dart';
import '../models/action_historique.dart';
import '../services/api_service.dart';

class HistoriquePage extends StatefulWidget {
  final String token;

  const HistoriquePage({Key? key, required this.token}) : super(key: key);

  @override
  State<HistoriquePage> createState() => _HistoriquePageState();
}

class _HistoriquePageState extends State<HistoriquePage> {
  late Future<List<ActionHistorique>> _historiqueFuture;

  @override
  void initState() {
    super.initState();
    _historiqueFuture = ApiService.fetchHistorique(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🕒 Historique des actions'),
      ),
      body: FutureBuilder<List<ActionHistorique>>(
        future: _historiqueFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune action historique.'));
          } else {
            final actions = snapshot.data!;
            return ListView.builder(
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(action.action),
                  subtitle: Text(action.horodatage),
                );
              },
            );
          }
        },
      ),
    );
  }
}
