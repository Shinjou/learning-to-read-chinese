// ./lib/views/teach_word/tabs/write_tab.dart

/*
// import 'package:audioplayers/audioplayers.dart' show AssetSource;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Consumer;
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:provider/provider.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class WriteTab extends ConsumerWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;  

  const WriteTab({
    super.key,
    required this.controllers,
    required this.state,
    required this.screenInfo,
  });

  /*
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building WriteTab - nextStepId: ${state.nextStepId}');
    if (controllers.strokeOrderAnimationController == null) {
      return _buildErrorWidget();
    }

    return TeachWordTabBarView(
      content: _WriteTabContent(
        controllers: controllers,
        state: state,
        screenInfo: screenInfo,
        ref: ref,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Text(
        '無法載入筆順動畫',
        style: TextStyle(
          fontSize: screenInfo.fontSize,
          color: Colors.red,
        ),
      ),
    );
  }
}

class _WriteTabContent extends ConsumerWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;
  final WidgetRef ref;

  const _WriteTabContent({
    required this.controllers,
    required this.state,
    required this.screenInfo,
    required this.ref,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building WriteTabContent - nextStepId: ${state.nextStepId}');
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: screenInfo.screenWidth * 0.90,
        maxHeight: screenInfo.screenHeight - screenInfo.screenHeight * 0.15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildWriteHeader(),
          SizedBox(height: screenInfo.fontSize * 0.2),
          Flexible(
            child: _buildStrokeAnimator(),
          ),
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildWriteHeader() {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: screenInfo.fontSize * 2.0,
      rightBorder: state.nextStepId == TeachWordConstants.steps['goToUse1'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '寫一寫',
        iconsColor: lightGray,
      ),
      isFirst: false,
      isLast: false,
      onLeftClicked: state.isWordLearned ? _handlePrevious : null,
      onRightClicked: _canNavigateNext ? _handleNext : null,
    );
  }

  Widget _buildStrokeAnimator() {
    return SizedBox(
      width: screenInfo.screenWidth,
      height: (screenInfo.screenHeight - screenInfo.screenHeight * 0.15) * 0.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: _buildStrokeAnimatorDecoration(),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildPracticeTimeIndicators(),
                _buildStrokeOrderAnimator(),
              ],
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildStrokeAnimatorDecoration() {
    return !state.isBpmf
        ? const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("lib/assets/img/box.png"),
              fit: BoxFit.fitWidth,
            ),
          )
        : const BoxDecoration(color: darkBrown);
  }

  Widget _buildPracticeTimeIndicators() {
    return Positioned(
      left: 10,
      top: 5,
      child: Column(
        children: [
          _buildPracticeIndicator(4),
          _buildPracticeIndicator(3),
          _buildPracticeIndicator(2),
          SizedBox(height: screenInfo.fontSize * 0.9),
          _buildPracticeIndicator(1),
        ],
      ),
    );
  }

  Widget _buildPracticeIndicator(int threshold) {
    final bool isActive = state.practiceTimeLeft >= threshold && !state.isWordLearned;
    return Icon(
      isActive ? Icons.circle_outlined : Icons.check_circle,
      size: screenInfo.fontSize * 1.5,
      color: isActive ? mediumGray : warmOrange,
    );
  }

  Widget _buildStrokeOrderAnimator() {
    return FittedBox(
      child: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
        value: controllers.strokeOrderAnimationController!,
        child: Consumer<StrokeOrderAnimationController>(
          builder: (context, controller, child) {
            return StrokeOrderAnimator(
              controller,
              key: UniqueKey(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Flexible(
      fit: FlexFit.loose,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 2,
        crossAxisSpacing: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildAnimationButton(),
          _buildWriteButton(),
          _buildOutlineButton(),
        ],
      ),
    );
  }

  Widget _buildAnimationButton() {
    final bool isAnimating = controllers.strokeOrderAnimationController?.isAnimating ?? false;
    
    return _buildControlButton(
      border: _shouldShowAnimationBorder,
      iconData: isAnimating ? Icons.pause : Icons.play_arrow,
      label: '筆順',
      isSelected: isAnimating,
      onPressed: _canShowAnimation ? _handleAnimationToggle : null,
    );
  }

  Widget _buildWriteButton() {
    final bool isQuizzing = controllers.strokeOrderAnimationController?.isQuizzing ?? false;
    
    return _buildControlButton(
      border: _shouldShowWriteBorder,
      iconData: isQuizzing ? Icons.edit_off : Icons.edit,
      label: '寫字',
      isSelected: isQuizzing,
      onPressed: _canWrite ? _handleWriteToggle : null,
    );
  }

  Widget _buildOutlineButton() {
    final bool showOutline = controllers.strokeOrderAnimationController?.showOutline ?? false;
    
    return _buildControlButton(
      border: _shouldShowOutlineBorder,
      iconData: showOutline ? Icons.remove_red_eye : Icons.remove_red_eye_outlined,
      label: '邊框',
      isSelected: showOutline,
      onPressed: _canToggleOutline ? _handleOutlineToggle : null,
    );
  }

  Widget _buildControlButton({
    required bool border,
    required IconData iconData,
    required String label,
    required bool isSelected,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: border
              ? BoxDecoration(
                  border: Border.all(
                    color: lightYellow,
                    width: 1.5,
                  ),
                )
              : null,
          child: IconButton(
            icon: Icon(
              iconData,
              size: screenInfo.fontSize,
            ),
            color: backgroundColor,
            onPressed: onPressed,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: screenInfo.fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  // Navigation handlers
  void _handlePrevious() {
    debugPrint('WriteTab handlePrevious called');
    controllers.handlePreviousInWriteTab(state);
  }

  void _handleNext() {
    debugPrint('WriteTab handleNext called');
    controllers.handleNextInWriteTab(state);
  }

  // Button handlers
  void _handleAnimationToggle() {
    debugPrint('Animation toggle - isAnimating: ${controllers.strokeOrderAnimationController?.isAnimating}');
    if (!controllers.strokeOrderAnimationController!.isAnimating) {
      controllers.startAnimation(state);
    } else {
      controllers.stopAnimation();
    }
  }

  void _handleWriteToggle() async {
    debugPrint('Write toggle called');
    await controllers.handleWriteToggle(state);
  }

  void _handleOutlineToggle() {
    debugPrint('Outline toggle called');
    controllers.handleOutlineToggle(state, ref);
  }

  // Conditional checks
  bool get _canNavigateNext =>
    state.nextStepId == TeachWordConstants.steps['goToUse1'] || 
    state.isWordLearned;

  bool get _shouldShowAnimationBorder =>
    state.nextStepId == TeachWordConstants.steps['seeAnimation'] && 
    !state.isWordLearned;

  bool get _shouldShowWriteBorder =>
    ((state.nextStepId > TeachWordConstants.steps['seeAnimation']! && 
      state.nextStepId < TeachWordConstants.steps['turnBorderOff']!) && 
     !state.isWordLearned && 
     !(controllers.strokeOrderAnimationController?.isQuizzing ?? false)) || 
    (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']!);

  bool get _shouldShowOutlineBorder =>
    state.nextStepId == TeachWordConstants.steps['turnBorderOff'] && 
    !state.isWordLearned;

  bool get _canShowAnimation =>
    (!controllers.strokeOrderAnimationController!.isQuizzing && 
     (state.nextStepId == TeachWordConstants.steps['seeAnimation'])) || 
    state.isWordLearned;

  bool get _canWrite =>
    ((state.nextStepId > TeachWordConstants.steps['seeAnimation']! && 
      state.nextStepId < TeachWordConstants.steps['turnBorderOff']!) || 
     state.isWordLearned || 
     (state.nextStepId == TeachWordConstants.steps['practiceWithoutBorder1']!));

  bool get _canToggleOutline =>
    state.nextStepId == TeachWordConstants.steps['turnBorderOff'] || 
    state.isWordLearned;
}
*/

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building WriteTab - word: ${state.word}, nextStepId: ${state.nextStepId}, isLearned: ${state.isLearned}');

    return TeachWordTabBarView(
      content: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenInfo.screenWidth * 0.90,
            maxHeight: screenInfo.screenHeight - screenInfo.nonConsumedHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _buildTopControls(context, ref),
              const SizedBox(height: 8),
              _buildWritingArea(context, ref),
              _buildBottomControls(context, ref),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopControls(BuildContext context, WidgetRef ref) {
    debugPrint('Building top controls - isLearned: ${state.isLearned}');
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: screenInfo.iconSize,
      rightBorder: state.nextStepId == TeachWordConstants.steps['goToUse1'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '寫一寫',
        iconsColor: lightGray,
      ),
      isFirst: false,
      isLast: false,
      onLeftClicked: state.isLearned || state.canNavigatePrevious()
          ? () => _handlePreviousNavigation(ref)
          : null,
      onRightClicked: state.isLearned || state.nextStepId == TeachWordConstants.steps['goToUse1']
          ? () => _handleNextNavigation(ref)
          : null,
    );
  }

  Widget _buildWritingArea(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
        value: _strokeOrderAnimationController!,
        child: Consumer<StrokeOrderAnimationController>(
          builder: (context, controller, _) {
            return Stack(
              alignment: Alignment.center,
              children: [
                _buildStrokeCanvas(controller),
                _buildPracticeIndicators(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStrokeCanvas(StrokeOrderAnimationController controller) {
    return Container(
      decoration: !state.isBpmf
          ? const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/assets/img/box.png"),
                fit: BoxFit.fitWidth,
              ),
            )
          : const BoxDecoration(color: darkBrown),
      child: StrokeOrderAnimator(
        controller,
        key: ValueKey('${state.word}-${state.nextStepId}'),
      ),
    );
  }

  Widget _buildPracticeIndicators() {
    return Positioned(
      left: 10,
      top: 5,
      child: Column(
        children: List.generate(4, (index) =>
          _buildPracticeIcon(index < state.practiceTimeLeft && !state.isLearned)
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildControlButton(
          context: context,
          border: state.nextStepId == TeachWordConstants.steps['seeAnimation'] && !state.isLearned,
          iconData: [Icons.pause, Icons.play_arrow],
          label: '筆順',
          onPressed: () => _handleStrokeOrder(ref),
          isSelected: ref.watch(strokeAnimationPlayingProvider),
        ),
        _buildControlButton(
          context: context,
          border: state.canStartWriting(),
          iconData: [Icons.edit_off, Icons.edit],
          label: '寫字',
          onPressed: () => _handleWriting(ref),
          isSelected: ref.watch(strokeQuizActiveProvider),
        ),
        _buildControlButton(
          context: context,
          border: state.canToggleOutline(),
          iconData: [Icons.remove_red_eye, Icons.remove_red_eye_outlined],
          label: '邊框',
          onPressed: () => _handleOutlineToggle(ref),
          isSelected: ref.watch(showOutlineProvider),
        ),
      ],
    );
  }

  void _handleStrokeOrder(WidgetRef ref) {
    debugPrint('Handling stroke order button - nextStepId: ${state.nextStepId}');
    final notifier = ref.read(teachWordStateProvider.notifier);
    final controller = ref.read(strokeOrderControllerProvider);

    if (!controller.isAnimating) {
      controller.startAnimation();
      if (state.nextStepId == TeachWordConstants.steps['seeAnimation']) {
        notifier.incrementNextStepId();
      }
    } else {
      controller.stopAnimation();
    }
  }

  void _handleWriting(WidgetRef ref) {
    debugPrint('Handling writing button - nextStepId: ${state.nextStepId}');
    if (state.canStartWriting()) {
      final controller = ref.read(strokeOrderControllerProvider);
      controller.startQuiz();
    }
  }

  void _handleOutlineToggle(WidgetRef ref) {
    debugPrint('Handling outline toggle - nextStepId: ${state.nextStepId}');
    if (state.canToggleOutline()) {
      final controller = ref.read(strokeOrderControllerProvider);
      controller.toggleOutline();
      
      if (state.nextStepId == TeachWordConstants.steps['turnBorderOff']) {
        ref.read(teachWordStateProvider.notifier).incrementNextStepId();
      }
    }
  }

  void _handlePreviousNavigation(WidgetRef ref) {
    debugPrint('Handling previous navigation');
    controllers.navigateToPreviousTab(state);
  }

  void _handleNextNavigation(WidgetRef ref) {
    debugPrint('Handling next navigation');
    controllers.navigateToNextTab(state);
  }

  Widget _buildControlButton({
    required BuildContext context,
    required bool border,
    required List<IconData> iconData,
    required String label,
    required VoidCallback? onPressed,
    required bool isSelected,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            border: border
                ? Border.all(color: lightYellow, width: 1.5)
                : null,
          ),
          child: IconButton(
            icon: Icon(
              isSelected ? iconData[0] : iconData[1],
              size: screenInfo.fontSize,
            ),
            color: backgroundColor,
            onPressed: onPressed,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: screenInfo.fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeIcon(bool isActive) {
    return Icon(
      isActive ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: isActive ? mediumGray : warmOrange,
      size: screenInfo.fontSize * 1.5,
    );
  }
}
*/

// lib/views/teach_word/tabs/write_tab.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide ChangeNotifierProvider, Consumer;
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
// import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
// import 'package:provider/provider.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/teach_word/teach_word_constants.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animation_controller.dart';
import 'package:ltrc/widgets/teach_word/stroke_order_animator.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/card_title.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

class WriteTab extends ConsumerWidget {
  final TeachWordControllers controllers;
  final TeachWordState state;
  final ScreenInfo screenInfo;  

  const WriteTab({
    super.key,
    required this.controllers,
    required this.state,
    required this.screenInfo,    
    });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Building WriteTab - word: ${state.word}, stepId: ${state.nextStepId}, learned: ${state.isLearned}');

    return TeachWordTabBarView(
      content: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenInfo.screenWidth * 0.90,
            maxHeight: screenInfo.screenHeight - (screenInfo.screenHeight * 0.15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTopNavigation(screenInfo, state, controllers),
              SizedBox(height: screenInfo.fontSize * 0.2),
              _buildWritingArea(ref, screenInfo, state),
              _buildControlButtons(ref, screenInfo, state, controllers),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopNavigation(ScreenInfo screenInfo, TeachWordState state, TeachWordControllers controllers) {
    return LeftRightSwitch(
      iconsColor: lightGray,
      iconsSize: screenInfo.fontSize * 2.0,
      rightBorder: state.nextStepId == TeachWordConstants.steps['goToUse1'],
      middleWidget: const TeachWordCardTitle(
        sectionName: '寫一寫',
        iconsColor: lightGray,
      ),
      isFirst: false,
      isLast: false,
      onLeftClicked: state.canNavigatePrevious
          ? () {
              debugPrint('Navigate previous clicked');
              controllers.navigateToPreviousTab();
            }
          : null,
      onRightClicked: state.isLearned || state.nextStepId == TeachWordConstants.steps['goToUse1']
          ? () {
              debugPrint('Navigate next clicked');
              controllers.navigateToNextTab();
            }
          : null,
    );
  }

  Widget _buildWritingArea(WidgetRef ref, ScreenInfo screenInfo, TeachWordState state) {
    final strokeController = ref.watch(strokeOrderControllerProvider);
    if (strokeController == null) return const SizedBox.shrink();
    final strokeOrderAnimationController = ref.watch(strokeOrderControllerProvider.notifier);
    final isBpmf = state.isBpmf;
    final practiceTimeLeft = state.practiceTimeLeft;
    final wordIsLearned = state.isLearned;
    final fontSize = screenInfo.fontSize;
    final availableWidth = screenInfo.screenWidth;
    final availableHeight = screenInfo.screenHeight;
    final nonConsumedHeight = screenInfo.nonConsumedHeight;

    return SizedBox(                            
      width: availableWidth,
      height: (availableHeight - nonConsumedHeight) * 0.5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: !isBpmf
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/assets/img/box.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : const BoxDecoration(color: darkBrown),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: 10,
                  top: 5,
                  child: Column(children: [
                    _buildPracticeTimeIcon(practiceTimeLeft >= 4 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 3 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 2 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                    SizedBox(height: fontSize * 0.9),
                    _buildPracticeTimeIcon(practiceTimeLeft >= 1 && !wordIsLearned, fontSize, mediumGray, warmOrange),
                  ]),
                ),
                FittedBox(
                  child: StrokeOrderAnimator(
                    strokeOrderAnimationController as StrokeOrderAnimationController,
                    key: UniqueKey(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  

    /*
    return Flexible(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: !state.isBpmf
                ? const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("lib/assets/img/box.png"),
                      fit: BoxFit.fitWidth,
                    ),
                  )
                : const BoxDecoration(color: darkBrown),
            child: StrokeOrderAnimator(
              strokeController,
              key: ValueKey('${state.word}-${state.nextStepId}'),
            ),
          ),
          Positioned(
            left: screenInfo.fontSize * 0.5,
            top: screenInfo.fontSize * 0.2,
            child: Column(
              children: List.generate(
                4,
                (index) => _buildPracticeIndicator(
                  index < state.practiceTimeLeft && !state.isLearned,
                  screenInfo.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    */

  }

  Widget _buildControlButtons(
    WidgetRef ref, 
    ScreenInfo screenInfo, 
    TeachWordState state,
    TeachWordControllers controllers
  ) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.0,
      mainAxisSpacing: screenInfo.fontSize * 0.1,
      crossAxisSpacing: screenInfo.fontSize * 0.15,
      children: [
        _buildControlButton(
          border: state.nextStepId == TeachWordConstants.steps['seeAnimation'] && !state.isLearned,
          iconData: ref.watch(strokeAnimationPlayingProvider)
              ? Icons.pause
              : Icons.play_arrow,
          label: '筆順',
          onPressed: state.canShowStrokeOrder
              ? () => controllers.handleStrokeOrderAnimation()
              : null,
          fontSize: screenInfo.fontSize,
        ),
        _buildControlButton(
          border: state.canShowWriteButton,
          iconData: ref.watch(strokeQuizActiveProvider)
              ? Icons.edit_off
              : Icons.edit,
          label: '寫字',
          onPressed: state.canShowWriteButton
              ? () => controllers.handleWriting()
              : null,
          fontSize: screenInfo.fontSize,
        ),
        _buildControlButton(
          border: state.canToggleOutline,
          iconData: ref.watch(showOutlineProvider)
              ? Icons.remove_red_eye
              : Icons.remove_red_eye_outlined,
          label: '邊框',
          onPressed: state.canToggleOutline
              ? () => controllers.handleOutlineToggle()
              : null,
          fontSize: screenInfo.fontSize,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required bool border,
    required IconData iconData,
    required String label,
    required VoidCallback? onPressed,
    required double fontSize,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: border
              ? BoxDecoration(
                  border: Border.all(color: lightYellow, width: 1.5),
                )
              : null,
          child: IconButton(
            icon: Icon(
              iconData,
              size: fontSize,
            ),
            color: backgroundColor,
            onPressed: onPressed,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            color: backgroundColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeTimeIcon(bool condition, double fontSize, Color defaultColor, Color activeColor) {
    return Icon(
      condition ? Icons.check_circle_outline_outlined : Icons.check_circle,
      color: condition ? defaultColor : activeColor,
      size: fontSize * 1.5,
    );
  }

}

