import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'admin_report_detail.dart';
import '../../config.dart';

class AdminDashboard extends StatefulWidget {
  final String token;

  AdminDashboard({required this.token});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _reports = [];
  Map<String, dynamic> _stats = {
    'total': 0,
    'pending': 0,
    'in_progress': 0,
    'resolved': 0,
  };
  bool _isLoading = true;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _connectToSocket();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void _connectToSocket() {
    _socket = IO.io(
      ApiConfig.baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).setQuery({
        'adminToken': widget.token,
      }).build(),
    );

    _socket!.onConnect((_) {
      print('Dashboard admin connecté en temps réel');
    });

    _socket!.on('new_report', (data) {
      setState(() {
        _reports.insert(0, data);
        _stats['total'] = (_stats['total'] ?? 0) + 1;
        _stats['pending'] = (_stats['pending'] ?? 0) + 1;
      });

      // Notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nouveau signalement reçu!'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    });

    _socket!.on('status_update', (data) {
      // Mettre à jour un signalement spécifique
      setState(() {
        final index = _reports.indexWhere((r) => r['id'] == data['id']);
        if (index != -1) {
          _reports[index] = data;
          _updateStats();
        }
      });
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      // Charger les stats
      final statsResponse = await http.get(
        // Uri.parse('http://localhost:3000/api/admin/dashboard-stats'),
        Uri.parse(ApiConfig.adminDashboardStats),
      );

      if (statsResponse.statusCode == 200) {
        setState(() {
          _stats = json.decode(statsResponse.body);
        });
      }

      // Charger les signalements récents
      final reportsResponse = await http.get(
        // Uri.parse('http://localhost:3000/api/admin/reports'),
        Uri.parse(ApiConfig.adminReports),
      );

      if (reportsResponse.statusCode == 200) {
        final data = json.decode(reportsResponse.body);
        setState(() {
          _reports = data['reports'];
        });
      }
    } catch (e) {
      print('Erreur chargement dashboard: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateStats() {
    int pending = 0;
    int inProgress = 0;
    int resolved = 0;

    for (var report in _reports) {
      switch (report['status']) {
        case 'pending':
          pending++;
          break;
        case 'in_progress':
          inProgress++;
          break;
        case 'resolved':
          resolved++;
          break;
      }
    }

    setState(() {
      _stats['pending'] = pending;
      _stats['in_progress'] = inProgress;
      _stats['resolved'] = resolved;
      _stats['total'] = _reports.length;
    });
  }

  Future<void> _updateReportStatus(int reportId, String status) async {
    try {
      final response = await http.put(
        // Uri.parse('http://localhost:3000/api/admin/reports/$reportId'),
        Uri.parse('${ApiConfig.baseUrl}/api/admin/reports/$reportId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await _loadDashboardData();
      }
    } catch (e) {
      print('Erreur mise à jour: $e');
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Nouveau';
      case 'in_progress':
        return 'En cours';
      case 'resolved':
        return 'Traité';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard Admin - ANAC',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 29, 7, 195),
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadDashboardData),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
                  Text(
                    'Tableau de Bord',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vue d\'ensemble des signalements en temps réel',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 32),

                  // Cartes de statistiques
                  _buildStatsCards(),
                  SizedBox(height: 32),

                  // Liste des signalements
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Incidents Signalés',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_reports.length} signalements',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Liste des signalements récents',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),

                  // Tableau des signalements
                  _buildReportsTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Nouveaux',
          count: _stats['pending']?.toString() ?? '0',
          subtitle: 'En attente de traitement',
          color: Colors.orange,
        ),
        _buildStatCard(
          title: 'En cours',
          count: _stats['in_progress']?.toString() ?? '0',
          subtitle: 'En cours de traitement',
          color: Colors.blue,
        ),
        _buildStatCard(
          title: 'Traités',
          count: _stats['resolved']?.toString() ?? '0',
          subtitle: 'Incidents résolus',
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required String subtitle,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTable() {
    if (_reports.isEmpty) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'Aucun signalement pour le moment',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // En-tête du tableau
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildTableHeader('ID', flex: 1),
                  _buildTableHeader('TYPE', flex: 2),
                  _buildTableHeader('DATE', flex: 2),
                  _buildTableHeader('STATUT', flex: 2),
                  _buildTableHeader('ACTIONS', flex: 3),
                ],
              ),
            ),
            Divider(height: 1),

            // Lignes des signalements
            ..._reports.map((report) {
              return _buildReportRow(report);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildReportRow(Map<String, dynamic> report) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          _buildTableCell('#${report['id']}', flex: 1),
          _buildTableCell(report['category'] ?? 'Non spécifié', flex: 2),
          _buildTableCell(_formatDate(report['created_at']), flex: 2),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(report['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getStatusColor(report['status']).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(report['status']),
                  style: TextStyle(
                    color: _getStatusColor(report['status']),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Row(
                children: [
                  if (report['status'] == 'pending')
                    ElevatedButton(
                      onPressed: () =>
                          _updateReportStatus(report['id'], 'in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(0, 32),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        'Prendre en charge',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                  if (report['status'] == 'in_progress')
                    ElevatedButton(
                      onPressed: () =>
                          _updateReportStatus(report['id'], 'resolved'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        minimumSize: Size(0, 32),
                        padding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                      child: Text(
                        'Marquer résolu',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                  SizedBox(width: 8),

                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminReportDetail(report: report),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(0, 32),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text('Voir', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(fontSize: 13, color: Colors.grey[800]),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
