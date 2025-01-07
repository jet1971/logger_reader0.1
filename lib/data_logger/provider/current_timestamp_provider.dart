import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentTimestampProvider extends StateNotifier<int?> {
CurrentTimestampProvider() : super(null);

  void setScreenPositionTimeStamp(int? timestamp) {
     state = timestamp;
    // print('state value == $state');
  }
}

final currentTimeStampProvider =
    StateNotifierProvider<CurrentTimestampProvider, int?>((ref) {
  return CurrentTimestampProvider();
});
