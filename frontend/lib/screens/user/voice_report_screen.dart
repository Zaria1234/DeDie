import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

class VoiceReportScreen extends StatefulWidget {
  final String? initialCategory;

  const VoiceReportScreen({Key? key, this.initialCategory}) : super(key: key);

  @override
  _VoiceReportScreenState createState() => _VoiceReportScreenState();
}

class _VoiceReportScreenState extends State<VoiceReportScreen> {
  // Variables d'enregistrement
  Timer? _recordingTimer;
  int _recordingSeconds = 0;
  bool _isRecording = false;
  bool _autoTranslation = false;
  String _transcribedText = '';
  bool _isSubmitting = false;

  // Variables pour la catégorie
  String _selectedCategory = 'Opérations';
  Color _categoryColor = Color(0xFF4A90E2);
  List<String> _categories = [
    'Opérations',
    'Passagers',
    'Ressources',
    'Maintenance',
    'Procédures',
    'Environnement',
  ];

  // Variables d'état
  final TextEditingController _textController = TextEditingController();
  final Color _backgroundColor = Color(0xFF0A1A3A);
  final Color _cardColor = Color(0xFF1A2B4A);
  final Color _textColor = Colors.white;
  final Color _subtextColor = Color(0xFF94A3B8);

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      _selectedCategory = widget.initialCategory!;
      _updateCategoryColor();
    }
  }

  @override
  void dispose() {
    _stopRecording();
    _recordingTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _updateCategoryColor() {
    final colors = {
      'Opérations': Color(0xFF4A90E2),
      'Passagers': Color(0xFF50C878),
      'Ressources': Color(0xFFFFB74D),
      'Maintenance': Color(0xFF9575CD),
      'Procédures': Color(0xFFF06292),
      'Environnement': Color(0xFF4DB6AC),
    };
    _categoryColor = colors[_selectedCategory] ?? Color(0xFF4A90E2);
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _recordingSeconds = 0;
    });

    // Simulation d'enregistrement - dans la réalité, utiliseriez un plugin d'enregistrement audio
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds++;
      });

      // Simulation : après 10 secondes, on simule une transcription
      if (_recordingSeconds == 10) {
        _simulateTranscription();
      }
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    if (_isRecording) {
      setState(() {
        _isRecording = false;
      });

      // Si pas encore transcrit, simuler la transcription
      if (_transcribedText.isEmpty && _recordingSeconds > 2) {
        _simulateTranscription();
      }
    }
  }

  void _simulateTranscription() {
    // Simulation de transcription IA
    setState(() {
      _transcribedText =
          "Lampe cassée près de la sortie d'urgence du terminal 2. "
          "La lumière clignote de manière intermittente, cela pourrait gêner "
          "l'évacuation en cas d'urgence.";
      _textController.text = _transcribedText;
    });
  }

  String _getFormattedTime() {
    int minutes = _recordingSeconds ~/ 60;
    int seconds = _recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String _getPriorityLevel() {
    // Simulation IA simple basée sur le texte
    final text = _textController.text.toLowerCase();
    if (text.contains('urgence') ||
        text.contains('dangereux') ||
        text.contains('incendie') ||
        text.contains('blessé')) {
      return 'Haute';
    } else if (text.contains('risque') ||
        text.contains('problème') ||
        text.length > 30) {
      return 'Moyenne';
    }
    return 'Basse';
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    if (_textController.text.isEmpty) {
      _showError('Veuillez décrire l\'incident');
      return;
    }

    setState(() => _isSubmitting = true);

    final report = {
      'userId': 'VOICE_${DateTime.now().millisecondsSinceEpoch}',
      'category': _selectedCategory,
      'description': _textController.text,
      'isVoiceReport': true,
      'recordingDuration': _recordingSeconds,
      'autoTranslation': _autoTranslation,
      'priority': _getPriorityLevel(),
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.submitReport),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(report),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          // Naviguer vers l'écran de confirmation
          Navigator.pushReplacementNamed(
            context,
            '/confirmation',
            arguments: {
              'reportId': responseData['reportId'],
              'category': _selectedCategory,
              'isVoiceReport': true,
              'priority': _getPriorityLevel(),
            },
          );
        } else {
          _showError('Erreur: ${responseData['message']}');
        }
      } else {
        _showError('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      print('Erreur de connexion: $e');
      _showError(
        'Impossible de se connecter au serveur. Vérifiez votre connexion.',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, size: 20, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final priority = _getPriorityLevel();
    final priorityColor = priority == 'Haute'
        ? Colors.red
        : priority == 'Moyenne'
        ? Colors.orange
        : Colors.green;

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(
          "ĐeDie",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        backgroundColor: _cardColor,
        elevation: 0,
        iconTheme: IconThemeData(color: _textColor),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            if (!_isSubmitting) Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête CATÉGORIE
              _buildCategoryHeader(),
              SizedBox(height: 24),

              // Suggestion IA
              _buildIASuggestion(priority, priorityColor),
              SizedBox(height: 24),

              // Enregistrement vocal
              _buildRecordingSection(),
              SizedBox(height: 24),

              // Transcription
              _buildTranscriptionSection(),
              SizedBox(height: 24),

              // Bouton d'envoi
              _buildSubmitButton(),
              SizedBox(height: 20),

              // Note SMS
              _buildSMSNote(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CATÉGORIE',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _subtextColor,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),

        // Sélecteur de catégorie
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _categoryColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedCategory,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(Icons.arrow_drop_down, color: _categoryColor),
                onSelected: (value) {
                  setState(() {
                    _selectedCategory = value;
                    _updateCategoryColor();
                  });
                },
                itemBuilder: (context) {
                  return _categories.map((category) {
                    return PopupMenuItem<String>(
                      value: category,
                      child: Text(
                        category,
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: _selectedCategory == category
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList();
                },
              ),
            ],
          ),
        ),
        Container(
          height: 3,
          width: 60,
          color: _categoryColor,
          margin: EdgeInsets.only(top: 8),
        ),
      ],
    );
  }

  Widget _buildIASuggestion(String priority, Color priorityColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _categoryColor.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology_outlined, color: Color(0xFF4A90E2), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Suggestion IA',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text.rich(
                  TextSpan(
                    text: 'Catégorie: ',
                    style: TextStyle(color: _subtextColor),
                    children: [
                      TextSpan(
                        text: _selectedCategory,
                        style: TextStyle(
                          color: _categoryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: ' • Priorité: ',
                        style: TextStyle(color: _subtextColor),
                      ),
                      TextSpan(
                        text: priority,
                        style: TextStyle(
                          color: priorityColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingSection() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF2A3B5A)),
      ),
      child: Column(
        children: [
          // Indicateur de temps
          Text(
            _getFormattedTime(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: _isRecording ? Color(0xFFEF1111) : _textColor,
              fontFamily: 'Monospace',
            ),
          ),
          SizedBox(height: 8),
          Text(
            _isRecording
                ? 'Enregistrement en cours...'
                : 'Enregistrement arrêté',
            style: TextStyle(color: _subtextColor, fontSize: 14),
          ),
          SizedBox(height: 24),

          // Bouton d'enregistrement
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _isRecording ? Color(0xFFEF1111) : Color(0xFF4A90E2),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (_isRecording ? Color(0xFFEF1111) : Color(0xFF4A90E2))
                      .withOpacity(0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                size: 40,
                color: Colors.white,
              ),
              onPressed: () {
                if (_isRecording) {
                  _stopRecording();
                } else {
                  _startRecording();
                }
              },
            ),
          ),
          SizedBox(height: 12),
          Text(
            _isRecording ? 'Arrêter' : 'Démarrer l\'enregistrement',
            style: TextStyle(color: _subtextColor, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Que s\'est-il passé ? (Optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        SizedBox(height: 12),

        // Champ de texte pour la transcription
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF2A3B5A)),
          ),
          child: TextFormField(
            controller: _textController,
            maxLines: 4,
            style: TextStyle(fontSize: 15, color: _textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText:
                  'La transcription apparaîtra ici après enregistrement...',
              hintStyle: TextStyle(color: _subtextColor),
              suffixIcon: _transcribedText.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.edit, color: Color(0xFF4A90E2)),
                      onPressed: () {
                        // Permettre l'édition manuelle
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {});
            },
          ),
        ),
        SizedBox(height: 12),

        // Toggle Traduction automatique
        Row(
          children: [
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: _autoTranslation,
                onChanged: (value) {
                  setState(() {
                    _autoTranslation = value;
                  });
                },
                activeColor: Color(0xFF4A90E2),
              ),
            ),
            SizedBox(width: 8),
            Text(
              'Traduction automatique activée',
              style: TextStyle(fontSize: 14, color: _subtextColor),
            ),
          ],
        ),

        // Bouton pour effacer
        if (_textController.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _textController.clear();
                    _transcribedText = '';
                  });
                },
                icon: Icon(Icons.delete_outline, size: 18, color: Colors.red),
                label: Text(
                  'Effacer la transcription',
                  style: TextStyle(fontSize: 13, color: Colors.red),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: (_textController.text.isEmpty || _isSubmitting)
            ? null
            : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEF1111),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: Color(0xFFEF1111).withOpacity(0.4),
        ),
        child: _isSubmitting
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'ENVOYER LE SIGNALEMENT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
      ),
    );
  }

  Widget _buildSMSNote() {
    return Container(
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
            child: Text(
              'Alerte SMS envoyée aux responsables',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
