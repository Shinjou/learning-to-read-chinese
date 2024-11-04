// lib/teach_word/constants/error_messages.dart

class ErrorMessages {
  static const String noSvg = '抱歉，「{word}」還沒有筆順。請繼續。謝謝！';
  static const String noWord = '「{word}」不在SQL。請截圖回報。謝謝！';
  static const String jsonError = '「{word}」的筆順檔無法下載。請截圖回報。謝謝！';
  static const String svgError = '「{word}」筆順檔問題。請截圖回報。謝謝！';
  static const String unknownError = '「{word}」發生未知錯誤。請截圖回報。謝謝！';

  static String format(String message, String word) {
    return message.replaceAll('{word}', word);
  }
}
