import 'package:flutter_riverpod/flutter_riverpod.dart';

class IndexProvider extends StateNotifier<int> {
  IndexProvider() : super(0);

  void setIndex(int index) {
    state = index;
    // print('state value == $state');
  }
}

final indexProvider =
    StateNotifierProvider<IndexProvider, int>((ref) {
  return IndexProvider();
});
