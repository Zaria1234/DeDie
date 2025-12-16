// dedie-web-admin/lib/main.dart
import 'package:flutter/material.dart';
import 'screens/admin/admin_login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ĐeDie Admin Dashboard',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: AdminLoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
