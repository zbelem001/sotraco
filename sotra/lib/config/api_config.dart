class ApiConfig {
  // Configuration API Backend
  static const String baseUrl = 'http://localhost:3000/api';
  
  // Endpoints Auth
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authDemo = '/auth/demo';
  
  // Endpoints Lines
  static const String lines = '/lines';
  static String lineById(String id) => '/lines/$id';
  
  // Endpoints Stops
  static const String stops = '/stops';
  static String stopById(String id) => '/stops/$id';
  static const String stopsNearby = '/stops/nearby';
  
  // Endpoints Buses
  static const String buses = '/buses';
  static String busById(String id) => '/buses/$id';
  static const String busesNearby = '/buses/nearby';
  static String busLocation(String id) => '/buses/$id/location';
  
  // Endpoints Alerts
  static const String alerts = '/alerts';
  static String alertById(String id) => '/alerts/$id';
  static const String alertsNearby = '/alerts/nearby';
  static String alertVote(String id) => '/alerts/$id/vote';
  
  // Endpoints Users
  static const String userMe = '/users/me';
  static const String userLocation = '/users/me/location';
  static const String userTrips = '/users/me/trips';
  
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
  
  // Headers
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> headersWithAuth(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
}
