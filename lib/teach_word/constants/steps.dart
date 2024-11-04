// lib/teach_word/constants/steps.dart

class TeachWordSteps {
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

  static bool isAtStep(int currentStep, String stepName) {
    return currentStep == steps[stepName];
  }

  static bool isBeforeStep(int currentStep, String stepName) {
    return currentStep < (steps[stepName] ?? currentStep + 1);
  }

  static bool isAfterStep(int currentStep, String stepName) {
    return currentStep > (steps[stepName] ?? -1);
  }

  static bool isBetweenSteps(int currentStep, String startStep, String endStep) {
    final start = steps[startStep] ?? -1;
    final end = steps[endStep] ?? currentStep + 1;
    return currentStep > start && currentStep < end;
  }
}


