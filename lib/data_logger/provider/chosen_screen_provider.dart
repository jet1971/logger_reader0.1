import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenScreenProvider extends StateNotifier<String?> {
  ChosenScreenProvider() : super(null);

  void setChosenScreen(String? contentId) {
    state = contentId;
  //   print('state value == $state');
  }
}

// final chosenScreenProvider = StateNotifierProvider<ChosenScreenProvider, String?>((ref) {
//   return ChosenScreenProvider();
// });


final chosenScreenProvider = StateNotifierProvider<ChosenScreenNotifier, String>((ref) 
=> ChosenScreenNotifier());

class ChosenScreenNotifier extends StateNotifier<String> {
  ChosenScreenNotifier() : super('track_report');

  void setChosenScreen(String? id) {
    if (id != null) {
      state = id;
    }
  }
}
