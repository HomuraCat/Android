class Config {
  static const bool isProduction = true;

  static const String productionBaseUrl = 'http://43.136.52.103:5001';
  static const String developmentBaseUrl = 'http://10.0.2.2:5001';

  static String get baseUrl {
    return isProduction ? productionBaseUrl : developmentBaseUrl;
  }
}
