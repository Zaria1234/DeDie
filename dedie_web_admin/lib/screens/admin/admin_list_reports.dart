import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'admin_report_detail.dart';
import '../../config.dart';

class AdminReportsList extends StatefulWidget {
  // Enlever le token si tu ne l'utilises plus
  AdminReportsList({Key? key}) : super(key: key);

  @override
  _AdminReportsListState createState() => _AdminReportsListState();
}

class _AdminReportsListState extends State<AdminReportsList> {
  List<dynamic> _reports = [];
  Map<String, dynamic> _stats = {
    'total': 0,
    'pending': 0,
    'in_progress': 0,
    'resolved': 0,
  };
  bool _isLoading = true;
  Timer? _refreshTimer;
  DateTime _lastUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (mounted) {
        _loadDashboardData();
      }
    });
  }

  Future<void> _loadDashboardData() async {
    if (!mounted) return;

    try {
      // Charger les stats
      final statsResponse = await http.get(
        Uri.parse(ApiConfig.adminDashboardStats),
      );

      if (statsResponse.statusCode == 200) {
        final statsData = json.decode(statsResponse.body);
        if (mounted) {
          setState(() {
            _stats = statsData;
            _lastUpdate = DateTime.now();
          });
        }
      }

      // Charger les signalements récents
      final reportsResponse = await http.get(Uri.parse(ApiConfig.adminReports));

      if (reportsResponse.statusCode == 200) {
        final data = json.decode(reportsResponse.body);
        if (mounted) {
          final oldReportsCount = _reports.length;
          final newReports = data['reports'] ?? [];

          setState(() {
            _reports = newReports;
            _isLoading = false;
          });

          // Vérifier si nouveau signalement
          if (newReports.isNotEmpty &&
              oldReportsCount > 0 &&
              newReports[0]['id'] != _reports[0]['id']) {
            _showNewReportNotification();
          }
        }
      }
    } catch (e) {
      print('Erreur chargement dashboard: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showNewReportNotification() {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_active, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Text('🆕 Nouveau signalement reçu!'),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _updateReportStatus(int reportId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/api/admin/reports/$reportId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        await _loadDashboardData();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Statut mis à jour avec succès'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Erreur mise à jour: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur lors de la mise à jour'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return 'N/A';

    try {
      final dateString = dateValue.toString();
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}\n${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateValue.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste des Signalements',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Color(0xFF1E293B),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Rafraîchir',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Icon(Icons.autorenew, size: 16, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  'Auto',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des signalements...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Signalements',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Liste en temps réel des incidents signalés',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${_reports.length} signalements',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B82F6),
                            ),
                          ),
                          Text(
                            'Rafraîchissement auto (3s)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Statistiques rapides
                  _buildQuickStats(),
                  SizedBox(height: 32),

                  // Tableau des signalements
                  _buildReportsTable(),
                ],
              ),
            ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildQuickStat(
          'Nouveaux',
          _stats['pending']?.toString() ?? '0',
          Colors.orange,
        ),
        SizedBox(width: 16),
        _buildQuickStat(
          'En cours',
          _stats['in_progress']?.toString() ?? '0',
          Colors.blue,
        ),
        SizedBox(width: 16),
        _buildQuickStat(
          'Traités',
          _stats['resolved']?.toString() ?? '0',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsTable() {
    if (_reports.isEmpty) {
      return Container(
        padding: EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            SizedBox(height: 16),
            Text(
              'Aucun signalement pour le moment',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 16,
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
            ),
            Divider(height: 1),

            // Lignes des signalements
            ..._reports.map((report) => _buildReportRow(report)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildReportRow(Map<String, dynamic> report) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            _buildTableCell('#${report['id']}', flex: 1),
            _buildTableCell(report['category'] ?? 'Non spécifié', flex: 2),
            _buildTableCell(_formatDate(report['created_at']), flex: 2),
            Expanded(
              flex: 2,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  if (report['status'] == 'pending')
                    ElevatedButton(
                      onPressed: () =>
                          _updateReportStatus(report['id'], 'in_progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: Size(0, 36),
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                        minimumSize: Size(0, 36),
                        padding: EdgeInsets.symmetric(horizontal: 16),
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
                      minimumSize: Size(0, 36),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    child: Text('Voir détails', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(fontSize: 13, color: Colors.grey[800]),
      ),
    );
  }
}
