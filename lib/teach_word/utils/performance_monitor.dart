// lib/teach_word/utils/performance_monitor.dart

import 'package:flutter/foundation.dart';

class PerformanceMonitor {
  static final Map<String, Stopwatch> _timers = {};
  static const int _warningThresholdMs = 500; // Warn if operation takes longer than 500ms

  static void startTimer(String operation) {
    _timers[operation] = Stopwatch()..start();
  }

  static void stopTimer(String operation) {
    final timer = _timers[operation];
    if (timer == null) return;

    timer.stop();
    final duration = timer.elapsedMilliseconds;
    debugPrint('Performance: $operation took $duration ms');
    
    if (duration > _warningThresholdMs) {
      debugPrint('⚠️ Warning: $operation is slow (${duration}ms > ${_warningThresholdMs}ms)');
    }

    _timers.remove(operation);
  }
}

// Add to TeachWordView:

class TeachWordViewState extends ConsumerStatefulWidget {
  // ... existing code ...

  @override
  void initState() {
    super.initState();
    PerformanceMonitor.startTimer('TeachWordView_Initialize');
    _initializeComponents();
  }

  Future<void> _initializeComponents() async {
    try {
      PerformanceMonitor.startTimer('InitComponents');
      
      word = widget.wordsStatus[widget.wordIndex].word;
      
      PerformanceMonitor.startTimer('InitTTS');
      _initializeTts();
      PerformanceMonitor.stopTimer('InitTTS');
      
      PerformanceMonitor.startTimer('InitTabController');
      _initializeTabController();
      PerformanceMonitor.stopTimer('InitTabController');
      
      await _initializeWordState();
      
      PerformanceMonitor.stopTimer('InitComponents');
      PerformanceMonitor.stopTimer('TeachWordView_Initialize');
    } catch (e, stackTrace) {
      debugPrint('Error initializing components: $e\n$stackTrace');
      _showErrorDialog('Initialization Error', 
        'Failed to initialize components. Please restart the app.');
    }
  }

  Future<void> _initializeWordState() async {
    PerformanceMonitor.startTimer('InitWordState');
    int memoryBefore = 0;
    try {
      memoryBefore = await _getCurrentMemoryUsage();
      
      // ... existing initialization code ...

      final memoryAfter = await _getCurrentMemoryUsage();
      final memoryDiff = memoryAfter - memoryBefore;
      if (memoryDiff > 50 * 1024 * 1024) { // Warning if memory increase > 50MB
        debugPrint('⚠️ Warning: High memory usage in initialization: ${memoryDiff ~/ (1024*1024)}MB');
      }

      PerformanceMonitor.stopTimer('InitWordState');
    } catch (e, stackTrace) {
      final memoryAfter = await _getCurrentMemoryUsage();
      debugPrint('Memory leak in error case: ${(memoryAfter - memoryBefore) ~/ (1024*1024)}MB');
      rethrow;
    }
  }

  Future<int> _getCurrentMemoryUsage() async {
    // This is a simple approximation. You might want to use platform-specific code
    // for more accurate measurements
    return Future.value(0); // Placeholder
  }

  // Add frame timing monitoring
  late DateTime _lastBuildTime;
  int _consecutiveSlowFrames = 0;

  @override
  Widget build(BuildContext context) {
    final buildStartTime = DateTime.now();
    
    if (_lastBuildTime != null) {
      final timeSinceLastBuild = buildStartTime.difference(_lastBuildTime);
      if (timeSinceLastBuild.inMilliseconds > 16) { // 60 FPS threshold
        _consecutiveSlowFrames++;
        if (_consecutiveSlowFrames > 5) {
          debugPrint('⚠️ Warning: Multiple slow frames detected');
          _reportPerformanceIssue();
        }
      } else {
        _consecutiveSlowFrames = 0;
      }
    }
    _lastBuildTime = buildStartTime;

    // Wrap the build with performance monitoring
    return _PerformanceWrapper(
      child: // ... your existing build code ...
    );
  }

  void _reportPerformanceIssue() {
    // Collect performance data
    final report = {
      'timestamp': DateTime.now().toString(),
      'word': word,
      'memoryUsage': _getCurrentMemoryUsage(),
      'slowFrames': _consecutiveSlowFrames,
      'timers': PerformanceMonitor._timers,
      // Add other relevant data
    };
    
    debugPrint('Performance Report: $report');
  }
}

// Performance wrapper widget
class _PerformanceWrapper extends StatelessWidget {
  final Widget child;
  
  const _PerformanceWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        PerformanceMonitor.startTimer('LayoutBuild');
        return NotificationListener<LayoutChangedNotification>(
          onNotification: (notification) {
            PerformanceMonitor.stopTimer('LayoutBuild');
            _checkLayoutPerformance();
            return true;
          },
          child: child,
        );
      },
    );
  }

  void _checkLayoutPerformance() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderObject = context.findRenderObject();
      if (renderObject != null) {
        final size = renderObject.paintBounds.size;
        if (size.width * size.height > 1000000) { // Large render area
          debugPrint('⚠️ Warning: Large render area detected');
        }
      }
    });
  }
}

// Add performance monitoring to WriteState updates
void _handleQuizCompletion(QuizSummary summary) {
  PerformanceMonitor.startTimer('QuizCompletion');
  try {
    final wordState = ref.read(wordStateProvider);
    if (wordState?.writeState == null) {
      throw Exception('Write state is not initialized');
    }

    PerformanceMonitor.startTimer('StateUpdate');
    ref.read(wordStateProvider.notifier).updateWriteState((writeState) {
      final newTimeLeft = writeState.practiceTimeLeft - 1;
      final newStepId = writeState.nextStepId + 1;
      
      if (newTimeLeft == 0) {
        PerformanceMonitor.startTimer('LearnedStatusUpdate');
        ref.read(wordStateProvider.notifier).updateLearnedStatus(true);
        PerformanceMonitor.stopTimer('LearnedStatusUpdate');
      }

      return writeState.copyWith(
        practiceTimeLeft: newTimeLeft,
        nextStepId: newStepId,
      );
    });
    PerformanceMonitor.stopTimer('StateUpdate');

  } catch (e, stackTrace) {
    debugPrint('Error handling quiz completion: $e\n$stackTrace');
  } finally {
    PerformanceMonitor.stopTimer('QuizCompletion');
  }
}

// Add SVG loading performance monitoring
Future<String> _loadSvgData(String word) async {
  PerformanceMonitor.startTimer('LoadSVG_$word');
  try {
    final String response = await rootBundle.loadString(
      'lib/assets/svg/$word.json',
    );
    
    PerformanceMonitor.startTimer('ProcessSVG');
    final processed = response.replaceAll("\"", "'");
    PerformanceMonitor.stopTimer('ProcessSVG');
    
    return processed;
  } finally {
    PerformanceMonitor.stopTimer('LoadSVG_$word');
  }
}