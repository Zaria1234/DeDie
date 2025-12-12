import 'package:flutter/material.dart';
import 'report_screen.dart';
import 'user_history.dart';

class Profil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "ĐeDie",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 239, 17, 17),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Bienvenue sur ĐeDie",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: const Color.fromARGB(255, 239, 17, 17),
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Plateforme de signalement aéronautique",
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 50),
          // Bouton avec effet de "scintillement" (pulsation)
          _PulsingButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReportScreen()),
              );
            },
            child: Text(
              "Signaler un incident",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Signalez anonymement tout incident de sécurité pour contribuer à l'amélioration continue",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "profil"),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: "historique",
          ),
        ],
        currentIndex: 0, // L'onglet actif
        onTap: (index) {
          if (index == 1) {
            // Naviguer vers l'écran historique
            // Tu devras créer UserHistoryScreen() plus tard
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UserHistoryScreen()),
            );
          }
        },
      ),
    );
  }
}

// Widget personnalisé pour le bouton avec effet de pulsation
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
            width: 250,
            height: 250,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 239, 17, 17),
                shape: CircleBorder(),
                padding: EdgeInsets.all(30),
                elevation: 10,
                shadowColor: const Color.fromARGB(
                  255,
                  239,
                  17,
                  17,
                ).withOpacity(0.5),
              ),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
