import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'user_history.dart';
import 'voice_report_screen.dart';

class Profil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0A1A3A),
      appBar: AppBar(
        title: Text(
          "ĐeDie",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF1A2B4A), // AppBar plus claire que fond
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),

              // Section "Anonymat total garanti"
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF1A2B4A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF2A3B5A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.green,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Anonymat total garanti",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Vos signalements sont totalement anonymes et sécurisés",
                      style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              // Message de bienvenue
              Text(
                "Bonjour.",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Un problème à signaler ?",
                style: TextStyle(fontSize: 18, color: Colors.grey[400]),
              ),

              SizedBox(height: 40),

              // BOUTON PRINCIPAL "SIGNALER"
              Center(
                child: _PulsingButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategoryScreen()),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "SIGNALER",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "un incident",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40),

              // Section RAPIDE / ANONYME / SÉCURISÉ
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _FeatureBadge(
                    icon: Icons.flash_on,
                    text: "RAPIDE",
                    color: Colors.blue,
                  ),
                  _FeatureBadge(
                    icon: Icons.device_unknown,
                    text: "ANONYME",
                    color: Colors.green,
                  ),
                  _FeatureBadge(
                    icon: Icons.lock,
                    text: "SÉCURISÉ",
                    color: Colors.orange,
                  ),
                ],
              ),

              SizedBox(height: 50),

              // Bouton Signalement vocal
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => VoiceReportScreen()),
                    );
                  },
                  icon: Icon(Icons.mic, color: Colors.white),
                  label: Text(
                    "Signalement vocal rapide",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(
                      0xFF4A90E2,
                    ), // Bleu pour différencier
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20),

              // Bouton Suivre mes signalements
              Container(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => UserHistoryScreen()),
                    );
                  },
                  icon: Icon(Icons.history, color: Color(0xFF4A90E2)),
                  label: Text(
                    "Suivre mes signalements",
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontWeight: FontWeight.bold,
                    ),
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

// Widget pour les badges de features
class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _FeatureBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

// Bouton pulsant adapté (gardé mais modifié)
class _PulsingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const _PulsingButton({required this.onPressed, required this.child});

  @override
  __PulsingButtonState createState() => __PulsingButtonState();
}

class __PulsingButtonState extends State<_PulsingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: 200,
            height: 200,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(
                  0xFFEF1111,
                ), // Rouge pour le bouton principal
                shape: CircleBorder(),
                padding: EdgeInsets.all(30),
                elevation: 15,
                shadowColor: Color(0xFFEF1111).withOpacity(0.5),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
