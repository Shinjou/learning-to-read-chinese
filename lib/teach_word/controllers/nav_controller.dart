// lib/teach_word/controllers/nav_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/providers/navigation_provider.dart';

class NavigationController {
  final WidgetRef ref;
  
  NavigationController(this.ref);

  void navigateToTab(int index, {bool canNavigate = true}) {
    if (!canNavigate) return;
    
    ref.read(navigationControllerProvider.notifier).updateTab(index);
  }
  
  void navigateNext() {
    final currentTabIndex = ref.read(navigationControllerProvider).currentTabIndex;
    if (currentTabIndex < 3) { // Max 4 tabs (0-3)
      ref.read(navigationControllerProvider.notifier).updateTab(currentTabIndex + 1);
    }
  }

  void navigatePrevious() {
    final currentTabIndex = ref.read(navigationControllerProvider).currentTabIndex;
    if (currentTabIndex > 0) {
      ref.read(navigationControllerProvider.notifier).updateTab(currentTabIndex - 1);
    }
  }
}

