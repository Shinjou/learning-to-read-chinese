// lib/views/teach_word/teach_word_constants.dart

class TeachWordConstants {
  static const int tabCount = 4;
  static const double strokeWidth = 2.0;
  static const Duration animationDuration = Duration(milliseconds: 300);    
  
  // Tab indices for direct reference
  static const int lookTabIndex = 0;
  static const int listenTabIndex = 1;
  static const int writeTabIndex = 2;
  static const int useTabIndex = 3;

  // Step progression map
  static const Map<String, int> steps = {
    'goToListen': 0,
    'goToWrite': 1,
    'seeAnimation': 2,
    'practiceWithBorder1': 3,
    'practiceWithBorder2': 4,
    'practiceWithBorder3': 5,
    'turnBorderOff': 6,
    'practiceWithoutBorder1': 7,
    'goToUse1': 8,
    'goToUse2': 9,
  };

  // Helper method to get tab index based on step
  static int getTabIndexForStep(int stepId) {
    if (stepId < steps['goToListen']!) {
      return lookTabIndex;
    } else if (stepId < steps['goToWrite']!) {
      return listenTabIndex;
    } else if (stepId < steps['goToUse1']!) {
      return writeTabIndex;
    } else {
      return useTabIndex;
    }
  }
}
