class AppConfig {
  AppConfig._internal();

  static final AppConfig instance = AppConfig._internal();

  static const String version = '1.0.0';
  String _currentYear = '';

  String get year => _currentYear;

  void changeYear(String newYear) {
    _currentYear = newYear;
  }
}
