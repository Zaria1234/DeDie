import 'package:flutter/material.dart';
import 'report_screen.dart'; // L'écran de formulaire existant

class CategoryScreen extends StatelessWidget {
  // Liste des catégories comme sur la maquette
  final List<Map<String, dynamic>> categories = [
    {
      'title': 'Opérations',
      'icon': Icons.flight_takeoff,
      'color': Color(0xFF4A90E2),
      'description': 'Activités quotidiennes de l\'aéroport',
    },
    {
      'title': 'Passagers',
      'icon': Icons.people,
      'color': Color(0xFF50C878),
      'description': 'Expérience et service client',
    },
    {
      'title': 'Ressources',
      'icon': Icons.business_center,
      'color': Color(0xFFFFB74D),
      'description': 'Matériel et équipements',
    },
    {
      'title': 'Maintenance',
      'icon': Icons.build,
      'color': Color(0xFF9575CD),
      'description': 'Entretien et réparations',
    },
    {
      'title': 'Procédures',
      'icon': Icons.description,
      'color': Color(0xFFF06292),
      'description': 'Processus et protocoles',
    },
    {
      'title': 'Environnement',
      'icon': Icons.eco,
      'color': Color(0xFF4DB6AC),
      'description': 'Impact écologique et sécurité environnementale',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1A3A), // Fond sombre cohérent
      appBar: AppBar(
        title: Text(
          'ĐeDie',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1A2B4A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),

              // Titre principal
              Text(
                'Quel type de problème ?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 8),

              // Sous-titre avec indication IA
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                  children: [
                    TextSpan(text: 'L'),
                    WidgetSpan(
                      child: Transform.translate(
                        offset: const Offset(0, -2),
                        child: Icon(
                          Icons.psychology_outlined,
                          size: 18,
                          color: Color(0xFF4A90E2),
                        ),
                      ),
                    ),
                    TextSpan(
                      text: ' vous aidera à catégoriser automatiquement',
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Grille des catégories (2 colonnes)
              GridView.builder(
                shrinkWrap: true,
                physics:
                    NeverScrollableScrollPhysics(), // Pour le scroll dans SingleChildScrollView
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.0, // Carrés
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _CategoryCard(
                    title: category['title'] as String,
                    icon: category['icon'] as IconData,
                    color: category['color'] as Color,
                    description: category['description'] as String,
                    onTap: () {
                      // Naviguer vers ReportScreen avec la catégorie sélectionnée
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportScreen(
                            selectedCategory: category['title'] as String,
                            categoryColor: category['color'] as Color,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 40),

              // Note sur l'analyse IA
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A2B4A).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF4A90E2).withOpacity(0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.psychology_outlined,
                      color: Color(0xFF4A90E2),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Analyse IA en temps réel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Dès que vous commencerez à décrire l\'incident, '
                            'notre IA suggérera la catégorie et la priorité la plus adaptée.',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Bouton "Je ne sais pas"
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // Si l'utilisateur ne sait pas, on passe directement au formulaire
                    // L'IA déterminera automatiquement la catégorie
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(
                          selectedCategory: 'À déterminer',
                          categoryColor: Colors.grey,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.help_outline, color: Colors.grey[400]),
                  label: Text(
                    'Je ne suis pas sûr·e, l\'IA peut déterminer',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget pour chaque carte de catégorie
class _CategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF1A2B4A),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle avec icône
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5), width: 2),
                ),
                child: Icon(icon, size: 30, color: color),
              ),

              SizedBox(height: 12),

              // Titre de la catégorie
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 6),

              // Description (plus petite)
              Text(
                description,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[400],
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8),

              // Indicateur de sélection discret
              Container(
                width: 24,
                height: 2,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
