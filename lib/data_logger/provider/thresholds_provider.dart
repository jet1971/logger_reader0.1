// thresholds_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ble1/data_logger/log_viewer/widgets/gps_plot/categories.dart';
//import 'thresholds.dart';

class ThresholdsState {
  final Map<DataCategory, Thresholds> values;
  const ThresholdsState(this.values);

  Thresholds forCategory(DataCategory c) => values[c] ?? kDefaultThresholds[c]!;
}

class ThresholdsNotifier extends StateNotifier<ThresholdsState> {
  static const _prefsKey = 'thresholds.v1';

  ThresholdsNotifier() : super(const ThresholdsState(kDefaultThresholds)) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) return;

    final Map<String, dynamic> map = json.decode(jsonStr);
    final merged = Map<DataCategory, Thresholds>.from(kDefaultThresholds);
    for (final entry in map.entries) {
      final cat = DataCategory.values.firstWhere(
        (c) => c.key == entry.key,
        orElse: () => DataCategory.speed, // safe default
      );
      merged[cat] = Thresholds.fromJson(Map<String, dynamic>.from(entry.value));
    }
    state = ThresholdsState(merged);
  }

  Future<void> setForCategory(DataCategory cat, Thresholds thresholds) async {
    final newMap = Map<DataCategory, Thresholds>.from(state.values)
      ..[cat] = thresholds;
    state = ThresholdsState(newMap);

    final prefs = await SharedPreferences.getInstance();
    final toSave = {
      for (final e in newMap.entries) e.key.key: e.value.toJson(),
    };
    await prefs.setString(_prefsKey, json.encode(toSave));
  }

  Thresholds forCategory(DataCategory c) => state.forCategory(c);
}

final thresholdsProvider =
    StateNotifierProvider<ThresholdsNotifier, ThresholdsState>(
        (ref) => ThresholdsNotifier());
