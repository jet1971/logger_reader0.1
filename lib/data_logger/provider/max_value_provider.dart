import 'package:flutter_riverpod/flutter_riverpod.dart';

// Class to hold both maxSpeed and maxRpm
class MaxValues {
  final double maxSpeed;
  final int maxRpm;

  MaxValues({required this.maxSpeed, required this.maxRpm});

  // Create a copy of the current MaxValues with updated maxSpeed or maxRpm
  MaxValues copyWith({double? maxSpeed, int? maxRpm}) {
    return MaxValues(
      maxSpeed: maxSpeed ?? this.maxSpeed,
      maxRpm: maxRpm ?? this.maxRpm,
    );
  }
}

class MaxValueProvider extends StateNotifier<MaxValues> {
  MaxValueProvider() : super(MaxValues(maxSpeed: 0, maxRpm: 0));

  // Update the maxSpeed
  void setMaxSpeedValue(double value) {
    state = state.copyWith(maxSpeed: value);
  }

  // Update the maxRpm
  void setMaxRpmValue(int value) {
    state = state.copyWith(maxRpm: value);
  }
}

// Create the provider for MaxValueProvider
final maxValueProvider =
    StateNotifierProvider<MaxValueProvider, MaxValues>((ref) {
  return MaxValueProvider();
});
