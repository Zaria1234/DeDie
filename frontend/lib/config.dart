class ApiConfig {
  // Pour émulateur Android
  static const String baseUrl = 'http://10.0.2.2:3000';

  // Pour émulateur iOS
  // static const String baseUrl = 'http://localhost:3000';

  // Pour téléphone physique (remplace X.X par ton IP locale)
  // static const String baseUrl = 'http://192.168.X.X:3000';

  // Endpoints
  static String generateUserId = '$baseUrl/api/generate-user-id';
  static String submitReport = '$baseUrl/api/report';
  static String adminLogin = '$baseUrl/api/admin/login';
  static String adminReports = '$baseUrl/api/admin/reports';
  static String adminDashboardStats = '$baseUrl/api/admin/dashboard-stats';
  static String userReports(String userId) =>
      '$baseUrl/api/user/reports/$userId';
}
