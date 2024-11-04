// lib/teach_word/providers/navigation_provider.dart


import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/states/navigation_state.dart';

final navigationControllerProvider = StateNotifierProvider<NavigationController, NavigationState>((ref) {
  return NavigationController();
});

class NavigationController extends StateNotifier<NavigationState> {
  NavigationController() : super(const NavigationState());

  void updateTab(int index, {bool canNavigateNext = true, bool canNavigatePrevious = true}) {
    state = state.copyWith(
      currentTabIndex: index,
      canNavigateNext: canNavigateNext,
      canNavigatePrevious: canNavigatePrevious,
    );
  }
}
