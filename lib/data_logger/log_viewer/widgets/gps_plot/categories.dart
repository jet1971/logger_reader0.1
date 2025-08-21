enum DataCategory {
  speed,
  rpm,
  tps,
  coolantTemperature,
  afr,
  airTemperature,
  airboxPressure,
  oilPressure,
  batteryVoltage,
}


extension DataCategoryX on DataCategory {
  String get key => toString().split('.').last; // e.g. "speed"
}

// thresholds.dart
class Thresholds {
  final double low;
  final double medium;
  final double high;
  
  const Thresholds({required this.low, required this.medium, required this.high});

  Map<String, dynamic> toJson() => {'low': low, 'medium': medium, 'high': high};
  factory Thresholds.fromJson(Map<String, dynamic> j) => Thresholds(
      low: (j['low'] ?? 0).toDouble(),
      medium: (j['medium'] ?? 0).toDouble(),
      high: (j['high'] ?? 0).toDouble());
}

const Map<DataCategory, Thresholds> kDefaultThresholds = {
  DataCategory.speed: Thresholds(low: 20, medium: 70, high: 140),
  DataCategory.tps: Thresholds(low: 10, medium: 50, high: 95),
  DataCategory.coolantTemperature: Thresholds(low:20, medium: 50, high: 90),
  DataCategory.afr: Thresholds(low: 11.5, medium: 13.0, high: 14.5),
  DataCategory.airTemperature: Thresholds(low: 5, medium: 15, high: 30),
  DataCategory.airboxPressure: Thresholds(low: 0, medium: 1, high: 2),
  DataCategory.oilPressure: Thresholds(low: 0, medium: 40, high: 80),
  DataCategory.batteryVoltage: Thresholds(low: 10, medium: 12.5, high: 15.5),
};
