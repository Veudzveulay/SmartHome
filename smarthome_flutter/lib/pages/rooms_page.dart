// lib/pages/rooms_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/room.dart';

class RoomsPage extends StatefulWidget {
  final String token;
  const RoomsPage({Key? key, required this.token}) : super(key: key);

  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  late Future<List<Room>> roomsFuture;

  @override
  void initState() {
    super.initState();
    roomsFuture = ApiService.getRooms(widget.token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📍 Pièces de la Maison'),
      ),
      body: FutureBuilder<List<Room>>(
        future: roomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune pièce trouvée.'));
          } else {
            final rooms = snapshot.data!;
            return ListView.builder(
              itemCount: rooms.length,
              itemBuilder: (context, index) {
                final room = rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.room, size: 30, color: Colors.blue),
                    title: Text(
                      room.nom.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('Capteurs : ${room.nombreCapteurs}\nMoyenne : ${room.moyenneValeur.toStringAsFixed(2)}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
