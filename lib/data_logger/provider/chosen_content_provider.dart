import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChosenContentProvider extends StateNotifier<String?> {
  ChosenContentProvider() : super(null);

  void setChosenContent(String? contentId) {
    state = contentId;
  //   print('state value == $state');
  }
}

final chosenContentProvider =
    StateNotifierProvider<ChosenContentProvider, String?>((ref) {
  return ChosenContentProvider();
});
