import 'package:flutter/material.dart';

class ConfirmationScreen extends StatelessWidget {
  final String reportId;
  final String category;
  final String zone;
  final String priority;
  final String userId;

  const ConfirmationScreen({
    Key? key,
    required this.reportId,
    required this.category,
    required this.zone,
    required this.priority,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = Color(0xFF0A1A3A);
    final Color cardColor = Color(0xFF1A2B4A);
    final Color textColor = Colors.white;
    final Color subtextColor = Color(0xFF94A3B8);
    final Color categoryColor = _getCategoryColor(category);
    final Color priorityColor = priority == 'Haute'
        ? Colors.red
        : priority == 'Moyenne'
        ? Colors.orange
        : Colors.green;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          "ĐeDie",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: cardColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Pas de bouton retour
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40),

              // Message principal
              Icon(Icons.check_circle, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Merci !',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Votre signalement anonyme a été transmis\naux équipes de sécurité.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subtextColor,
                  height: 1.5,
                ),
              ),

              SizedBox(height: 40),

              // Séparateur
              Container(
                height: 1,
                color: Color(0xFF2A3B5A),
                margin: EdgeInsets.symmetric(horizontal: 20),
              ),

              SizedBox(height: 40),

              // RÉFÉRENCE DU SIGNALEMENT
              Text(
                'RÉFÉRENCE DU SIGNALEMENT',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subtextColor,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 16),
              Text(
                reportId,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.0,
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF2A3B5A)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.smartphone, color: Color(0xFF4A90E2), size: 20),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Accessible depuis cet appareil via "Suivre mes signalements"',
                        style: TextStyle(fontSize: 14, color: subtextColor),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // RÉSUMÉ
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: categoryColor.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RÉSUMÉ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: subtextColor,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),

                    // Catégorie
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Container(
                      height: 3,
                      width: 60,
                      color: categoryColor,
                      margin: EdgeInsets.only(top: 8, bottom: 20),
                    ),

                    // Zone
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: subtextColor,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            zone,
                            style: TextStyle(fontSize: 16, color: textColor),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    // Priorité
                    Row(
                      children: [
                        Icon(
                          Icons.flag_outlined,
                          size: 20,
                          color: priorityColor,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Priorité: $priority',
                            style: TextStyle(
                              fontSize: 16,
                              color: priorityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Note SMS
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A2B4A).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sms_outlined, color: Colors.green, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alerte envoyée',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'SMS transmis au Safety Management System',
                            style: TextStyle(color: subtextColor, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Suivre mes signalements (à implémenter)
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Color(0xFF4A90E2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'SUIVRE MES SIGNALEMENTS',
                        style: TextStyle(
                          color: Color(0xFF4A90E2),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Retour à l'accueil
                        Navigator.popUntil(context, (route) => route.isFirst);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFEF1111),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'NOUVEAU SIGNALEMENT',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),

              // Note sur l'anonymat
              Text(
                'Votre identifiant anonyme: ${userId.substring(0, 12)}...',
                style: TextStyle(
                  fontSize: 12,
                  color: subtextColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final colors = {
      'Opérations': Color(0xFF4A90E2),
      'Passagers': Color(0xFF50C878),
      'Ressources': Color(0xFFFFB74D),
      'Maintenance': Color(0xFF9575CD),
      'Procédures': Color(0xFFF06292),
      'Environnement': Color(0xFF4DB6AC),
      'À déterminer': Colors.grey,
    };
    return colors[category] ?? Color(0xFF4A90E2);
  }
}
