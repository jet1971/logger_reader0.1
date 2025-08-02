class LoggerSettings {
  LoggerSettings({
    required this.id,
    required this.daylightSaving,
    required this.rpmMultiplier,
  });

  late String id;
  late bool daylightSaving;
  late int rpmMultiplier;

  // Create a factory method to construct LoggerSettings from JSON
  factory LoggerSettings.fromJson(Map<String, dynamic> json) {
    return LoggerSettings(
      id: json['id'] ?? '000',
      daylightSaving: json['daylightSaving'] ?? false,
      rpmMultiplier: json['rpmMultiplier'] ?? 1,
    );
  }
}
