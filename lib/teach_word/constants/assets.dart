// lib/teach_word/constants/assets.dart

class AssetPaths {
  static const String boxImage = "lib/assets/img/box.png";
  static const String bpmfPath = "lib/assets/img/bopomo/";
  static const String oldWordsPath = "lib/assets/img/oldWords/";
  static const String svgPath = "lib/assets/svg/";
  static const String vocabularyPath = "lib/assets/img/vocabulary/";
  
  static String getBpmfAudio(String word) => 'bopomo/$word.mp3';
  static String getBpmfImage(String word) => '$bpmfPath$word.png';
  static String getOldWordImage(String word) => '$oldWordsPath$word.webp';
  static String getSvgFile(String word) => '$svgPath$word.json';
  static String getVocabImage(String word) => '$vocabularyPath$word.webp';
}