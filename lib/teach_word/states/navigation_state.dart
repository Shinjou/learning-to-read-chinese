// lib/teach_word/states/navigation_state.dart

// Navigation state management
class NavigationState {
  final int currentTab;
  final bool canNavigateNext;
  final bool canNavigatePrev;

  const NavigationState({
    this.currentTab = 0,
    this.canNavigateNext = true,
    this.canNavigatePrev = false,
  });

  NavigationState copyWith({
    int? currentTab,
    bool? canNavigateNext,
    bool? canNavigatePrev,
  }) {
    return NavigationState(
      currentTab: currentTab ?? this.currentTab,
      canNavigateNext: canNavigateNext ?? this.canNavigateNext,
      canNavigatePrev: canNavigatePrev ?? this.canNavigatePrev,
    );
  }
}
