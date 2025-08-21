import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenScreenProvider extends StateNotifier<String?> {
  ChosenScreenProvider() : super(null);

  void setChosenScreen(String? contentId) {
    state = contentId;
  //   print('state value == $state');
  }
}

final chosenScreenProvider =
    StateNotifierProvider<ChosenScreenProvider, String?>((ref) {
  return ChosenScreenProvider();
});
