class EnvironmentConfig {
  /// To run application with prod server, use
  /// flutter run --dart-define=isProductionEnvironment=true
  /// otherwise staging server is selected by default.
  static const bool isProductionEnvironment = bool.fromEnvironment(
    'isProductionEnvironment',
    defaultValue: false,
  );

  static const String thirdPartyID = String.fromEnvironment(
    'thirdPartyID',
    defaultValue: "5d730376-72ed-478c-8d5e-1a3a6aee9815",
  );
}
