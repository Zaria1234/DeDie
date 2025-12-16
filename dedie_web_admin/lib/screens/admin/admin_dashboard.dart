import 'package:flutter/material.dart';
import 'admin_list_reports.dart';
// import 'admin_report_detail.dart';

class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'ĐeDie Admin - ANAC',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
      ),
      body: Row(
        children: [
          // SIDEBAR
          _buildSidebar(context),

          // CONTENU PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre
                  Text(
                    'Tableau de Bord Temps Réel',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Vue synthétique des signalements et indicateurs clés',
                    style: TextStyle(fontSize: 16, color: Color(0xFF64748B)),
                  ),
                  SizedBox(height: 32),

                  // 4 CARTES STATISTIQUES
                  _buildStatsCards(),
                  SizedBox(height: 32),

                  // ALERTES AUTOMATIQUES
                  _buildAlertsSection(context), // Passer context
                  SizedBox(height: 32),

                  // SECTION CULTURE (optionnelle)
                  _buildCultureSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 280,
      color: Color(0xFF1E293B),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40),

          // Menu items
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            label: 'Tableau de Bord',
            isSelected: true,
            onTap: () {},
          ),

          _buildMenuItem(
            context,
            icon: Icons.notifications,
            label: 'Alertes',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminReportsList()),
              );
            },
          ),

          _buildMenuItem(
            context,
            icon: Icons.report_problem,
            label: 'Signalements',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AdminReportsList()),
              );
            },
          ),

          Spacer(),

          // Déconnexion
          Padding(
            padding: EdgeInsets.all(24),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              icon: Icon(Icons.logout, size: 18),
              label: Text('Déconnexion'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFEF4444),
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF334155) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(label, style: TextStyle(color: Colors.white)),
        trailing: isSelected
            ? Icon(Icons.chevron_right, color: Colors.white)
            : null,
        onTap: onTap,
        dense: true,
      ),
    );
  }

  Widget _buildStatsCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'Signalements Aujourd\'hui',
          value: '47',
          subtitle: 'Semaine: 312 | Mois: 1,284',
          trend: '+12%',
          color: Color(0xFF3B82F6),
          icon: Icons.trending_up,
        ),
        _buildStatCard(
          title: 'Taux Critiques',
          value: '8.5%',
          subtitle: '3 signalements critiques actifs',
          trend: 'Critique',
          color: Color(0xFFEF4444),
          icon: Icons.warning,
        ),
        _buildStatCard(
          title: 'Temps Moyen Traitement',
          value: '4.2h',
          subtitle: 'Objectif: < 6h',
          trend: '+15%',
          color: Color(0xFF10B981),
          icon: Icons.timer,
        ),
        _buildStatCard(
          title: 'Taux de Résolution',
          value: '92.3%',
          subtitle: '1,184 résolus ce mois',
          trend: '+5%',
          color: Color(0xFF8B5CF6),
          icon: Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required String trend,
    required Color color,
    required IconData icon,
  }) {
    final bool isPositive = trend.contains('+');

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                trend,
                style: TextStyle(
                  color: trend == 'Critique'
                      ? Color(0xFFEF4444)
                      : isPositive
                      ? Color(0xFF10B981)
                      : Color(0xFFEF4444),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context) {
    // Ajouter BuildContext comme paramètre
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alertes Automatiques Actives',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFFECACA)),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Accumulation Zone A - Piste 09',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDC2626),
                ),
              ),
              SizedBox(height: 8),
              Text(
                '5 signalements en 2h - Mots-clés: "débris", "FOD", "danger"',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text(
                    'il y a 15 min',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  SizedBox(width: 20),
                  Icon(Icons.location_on, size: 16, color: Color(0xFF64748B)),
                  SizedBox(width: 6),
                  Text(
                    'Zone A',
                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context, // Maintenant context est disponible
                        MaterialPageRoute(builder: (_) => AdminReportsList()),
                      );
                    },
                    icon: Icon(Icons.visibility, size: 16),
                    label: Text('Traiter'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFEF4444),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCultureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CULTURE',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFFF0F9FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFBAE6FD)),
          ),
          child: Row(
            children: [
              Icon(Icons.flag, size: 40, color: Color(0xFF0369A1)),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Culture de Sécurité Active',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0369A1),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '12 signalements positifs ce mois concernant des améliorations de procédures',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
