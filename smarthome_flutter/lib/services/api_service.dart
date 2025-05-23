// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/capteur.dart';
import '../models/room.dart';
import '../models/action_historique.dart';
import '../models/seuil.dart';

class ApiService {
  static const String baseUrl = "http://localhost:18080";
  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _token = data['token'];
      return _token;
    } else {
      return null;
    }
  }

  static Future<List<Capteur>> fetchCapteurs(String token) async {
  final url = Uri.parse('$baseUrl/capteurs');
  final response = await http.get(url, headers: {
    'Authorization': 'Bearer $token',
  });

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((item) => Capteur.fromJson(item)).toList();
  } else {
    throw Exception('Erreur lors du chargement des capteurs');
  }
}

  // Ajout de cette fonction pour récupérer les pièces
  static Future<List<Room>> getRooms(String token) async {
    final url = Uri.parse('$baseUrl/rooms');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => Room.fromJson(item)).toList();
    } else {
      throw Exception('Erreur lors du chargement des pièces');
    }
  }

  static Future<List<Capteur>> fetchAlertes(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/alertes'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Capteur.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement alertes');
    }
  }

  static Future<bool> envoyerCommande(String equipement, String action, String token) async {
    final url = Uri.parse('$baseUrl/equipements/$equipement?action=$action');
    final response = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
    });

    return response.statusCode == 200;
  }

  static Future<List<ActionHistorique>> fetchHistorique(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/historique'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => ActionHistorique.fromJson(e)).toList();
    } else {
      throw Exception('Erreur récupération historique');
    }
  }

  static Future<bool> ajouterCapteur(String type, String room, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/ajouter_capteur'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type,
        'room': room,
      }),
    );
    return response.statusCode == 201;
  }

  static Future<bool> supprimerCapteur(int id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/capteurs/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> modifierSeuil(String type, double seuil, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/seuils'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'type': type, 'seuil': seuil}),
    );

    return response.statusCode == 200;
  }

  static Future<List<Seuil>> fetchSeuils(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/seuils'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Seuil.fromJson(e)).toList();
    } else {
      throw Exception("Erreur récupération des seuils");
    }
  }

  static Future<bool> setSeuil(String type, double valeur, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/seuils'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'type': type, 'valeur': valeur}),
    );

    return response.statusCode == 200;
  }
  
  static Future<List<String>> fetchTypesCapteurs(String token) async {
    final url = Uri.parse('$baseUrl/types_capteurs');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => e.toString()).toList();
    } else {
      throw Exception('Erreur récupération des types de capteurs');
    }
  }

  static Future<bool> register(String username, String password) async {
    final url = Uri.parse('$baseUrl/register');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    return response.statusCode == 201;
  }


}
