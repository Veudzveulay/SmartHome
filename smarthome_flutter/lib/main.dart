import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? token;

  void _setToken(String t) {
    setState(() => token = t);
  }

  void _logout() {
    setState(() => token = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartHome',
      debugShowCheckedModeBanner: false,
      home: token == null
          ? LoginPage(onLogin: _setToken)
          : HomePage(token: token!, onLogout: _logout),
    );
  }
}