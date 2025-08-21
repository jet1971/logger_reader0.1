import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenDataProvider extends StateNotifier<String?> {
  ChosenDataProvider() : super(null);

  void setChosenData(String? chosenData) {
    state = chosenData;
    //   print('state value == $state');
  }
}

final chosenDataProvider =
    StateNotifierProvider<ChosenDataProvider, String?>((ref) {
  return ChosenDataProvider();
});
