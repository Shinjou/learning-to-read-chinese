// lib/teach_word/states/navigation_state.dart

class NavigationState {
  final int currentTabIndex;
  final bool canNavigateNext;
  final bool canNavigatePrevious;

  const NavigationState({
    this.currentTabIndex = 0,
    this.canNavigateNext = true,
    this.canNavigatePrevious = true,
  });

  NavigationState copyWith({
    int? currentTabIndex,
    bool? canNavigateNext,
    bool? canNavigatePrevious,
  }) {
    return NavigationState(
      currentTabIndex: currentTabIndex ?? this.currentTabIndex,
      canNavigateNext: canNavigateNext ?? this.canNavigateNext,
      canNavigatePrevious: canNavigatePrevious ?? this.canNavigatePrevious,
    );
  }
}
