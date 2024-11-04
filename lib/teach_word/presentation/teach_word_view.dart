// lib/teach_word/presentation/teach_word_screen.dart


import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/look_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/listen_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/write_tab.dart';
import 'package:ltrc/teach_word/presentation/widgets/tabs/use_tab.dart';
import 'package:ltrc/teach_word/providers/word_provider.dart';

import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/word_card.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/teach_word/constants/steps.dart';



class TeachWordView extends ConsumerStatefulWidget {
  final int unitId;
  final String unitTitle;
  final List<WordStatus> wordsStatus;
  final List<Map> wordsPhrase;
  final int wordIndex;

  const TeachWordView({
    super.key,
    required this.unitId,
    required this.unitTitle,
    required this.wordsStatus,
    required this.wordsPhrase,
    required this.wordIndex,
  });

  @override
  TeachWordViewState createState() => TeachWordViewState();
}

class TeachWordViewState extends ConsumerState<TeachWordView> 
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final StrokeOrderAnimationController strokeController;

  @override
  void initState() {
    super.initState();
    
    // Initialize TabController
    _tabController = TabController(length: 4, vsync: this);
    
    // Proper initialization of StrokeController with all required parameters
    strokeController = StrokeOrderAnimationController(
      '',  // Initial SVG data
      this,  // TickerProvider
      strokeAnimationSpeed: 1.0,
      hintAnimationSpeed: 1.0,
      showStroke: true,
      showOutline: true,
      showMedian: false,
      showUserStroke: true,
      highlightRadical: false,
      strokeColor: const Color.fromRGBO(153, 153, 153, 1),
      outlineColor: const Color.fromRGBO(153, 153, 153, 1),
      medianColor: const Color.fromRGBO(153, 153, 153, 1),
      radicalColor: Colors.red,
      brushColor: const Color.fromRGBO(153, 153, 153, 1),
      brushWidth: 8.0,
      hintAfterStrokes: 3,
      hintColor: Colors.white,
    );
    
    // Set up word controller with initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(wordControllerProvider.notifier)
        ..initializeWord(
          widget.wordsStatus[widget.wordIndex],
          widget.wordsPhrase[widget.wordIndex],
        )
        ..setStrokeController(strokeController);
    });
    
    // Listen to tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final wordState = ref.read(wordControllerProvider);
        ref.read(navigationStateProvider.notifier).state = NavigationState(
          currentTab: _tabController.index,
          canNavigateNext: _tabController.index < 3 && !wordState.isLearned,
          canNavigatePrev: _tabController.index > 0,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    strokeController.dispose();
    super.dispose();
  }

  void nextTab() {
    final wordController = ref.read(wordControllerProvider.notifier);
    final wordState = ref.read(wordControllerProvider);

    if (wordState.nextStepId >= TeachWordSteps.steps['goToUse2']!) return;

    int savedNextStepId = wordState.nextStepId;
    wordController.updateState(currentTabIndex: wordState.currentTabIndex + 1);

    if (wordState.svgExists) {
      if (wordState.isLearned) {
        if (savedNextStepId > 1 && savedNextStepId < 8) {
          wordController.updateState(nextStepId: TeachWordSteps.steps['goToUse1']!);
        }
      }
      _processNextStep();
    } else {
      if (wordState.nextStepId > TeachWordSteps.steps['goToListen']! && 
          wordState.nextStepId < TeachWordSteps.steps['goToUse1']!) {
        wordController.handleError('noSvg');
        return;
      }
      wordController.updateState(
        nextStepId: math.min(TeachWordSteps.steps['goToUse2']!, wordState.nextStepId)
      );
      _processNextStep();
    }

    _tabController.animateTo(_tabController.index + 1);
  }

  void prevTab() {
    final wordController = ref.read(wordControllerProvider.notifier);
    final wordState = ref.read(wordControllerProvider);

    if (_tabController.index > 0) {
      // int savedNextStepId = wordState.nextStepId;
      wordController.updateState(currentTabIndex: wordState.currentTabIndex - 1);

      if (wordState.svgExists) {
        if (wordState.isLearned) {
          if (wordState.nextStepId > 0 && wordState.nextStepId < 8) {
            wordController.updateState(nextStepId: TeachWordSteps.steps['goToListen']!);
          } else {
            _adjustPrevStepId();
          }
        } else {
          wordController.updateState(nextStepId: wordState.nextStepId - 1);
        }
      } else {
        if (wordState.nextStepId == TeachWordSteps.steps['goToUse2']) {
          wordController.updateState(nextStepId: wordState.nextStepId - 1);
        } else if (wordState.nextStepId == TeachWordSteps.steps['goToUse1']) {
          wordController.handleError('noSvg');
          wordController.updateState(
            nextStepId: TeachWordSteps.steps['practiceWithoutBorder1']!
          );
        } else {
          wordController.updateState(
            nextStepId: math.max(0, wordState.nextStepId - 1)
          );
        }
      }

      _tabController.animateTo(_tabController.index - 1);
    }
  }

  void _adjustPrevStepId() {
    final wordController = ref.read(wordControllerProvider.notifier);
    final wordState = ref.read(wordControllerProvider);
    
    int newStepId = wordState.nextStepId - 1;
    if (newStepId == TeachWordSteps.steps['practiceWithoutBorder1']) {
      newStepId = TeachWordSteps.steps['goToWrite']!;
    } else if (newStepId < TeachWordSteps.steps['goToListen']!) {
      newStepId = TeachWordSteps.steps['goToListen']!;
    }
    wordController.updateState(nextStepId: newStepId);
  }

  void _processNextStep() async {
    final wordController = ref.read(wordControllerProvider.notifier);
    final wordState = ref.read(wordControllerProvider);

    if (wordState.nextStepId == TeachWordSteps.steps['goToListen']) {
      wordController.incrementNextStepId();
    } else if (wordState.nextStepId == TeachWordSteps.steps['goToWrite'] || 
              wordState.nextStepId == (TeachWordSteps.steps['goToWrite']! + 1)) {
      wordController.incrementNextStepId();
      await wordController.playWordAudio();
    } else if (wordState.nextStepId == TeachWordSteps.steps['goToUse1'] || 
              wordState.nextStepId == TeachWordSteps.steps['goToUse2']) {
      await wordController.handleGoToUse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final screenInfo = ref.watch(screenInfoProvider);
    
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight * 2),
      child: AppBar(
        title: Text(
          widget.unitTitle,
          style: TextStyle(fontSize: screenInfo.fontSize * 1.2),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.image, size: screenInfo.fontSize)),
            Tab(icon: Icon(Icons.hearing, size: screenInfo.fontSize)),
            Tab(icon: Icon(Icons.create, size: screenInfo.fontSize)),
            Tab(icon: Icon(Icons.school, size: screenInfo.fontSize)),
          ],
          onTap: (index) {
            // Prevent direct tab switching - must go through navigation
            final currentState = ref.read(navigationStateProvider);
            if (index != currentState.currentTab) {
              _tabController.animateTo(currentState.currentTab);
            }
          },
          labelColor: darkBrown,
          dividerColor: mediumGray,
          unselectedLabelColor: mediumGray,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 2),
          indicator: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            color: mediumGray,
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final navigationState = ref.watch(navigationStateProvider);
    
    return ProviderScope(
      overrides: [
        contextProvider.overrideWithValue(context),
      ],
      child: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LookTab(
            onNextTab: navigationState.canNavigateNext ? nextTab : () {},
          ),
          ListenTab(
            onPreviousTab: navigationState.canNavigatePrev ? prevTab : () {},
            onNextTab: navigationState.canNavigateNext ? nextTab : () {},
          ),
          WriteTab(
            onPreviousTab: navigationState.canNavigatePrev ? prevTab : () {},
            onNextTab: navigationState.canNavigateNext ? nextTab : () {},
          ),
          UseTab(
            onPreviousTab: navigationState.canNavigatePrev ? prevTab : () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final screenInfo = ref.watch(screenInfoProvider);
    final wordState = ref.watch(wordControllerProvider);
    
    return Container(
      height: 4.0 * screenInfo.fontSize,
      color: darkBrown,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenInfo.fontSize),
        child: LeftRightSwitch(
          iconsColor: beige,
          iconsSize: screenInfo.fontSize * 2.0,
          rightBorder: false,
          middleWidget: WordCard(
            unitId: widget.unitId,
            unitTitle: widget.unitTitle,
            wordsStatus: widget.wordsStatus,
            wordsPhrase: widget.wordsPhrase,
            wordIndex: widget.wordIndex,
            sizedBoxWidth: 10 * screenInfo.fontSize,
            sizedBoxHeight: 4.0 * screenInfo.fontSize,
            fontSize: screenInfo.fontSize * 1.2,
            isBpmf: wordState.isBpmf,
            isVertical: false,
            disable: true,
          ),
          isFirst: (widget.wordIndex == 0),
          isLast: (widget.wordIndex == widget.wordsStatus.length - 1),
          onLeftClicked: widget.wordIndex > 0 
            ? () => _navigateToWord(-1) 
            : null,
          onRightClicked: widget.wordIndex < widget.wordsStatus.length - 1 
            ? () => _navigateToWord(1) 
            : null,
        ),
      ),
    );
  }

  void _navigateToWord(int offset) {
    navigateWithProvider(
      context,
      '/teachWord',
      ref,
      arguments: {
        'unitId': widget.unitId,
        'unitTitle': widget.unitTitle,
        'wordsStatus': widget.wordsStatus,
        'wordsPhrase': widget.wordsPhrase,
        'wordIndex': widget.wordIndex + offset,
      },
    );
  }
}