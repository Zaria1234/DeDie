import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class UserHistoryScreen extends StatefulWidget {
  @override
  _UserHistoryScreenState createState() => _UserHistoryScreenState();
}

class _UserHistoryScreenState extends State<UserHistoryScreen> {
  final _userIdController = TextEditingController();
  List<dynamic> _userReports = [];

  Future<void> _loadUserReports() async {
    if (_userIdController.text.isEmpty) return;

    final response = await http.get(
      // Uri.parse(
      //   'http://localhost:3000/api/user/reports/${_userIdController.text}',
      // ),
      Uri.parse(ApiConfig.userReports(_userIdController.text)),
    );

    if (response.statusCode == 200) {
      setState(() {
        _userReports = json.decode(response.body);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Historique Utilisateur')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              decoration: InputDecoration(
                labelText: 'Entrez votre ID anonyme',
                hintText: 'Ex: USER_ABC123DEF',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _loadUserReports,
              child: Text('Charger mes signalements'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _userReports.length,
                itemBuilder: (context, index) {
                  final report = _userReports[index];
                  return Card(
                    child: ListTile(
                      title: Text(report['category']),
                      subtitle: Text(report['description']),
                      trailing: Chip(
                        label: Text(report['status']),
                        backgroundColor: report['status'] == 'pending'
                            ? Colors.orange
                            : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
