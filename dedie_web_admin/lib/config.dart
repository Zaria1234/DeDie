class ApiConfig {
  // POUR NAVIGATEUR WEB (Chrome, Firefox, etc.)
  static const String baseUrl = 'http://localhost:3000';

  // POUR DÉPLOIEMENT EN LIGNE (exemple)
  // static const String baseUrl = 'https://api.dedie.tg';

  // Endpoints ADMINISTRATEUR uniquement
  static String get adminLogin => '$baseUrl/api/admin/login';
  static String get adminReports => '$baseUrl/api/admin/reports';
  static String get adminDashboardStats => '$baseUrl/api/admin/dashboard-stats';
  static String updateReportStatus(int reportId) =>
      '$baseUrl/api/admin/reports/$reportId';

  // Pour voir un signalement spécifique
  static String getReportDetails(int reportId) =>
      '$baseUrl/api/admin/reports/$reportId';
}
