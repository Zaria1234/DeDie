import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String? _userId;
  String? _selectedIncidentType;
  String? _selectedZone;

  final Color _primaryColor = const Color.fromARGB(255, 239, 17, 17);
  final Color _lightBlue = Color.fromARGB(255, 235, 238, 255);

  final List<Map<String, dynamic>> _incidentTypes = [
    {
      'type': 'FOD',
      'label': 'Objet sur piste/plateforme',
      'icon': Icons.dangerous_outlined,
    },
    {
      'type': 'Equipement',
      'label': 'Équipement défaillant',
      'icon': Icons.build_outlined,
    },
    {
      'type': 'Comportement',
      'label': 'Comportement à risque',
      'icon': Icons.warning_outlined,
    },
    {
      'type': 'Autre',
      'label': 'Autre type d\'incident',
      'icon': Icons.more_horiz_outlined,
    },
  ];

  final List<String> _zones = [
    'Sélectionnez une zone',
    'Piste / Taxiway',
    'Terminal (Hall, Contrôle)',
    'Parking avions / Aire de trafic',
    'Zone fret / Maintenance',
    'Autre zone',
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
      final response = await http.post(
        // Uri.parse('http://localhost:3000/api/generate-user-id'),
        Uri.parse(ApiConfig.generateUserId),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _userId = data['userId'];
        });
      }
    } catch (e) {
      print('Erreur génération ID: $e');
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedIncidentType == null) {
      _showError('Sélectionnez un type d\'incident');
      return;
    }
    if (_selectedZone == null || _selectedZone == _zones[0]) {
      _showError('Sélectionnez une zone concernée');
      return;
    }

    final report = {
      'userId': _userId,
      'category': _selectedIncidentType,
      'description': _descriptionController.text,
      'location': _selectedZone,
    };

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.submitReport),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(report),
      );

      if (response.statusCode == 200) {
        _showSuccess();
        _formKey.currentState!.reset();
        setState(() {
          _selectedIncidentType = null;
          _selectedZone = _zones[0];
        });
        _descriptionController.clear();
      }
    } catch (e) {
      _showError('Erreur de connexion');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Signalement envoyé avec succès'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Nouveau Signalement",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: _primaryColor,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête
                _buildHeader(),
                SizedBox(height: 32),

                // ID Anonyme
                if (_userId != null) _buildUserIDCard(),
                SizedBox(height: 24),

                // 1. Type d'incident
                _buildSectionTitle('Type d\'incident'),
                SizedBox(height: 16),
                _buildIncidentTypeGrid(),
                SizedBox(height: 24),

                // 2. Zone concernée
                _buildSectionTitle('Zone concernée'),
                SizedBox(height: 12),
                _buildZoneDropdown(),
                SizedBox(height: 24),

                // 3. Description
                _buildSectionTitle('Description'),
                SizedBox(height: 12),
                _buildDescriptionField(),
                SizedBox(height: 32),

                // Bouton de soumission
                _buildSubmitButton(),
                SizedBox(height: 16),

                // Note
                _buildPrivacyNote(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signaler un incident',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _primaryColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Votre signalement est 100% anonyme et contribue à la sécurité aérienne.',
          style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.5),
        ),
      ],
    );
  }

  Widget _buildUserIDCard() {
    return Container(
      decoration: BoxDecoration(
        color: _lightBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _primaryColor.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.fingerprint_outlined, color: _primaryColor, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Votre identifiant anonyme',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _userId!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: -0.3,
      ),
    );
  }

  Widget _buildIncidentTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: _incidentTypes.length,
      itemBuilder: (context, index) {
        final type = _incidentTypes[index];
        bool isSelected = _selectedIncidentType == type['type'];

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedIncidentType = type['type'] as String;
            });
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? _primaryColor : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _primaryColor.withOpacity(0.2),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    type['icon'] as IconData,
                    size: 28,
                    color: isSelected ? Colors.white : _primaryColor,
                  ),
                  SizedBox(height: 12),
                  Text(
                    type['type'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    type['label'] as String,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneDropdown() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedZone ?? _zones[0],
        items: _zones.map((zone) {
          return DropdownMenuItem(
            value: zone,
            child: Text(
              zone,
              style: TextStyle(
                fontSize: 15,
                color: zone == _zones[0] ? Colors.grey[500] : Colors.black87,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedZone = value;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          filled: true,
          fillColor: Colors.transparent,
        ),
        style: TextStyle(fontSize: 15, color: Colors.black87),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: _primaryColor),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        validator: (value) {
          if (value == null || value == _zones[0]) return null;
          return null;
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            controller: _descriptionController,
            maxLines: 5,
            maxLength: 200,
            style: TextStyle(fontSize: 15, color: Colors.black87),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              hintText: 'Décrivez ce que vous avez observé...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              counterText: '',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              if (value.length < 10) {
                return 'Description trop courte (min. 10 caractères)';
              }
              return null;
            },
          ),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${_descriptionController.text.length}/200 caractères',
              style: TextStyle(
                fontSize: 12,
                color: _descriptionController.text.length > 200
                    ? Colors.red
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_descriptionController.text.length >= 10)
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Description valide',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: _primaryColor.withOpacity(0.3),
        ),
        child: Text(
          'Envoyer le signalement',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.security_outlined, size: 18, color: _primaryColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Votre anonymat est garanti. Aucune donnée personnelle n\'est collectée, et vous pouvez suivre l\'avancement de vos signalements avec votre identifiant unique.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
