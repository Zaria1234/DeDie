import 'package:flutter/material.dart';
import 'package:frontend/screens/user/Profil.dart';
import 'package:frontend/screens/admin/admin_login.dart';

void main() {
  runApp(DedieApp());
}

class DedieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ĐeDie - Sécurité Aéronautique',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: AdminLoginScreen(),
      home: Profil(),
      debugShowCheckedModeBanner: false,
    );
  }
}
