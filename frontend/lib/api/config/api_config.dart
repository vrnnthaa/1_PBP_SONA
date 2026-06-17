class ApiConfig {
  static const String baseUrl =
      'https://1pbpsona-production.up.railway.app/api';

  static Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static String normalizeUrl(String url) {
    // Helper to ensure compatibility with local hosts, since using ngrok we just return the url as is
    return url;
  }
}
