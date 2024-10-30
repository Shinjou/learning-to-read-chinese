// views/teach_word/widgets/teach_word_app_bar.dart

import 'package:flutter/material.dart';
import 'package:ltrc/views/teach_word/state/teach_word_providers.dart';
import 'package:ltrc/views/teach_word/state/teach_word_state.dart';
import 'package:ltrc/views/teach_word/teach_word_controllers.dart';
import 'package:ltrc/views/view_utils.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TeachWordAppBar extends PreferredSize {
  TeachWordAppBar({
    super.key,
    required ScreenInfo screenInfo,
    required TeachWordControllers controllers,
    required TeachWordState state,
    required int unitId,
    required String unitTitle,
  }) : super(
    preferredSize: const Size.fromHeight(kToolbarHeight * 2),
    child: _TeachWordAppBarContent(
      screenInfo: screenInfo,
      controllers: controllers,
      state: state,
      unitId: unitId,
      unitTitle: unitTitle,
    ),
  );
}

class _TeachWordAppBarContent extends ConsumerWidget {
  final ScreenInfo screenInfo;
  final TeachWordControllers controllers;
  final TeachWordState state;
  final int unitId;
  final String unitTitle;

  const _TeachWordAppBarContent({
    required this.screenInfo,
    required this.controllers,
    required this.state,
    required this.unitId,
    required this.unitTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: SizedBox(
        width: screenInfo.screenWidth,
        child: SafeArea(
          child: Column(
            children: [
              _buildTopBar(context),
              _buildTabBar(ref), // Pass ref to _buildTabBar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return SizedBox(
      height: kToolbarHeight,
      child: Row(
        children: [
          _buildBackButton(context),
          Expanded(child: _buildTitle()),
          _buildHomeButton(context),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.chevron_left,
        color: beige,
        size: screenInfo.fontSize * 1.5,
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitle() {
    String title = (unitId == -1)
        ? unitTitle
        : "${unitId.toString().padLeft(2, '0')} | $unitTitle";
            
    return Text(
      title,
      style: TextStyle(
        fontSize: screenInfo.fontSize * 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/mainPage');
      },
      icon: Icon(
        Icons.home_filled,
        color: beige,
        size: screenInfo.fontSize * 1.5,
      ),
    );
  }

  Widget _buildTabBar(WidgetRef ref) {  // Add WidgetRef parameter here
    return SizedBox(
      height: kToolbarHeight,
      child: TabBar(
        tabs: _buildTabs(),
        controller: controllers.tabController,
        onTap: (index) => _handleTabTap(index, ref), // Pass ref to _handleTabTap
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
    );
  }

  List<Widget> _buildTabs() {
    return [
      Tab(icon: Icon(Icons.image, size: screenInfo.fontSize * 0.75)),
      Tab(icon: Icon(Icons.hearing, size: screenInfo.fontSize * 0.75)),
      Tab(icon: Icon(Icons.create, size: screenInfo.fontSize * 0.75)),
      Tab(icon: Icon(Icons.school, size: screenInfo.fontSize * 0.75)),
    ];
  }

  void _handleTabTap(int index, WidgetRef ref) { // Add WidgetRef parameter here
    if (_shouldAllowTabSwitch(index)) {
      ref.read(teachWordStateProvider.notifier).setCurrentTabIndex(index);
    } else {
      controllers.tabController.index = ref.read(teachWordStateProvider).currentTabIndex;
    }
  }

  bool _shouldAllowTabSwitch(int index) {
    if (state.isLearned && state.svgFileExists) {
      return true;
    } else {
      return false;
    }
  }
}

