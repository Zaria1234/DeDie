import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';
import 'dart:math';
import 'confirmation_screen.dart';

class ReportScreen extends StatefulWidget {
  final String selectedCategory;
  final Color categoryColor;

  const ReportScreen({
    Key? key,
    required this.selectedCategory,
    required this.categoryColor,
  }) : super(key: key);

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _userId;
  String? _selectedZone;
  bool _isSubmitting = false;
  bool _autoTranslation = false;
  bool _hasPhoto = false;

  // Couleurs adaptées au design sombre
  final Color _backgroundColor = Color(0xFF0A1A3A);
  final Color _cardColor = Color(0xFF1A2B4A);
  final Color _textColor = Colors.white;
  final Color _subtextColor = Color(0xFF94A3B8);

  // Zones comme sur la maquette
  final List<Map<String, dynamic>> _zones = [
    {'name': 'Piste / Taxiway', 'icon': Icons.flight_takeoff},
    {'name': 'Terminal', 'icon': Icons.account_balance},
    {'name': 'Hall Arrivée', 'icon': Icons.directions_walk},
    {'name': 'Hall Départ', 'icon': Icons.flight_takeoff_outlined},
    {'name': 'Parking', 'icon': Icons.local_parking},
    {'name': 'Zone fret', 'icon': Icons.local_shipping},
    {'name': 'Zone maintenance', 'icon': Icons.build},
    {'name': 'Autre', 'icon': Icons.more_horiz},
  ];

  @override
  void initState() {
    super.initState();
    _generateUserId();
    _descriptionController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {});
  }

  Future<void> _generateUserId() async {
    try {
      final response = await http.post(Uri.parse(ApiConfig.generateUserId));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userId = data['userId'];
        });
      } else {
        print('Erreur génération ID: ${response.statusCode}');
        _generateLocalUserId();
      }
    } catch (e) {
      print('Erreur génération ID: $e');
      _generateLocalUserId();
    }
  }

  void _generateLocalUserId() {
    final localId =
        'USER_${DateTime.now().millisecondsSinceEpoch}${_generateRandomString(6)}';
    setState(() {
      _userId = localId;
    });
  }

  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showError('Veuillez corriger les erreurs dans le formulaire');
      return;
    }

    if (_selectedZone == null) {
      _showError('Sélectionnez une zone concernée');
      return;
    }

    setState(() => _isSubmitting = true);

    final report = {
      'userId': _userId,
      'category': widget.selectedCategory,
      'description': _descriptionController.text,
      'location': _selectedZone,
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
          // CORRECTION ICI : Gérer le cas où reportId pourrait être un int
          final reportId = responseData['reportId'];
          _navigateToConfirmation(reportId);
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

  String _getPriorityLevel() {
    // Simulation IA simple : basée sur la longueur et mots-clés
    final text = _descriptionController.text.toLowerCase();
    if (text.contains('urgence') ||
        text.contains('dangereux') ||
        text.contains('immédiat')) {
      return 'Haute';
    } else if (text.length > 50 || text.contains('risque')) {
      return 'Moyenne';
    }
    return 'Basse';
  }

  void _navigateToConfirmation(dynamic reportId) {
    // CORRECTION CRITIQUE : Convertir en string peu importe le type
    String reportIdString;

    if (reportId is String) {
      reportIdString = reportId;
    } else if (reportId is int) {
      // Si le backend retourne un int, le formatter
      reportIdString = 'SR-2025-${reportId.toString().padLeft(3, '0')}';
    } else {
      // Fallback pour la sécurité
      reportIdString =
          'SR-${DateTime.now().year}-${_generateRandomString(3).toUpperCase()}';
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ConfirmationScreen(
          reportId: reportIdString,
          category: widget.selectedCategory,
          zone: _selectedZone ?? 'Non spécifiée',
          priority: _getPriorityLevel(),
          userId: _userId ?? 'ID inconnu',
        ),
      ),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _selectedZone = null;
      _hasPhoto = false;
    });
    _descriptionController.clear();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête CATÉGORIE comme maquette
                _buildCategoryHeader(),
                SizedBox(height: 24),

                // Suggestion IA comme maquette
                _buildIASuggestion(),
                SizedBox(height: 24),

                // Description
                _buildDescriptionField(),
                SizedBox(height: 24),

                // Sélection de zone
                _buildZoneSection(),
                SizedBox(height: 24),

                // Photo/Video optionnel
                _buildPhotoSection(),
                SizedBox(height: 32),

                // Bouton d'envoi
                _buildSubmitButton(),
                SizedBox(height: 20),
              ],
            ),
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
        Text(
          widget.selectedCategory,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _textColor,
          ),
        ),
        Container(
          height: 3,
          width: 60,
          color: widget.categoryColor,
          margin: EdgeInsets.only(top: 8),
        ),
      ],
    );
  }

  Widget _buildIASuggestion() {
    final priority = _getPriorityLevel();
    final priorityColor = priority == 'Haute'
        ? Colors.red
        : priority == 'Moyenne'
        ? Colors.orange
        : Colors.green;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.categoryColor.withOpacity(0.3)),
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
                        text: widget.selectedCategory,
                        style: TextStyle(
                          color: widget.categoryColor,
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

  Widget _buildDescriptionField() {
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
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFF2A3B5A)),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 4,
            style: TextStyle(fontSize: 15, color: _textColor),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Ex: Lampe cassée près du gate 3',
              hintStyle: TextStyle(color: _subtextColor),
              counterText: '',
            ),
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
      ],
    );
  }

  Widget _buildZoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Où ?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _zones.map((zone) {
            final isSelected = _selectedZone == zone['name'];
            return ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    zone['icon'] as IconData,
                    size: 18,
                    color: isSelected ? Colors.white : _subtextColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    zone['name'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected ? Colors.white : _subtextColor,
                    ),
                  ),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedZone = selected ? zone['name'] as String : null;
                });
              },
              backgroundColor: _cardColor,
              selectedColor: widget.categoryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? widget.categoryColor : Color(0xFF2A3B5A),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photo / Vidéo (Optionnel)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _hasPhoto = !_hasPhoto;
            });
          },
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hasPhoto ? Color(0xFF4A90E2) : Color(0xFF2A3B5A),
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _hasPhoto ? Icons.check_circle : Icons.add_a_photo,
                  size: 40,
                  color: _hasPhoto ? Color(0xFF4A90E2) : _subtextColor,
                ),
                SizedBox(height: 8),
                Text(
                  _hasPhoto ? 'Photo ajoutée' : 'Ajouter une photo',
                  style: TextStyle(
                    color: _hasPhoto ? Color(0xFF4A90E2) : _subtextColor,
                    fontSize: 16,
                  ),
                ),
              ],
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
        onPressed: _isSubmitting ? null : _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFEF1111), // Rouge comme maquette
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
}
