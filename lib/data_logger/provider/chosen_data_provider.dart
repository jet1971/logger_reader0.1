import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenDataProvider extends StateNotifier<String?> {
  ChosenDataProvider() : super(null);

  void setChosenData(String? chosenData) {
    state = chosenData;
       print('state value == $state');
  }
}


final chosenDataProvider = StateNotifierProvider<ChosenDataNotifier, String>(
    (ref) => ChosenDataNotifier());

class ChosenDataNotifier extends StateNotifier<String> {
  ChosenDataNotifier() : super('speed');

  void setChosenData(String? id) {
    if (id != null) {
      state = id;
    }
  }
}
