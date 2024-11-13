// lib/teach_word/providers/providers.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/teach_word/states/navigation_state.dart';

final contextProvider = Provider<BuildContext>((ref) {
  throw UnimplementedError('Context provider must be overridden at the widget level');
});


final navigationStateProvider = StateProvider<NavigationState>((ref) {
  return const NavigationState(
    currentTab: 0,
    canNavigateNext: false,
    canNavigatePrev: false,
  );
});
