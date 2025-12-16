class ApiConfig {
  // POUR ÉMULATEUR ANDROID
  static const String baseUrl = 'http://10.0.2.2:3000';

  // POUR ÉMULATEUR iOS (décommente si besoin)
  // static const String baseUrl = 'http://localhost:3000';

  // POUR TÉLÉPHONE PHYSIQUE (sur même WiFi)
  // static const String baseUrl = 'http://192.168.X.X:3000';

  // Endpoints UTILISATEURS uniquement
  static String get generateUserId => '$baseUrl/api/generate-user-id';
  static String get submitReport => '$baseUrl/api/report';
  static String userReports(String userId) =>
      '$baseUrl/api/user/reports/$userId';
}
