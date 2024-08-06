class Config {
  static const bool isProduction = false;

  static const String productionBaseUrl = 'http://43.136.14.179:5001';
  static const String developmentBaseUrl = 'http://10.0.2.2:5001';

  static String get baseUrl {
    return isProduction ? productionBaseUrl : developmentBaseUrl;
  }
}
