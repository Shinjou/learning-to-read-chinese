// File: test/teach_word/tab_navigation_test.dart

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_status_model.dart';
// import 'package:ltrc/teach_word/providers/teach_word_providers.dart';
import 'package:ltrc/teach_word/states/word_state.dart';  
import 'package:ltrc/teach_word/states/navigation_state.dart';  

// Define required enums if they're not accessible in test
enum QuizMode { none, writing, multiple }
enum StrokeMode { none, practice, animation }

// Define navigationStateProvider for testing
final navigationStateProvider = StateProvider<NavigationState>((ref) {
  return const NavigationState(
    currentTab: 0,
    canNavigateNext: false,
    canNavigatePrev: false,
  );
});

// Mock Classes
class MockWordState implements WordState {
  @override
  final bool isLearned;
  
  MockWordState({this.isLearned = false});
  
  String get word => 'test';

  @override
  String get currentWord => 'test';

  @override
  WordStatus get currentWordStatus => WordStatus(
    id: 1, 
    userAccount: 'tester',     
    word: '下',
    learned: isLearned,
    liked: false,
  );

  /* WordStatus class definition in package:ltrc/data/models/word_status_model.dart
  (new) WordStatus WordStatus({
    required int id,
    required String userAccount,
    required String word,
    required bool learned,
    required bool liked,
  })

  Claude 建議的 nextReviewDate: nextReviewDate: DateTime.now(), 非常好。下次放進去。
  */


  @override
  int get currentTabIndex => 0;

  // Implement the minimum required properties for the test
  @override
  bool get isQuizzing => false;

  /* quizMode and strokeMode are not defined
  @override
  QuizMode get quizMode => QuizMode.none;

  @override
  StrokeMode get strokeMode => StrokeMode.none;
  */

  // For unneeded properties in this test, return default values
  @override
  WordState copyWith({
    String? currentWord,
    int? unitId,
    String? unitTitle,
    String? fallbackWord,
    bool? isLearned,
    int? nextStepId,
    bool? isBpmf,
    bool? svgExists,
    int? practiceTimeLeft,
    int? currentTabIndex,
    bool? isQuizzing,
    bool? isAnimating,
    StrokeMode? strokeMode,
    QuizMode? quizMode,
    bool? showOutline,
    int? vocabCount,
    String? vocab1,
    String? vocab2,
    String? sentence1,
    String? sentence2,
    String? meaning1,
    String? meaning2,
    WordStatus? currentWordStatus,
    List<Map>? wordsPhrase,
    int? wordIndex,
    bool? img1Exists,
    bool? img2Exists,
    int? currentStroke,
    String? svgData,
  }) {
    return MockWordState(isLearned: isLearned ?? this.isLearned);
  }

  // Provide default implementations for remaining properties
  @override
  int get currentStroke => 0;
  @override
  String get fallbackWord => '';
  @override
  bool get img1Exists => false;
  @override
  bool get img2Exists => false;
  @override
  bool get isAnimating => false;
  @override
  bool get isBpmf => false;
  @override
  String get meaning1 => '';
  @override
  String get meaning2 => '';
  @override
  int get nextStepId => 0;
  @override
  int get practiceTimeLeft => 0;
  @override
  String get sentence1 => '';
  @override
  String get sentence2 => '';
  @override
  bool get showOutline => false;
  @override
  String get svgData => '';
  @override
  bool get svgExists => false;
  @override
  int get unitId => 0;
  @override
  String get unitTitle => '';
  @override
  String get vocab1 => '';
  @override
  String get vocab2 => '';
  @override
  int get vocabCount => 0;
  @override
  int get wordIndex => 0;
  @override
  List<Map> get wordsPhrase => [];
}

// Test Widget
class NavigationButtons extends ConsumerWidget {
  const NavigationButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navState = ref.watch(navigationStateProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: navState.canNavigatePrev ? () {} : null,
          icon: const Icon(Icons.arrow_back),
        ),
        IconButton(
          onPressed: navState.canNavigateNext ? () {} : null,
          icon: const Icon(Icons.arrow_forward),
        ),
      ],
    );
  }
}

// Test Helper Classes
class TestVsync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) => Ticker(onTick);
}

// Mock Provider
final wordControllerProvider = Provider<WordState>((ref) {
  throw UnimplementedError('Provider must be overridden in tests');
});

// Test Handler
void handleTabChange(ProviderContainer container, TabController controller) {
  Future(() {
    final wordState = container.read(wordControllerProvider);
    container.read(navigationStateProvider.notifier).state = NavigationState(
      currentTab: controller.index,
      canNavigateNext: controller.index < 3 && !wordState.isLearned,
      canNavigatePrev: controller.index > 0,
    );
  });
}

// Tests
void main() {
  late TabController tabController;
  late ProviderContainer container;

  setUp(() {
    tabController = TabController(length: 4, vsync: TestVsync());
    
    container = ProviderContainer(
      overrides: [
        wordControllerProvider.overrideWith((ref) => MockWordState()),
        navigationStateProvider.overrideWith((ref) => const NavigationState(
          currentTab: 0,
          canNavigateNext: false,
          canNavigatePrev: false,
        )),
      ],
    );
  });

  tearDown(() {
    tabController.dispose();
    container.dispose();
  });

  group('Tab Navigation Tests', () {
    test('Initial navigation state', () {
      final navState = container.read(navigationStateProvider);
      
      expect(navState.currentTab, equals(0));
      expect(navState.canNavigateNext, equals(false));
      expect(navState.canNavigatePrev, equals(false));
    });

    test('Tab change updates navigation state', () async {
      tabController.index = 1;
      handleTabChange(container, tabController);
      await Future.microtask(() {});
      
      final navState = container.read(navigationStateProvider);
      expect(navState.currentTab, equals(1));
      expect(navState.canNavigateNext, isTrue);
      expect(navState.canNavigatePrev, isTrue);
    });

    test('Last tab disables next navigation when word not learned', () async {
      tabController.index = 3;
      handleTabChange(container, tabController);
      await Future.microtask(() {});
      
      final navState = container.read(navigationStateProvider);
      expect(navState.currentTab, equals(3));
      expect(navState.canNavigateNext, isFalse);
      expect(navState.canNavigatePrev, isTrue);
    });

    test('Navigation state with learned word', () async {
      container = ProviderContainer(
        overrides: [
          wordControllerProvider.overrideWith((ref) => MockWordState(isLearned: true)),
          navigationStateProvider,
        ],
      );

      tabController.index = 2;
      handleTabChange(container, tabController);
      await Future.microtask(() {});
      
      final navState = container.read(navigationStateProvider);
      expect(navState.canNavigateNext, isTrue);
    });
  });

  group('Widget Integration Tests', () {
    testWidgets('Navigation buttons update on tab change', 
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            wordControllerProvider.overrideWith((ref) => MockWordState()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: const NavigationButtons(),
            ),
          ),
        ),
      );

      // Initial state - prev button disabled
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      final prevButton = tester.widget<IconButton>(
        find.byIcon(Icons.arrow_back),
      );
      expect(prevButton.onPressed, isNull);

      // Simulate tab change
      tabController.index = 1;
      handleTabChange(container, tabController);
      await tester.pump();

      // After tab change - prev button enabled
      final updatedPrevButton = tester.widget<IconButton>(
        find.byIcon(Icons.arrow_back),
      );
      expect(updatedPrevButton.onPressed, isNotNull);
    });
  });
}

// ======



