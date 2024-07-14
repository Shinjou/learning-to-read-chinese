// polyphonic_processor.dart
// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';

import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';

class PolyphonicProcessor {
  late Map<String, dynamic> _polyphonicData;
  String spansUnicode = '';

  static final PolyphonicProcessor _instance = PolyphonicProcessor._internal();

  PolyphonicProcessor._internal();

  static PolyphonicProcessor get instance => _instance;

  Future<void> loadPolyphonicData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data_files/poyin_db.json');
      _polyphonicData = json.decode(jsonString);
      if (!_polyphonicData.containsKey('data')) {
        throw Exception('Polyphonic data is improperly formatted or missing key data');
      }
      // // debugPrint('Polyphonic data loaded successfully');
    } catch (e) {
      // // debugPrint('Failed to load polyphonic data: $e');
      throw Exception('Failed to load polyphonic data: $e');
    }
  }

  TextStyle getCharPolyStyle(double fontSize, Color color, String newSs, bool highlightOn) {
    return TextStyle(
      fontFamily: 'BpmfIansui',
      fontSize: fontSize,
      color: highlightOn ? Colors.black : color,
      background: highlightOn ? (Paint()..color = Colors.yellow) : (null),
      fontFeatures: [FontFeature.enable(newSs)]
    );
  }

  TextStyle getCharStyle(double fontSize, Color color, bool highlightOn) {
    return TextStyle(
      fontFamily: 'BpmfIansui',
      fontSize: fontSize,
      color: color,
      background: null,
    );
  }

  // output: 1, 2, 3, 4, 5. If error, return 0
  Future<int> getToneForChar(String char) async {
    if (!RegExp(r'[\u4e00-\u9fff]').hasMatch(char)) {
      // Skip if char is not a Chinese character. This check is needed because of prevChar might be null
      return 0; // ?? Default tone for non-Chinese characters or null input
    }    
    try {
      Word word = await WordProvider.getWord(inputWord: char);
      return word.tone;
    } catch (e) {
      // debugPrint('Error fetching tone for character $char: $e');
      // Return a default tone in case of an error
      return 0; // ?? default is not necessary 1, e.g., 不 is 4
    }
  }

  /* 在處理“一”時，若下一個字是
  一聲，用 "0000" 代表 default
  二聲，用 "ss01" 代表
  四聲，用 "ss02" 代表

  在處理“不”時，若下一個字是
  四聲，例如不要，用 “0000” 代表 二聲，default
  二聲，例如不同，用 “ss01” 代表 四聲
  */

  Tuple2<String, bool> getNewToneForYiBu({
      String? prevChar,
      required String currentChar,
      String? nextChar,
      int? prevTone,
      int? nextTone,
  }) {
      // debugPrint('getNewToneForYiBu: prevChar: $prevChar, currentChar: $currentChar, nextChar: $nextChar, prevTone: $prevTone, nextTone: $nextTone');

      const Map<String, Tuple2<String, bool>> specialCases = {
        '禁': Tuple2("0000", false), // 禁平常是四聲，不禁的禁要念一聲
        '菲': Tuple2("0000", false), // 菲平常是一聲，不菲的菲要念三聲
      };

      if (currentChar == '一') {
          /*
          // Check nextChar conditions first
          if (['是', '日', '月', '個', '个', '的', '或'].contains(nextChar) || 
              ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零'].contains(nextChar)) {
              // debugPrint('Skipping next character for 一 based on special nextChar');
              return const Tuple2("0000", true); // Use the default, First tone
          } else if (nextTone != null && (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
              return const Tuple2("ss02", true); // Change to 四聲
          } else if (nextTone != null && nextTone == 4) {
              return const Tuple2("ss01", true); // Change to second tone
          } else {
              return const Tuple2("0000", false); // Default to 一聲 if no other conditions match
          }
          */
          // Check prevChar conditions first
          if (prevChar == null ||
              ['第', '説', '说', '唯', '惟', '统', '統', '独', '獨', '劃', '划', '萬'].contains(prevChar) ||
              ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零'].contains(prevChar)) {
              // debugPrint('Returning first tone for 一 based on special prevChar');
              return const Tuple2("0000", false); // Use the default, First tone
          } else if (nextChar == null ||
                    nextChar.isEmpty ||
                    ['是', '日', '月', '個', '个', '的', '或'].contains(nextChar) ||
                    ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零'].contains(nextChar)) {
              // debugPrint('Skipping $nextChar for 一 based on special nextChar');
              return const Tuple2("0000", true); // Use the default, First tone, and skip the next character
          } else if (nextTone != null && (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
              return const Tuple2("ss02", true); // Change to fourth tone
          } else if (nextTone != null && nextTone == 4) {
              return const Tuple2("ss01", true); // Change to second tone
          } else {
              return const Tuple2("0000", false); // Default to first tone if no other conditions match
          }          
      } else if (currentChar == '不') {
        // debugPrint('Processing 不. nextChar $nextChar, nextTone $nextTone, prevChar $prevChar, prevTone $prevTone');

        if (specialCases.containsKey(nextChar)) {
          // debugPrint('不$nextChar，不 四聲，$nextChar 特殊聲調');
          return specialCases[nextChar]!;
        }

        if (nextTone != null &&
            (nextTone == 1 || nextTone == 2 || nextTone == 3 || nextTone == 5)) {
          // debugPrint('Returning 四聲 for 不 based on nextTone');
          return const Tuple2("0000", true); // Remain 四聲
        } else if (nextTone != null && nextTone == 4) {
          // debugPrint('Returning second tone for 不 based on nextTone');
          return const Tuple2("ss01", true); // Change to second tone
        } else {
          // debugPrint('Returning default 四聲 for 不');
          return const Tuple2("0000", false); // Default to 四聲 if no other conditions match
        }          
      }
      // debugPrint('Error: not 一 nor 不');
      return const Tuple2("0000", false); // Default case
  }


  Future<Tuple2<List<TextSpan>, String>> process(String text, double fontSize, Color color, bool highlightOn) async {
      List<TextSpan> spans = [];
      String spansUnicode = '';
      List<String> characters = text.split('');
      RegExp chineseCharRegex = RegExp(r'[\u4e00-\u9fa5]');
      var ssMapping = {
          "ss01": "E01E1",
          "ss02": "E01E2",
          "ss03": "E01E3",
          "ss04": "E01E4",
          "ss05": "E01E5",
      };

      int length = characters.length; // Cache the length for better performance

      for (int i = 0; i < length; i++) {
          String character = characters[i];
          String hexUnicode = character.runes.first.toRadixString(16).toUpperCase();
          // // debugPrint('Processing character: $character at index $i');

          if (!chineseCharRegex.hasMatch(character)) {
              // debugPrint('Not a Chinese character: $character');
              spans.add(TextSpan(text: character, style: TextStyle(fontSize: fontSize, color: color)));
              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
              continue;
          }

          String nextChar = (i + 1 < length) ? characters[i + 1] : '';
          String prevChar = (i > 0) ? characters[i - 1] : '';
          // debugPrint("prevChar: $prevChar, curChar: $character, nextChar: $nextChar");

          if (character == '一' || character == '不') { // Special handle for 一 and 不
              int prevTone = (i > 0) ? await getToneForChar(prevChar) : 0; // 0: error
              int nextTone = (i + 1 < length) ? await getToneForChar(nextChar) : 0; // 0: error
              // debugPrint("prevTone: $prevTone, nextTone: $nextTone");
              var result = getNewToneForYiBu(
                  prevChar: prevChar,
                  currentChar: character,
                  nextChar: nextChar,
                  prevTone: prevTone,
                  nextTone: nextTone,
              );

              String newSs = result.item1;
              bool skipNext = result.item2;
              // debugPrint("newSs for 一 or 不: $newSs, skipNext: $skipNext");
              spans.add(TextSpan(text: character, style: newSs == "0000" ? getCharStyle(fontSize, color, highlightOn) : getCharPolyStyle(fontSize, color, newSs, highlightOn)));
              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
              if (newSs != "0000") {
                  spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
              }
              
              if (skipNext && i + 1 < length) {
                String nextHexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn))); // Add next character
                spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                // debugPrint("Skipping nextChar $nextChar at index: ${i + 1}");
                i += 1; // Skip the next character since it's part of the phrase
                continue; // Skip to the next loop iteration to avoid processing the skipped character again
              }      
          } else {  // 非“一”或“不”的多音字處理
              var charData = _polyphonicData['data'][character];

              if (charData != null) {
                  List<dynamic>? variations = charData['v'];
                  if (variations != null && variations.isNotEmpty) {
                      List<String> patterns = variations.map((v) => v.toString()).toList();
                      var matchResult = match(character, i, patterns, characters);
                      int matchIndex = matchResult.item1;
                      bool skipNext = matchResult.item2;
                      // debugPrint("matchIndex: $matchIndex, skipNext: $skipNext");

                      if (matchIndex != 0 || skipNext) {
                          String newSs = (matchIndex != 0) ? 'ss0$matchIndex' : '';
                          if (newSs.isNotEmpty) {
                              spans.add(TextSpan(text: character, style: getCharPolyStyle(fontSize, color, newSs, highlightOn)));
                              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                              spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
                          } else {
                              spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                          }

                          if (skipNext && i + 1 < length) {
                              if (character == nextChar && (character == '處' || character == '重')) {
                                  spans.add(TextSpan(text: character, style: getCharPolyStyle(fontSize, color, newSs, highlightOn)));
                                  spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                                  spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
                                  // debugPrint("重重/處處，Skipping $nextChar at index: ${i + 1}");
                                  i += 1; // Skip the next character since it's part of the phrase
                                  continue; // Skip to the next loop iteration to avoid processing the skipped character again
                              } else {
                                  String nextHexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                                  spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn))); // Add next character
                                  spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                                  // debugPrint("Skipping $nextChar at index: ${i + 1}");
                                  i += 1; // Skip the next character since it's part of the phrase
                                  continue; // Skip to the next loop iteration to avoid processing the skipped character again
                              }
                          }
                      } else {
                          spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                          spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                      }
                  } else {
                      spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                      spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                  }
              } else {
                  spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                  spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
              }

          }
      }
      return Tuple2(spans, spansUnicode);
  }


  Tuple2<int, bool> match(String c, int i, List<String> patterns, List<String> text) {
      int defaultIndex = -1;  // To handle empty patterns as fallback
      // debugPrint('Starting match function. Character: $c, Index: $i');

      for (int j = 0; j < patterns.length; j++) {
          String combinedPattern = patterns[j];
          List<String> subPatterns = combinedPattern.split('/');  // Split into sub-patterns
          // // debugPrint('Checking pattern $j: $combinedPattern');

          for (String pattern in subPatterns) {
              if (pattern.isEmpty) {
                  defaultIndex = j;  // Save the index of the empty pattern
                  // // debugPrint('Found empty sub-pattern at index $j');
                  continue;  // Continue to check other patterns
              }

              int pos = pattern.indexOf('*');
              if (pos == -1 || i - pos < 0 || i - pos + pattern.length > text.length) {
                  // // debugPrint('Skipping sub-pattern due to no "*" or out of bounds. Sub-Pattern: $pattern, Position: $pos, Pattern Length: ${pattern.length}');
                  continue;  // Skip if no '*' found or out of bounds
              }

              String tmp = '';
              for (int z = i - pos; z < i - pos + pattern.length; z++) {
                  if (z >= text.length) {
                      // debugPrint('Out of bounds when constructing substring for $pattern. Breaking out.');
                      break;  // Ensure not to go out of text bounds
                  }
                  tmp += text[z];
              }
              // // debugPrint('Constructed substring for sub-pattern: $tmp');

              if (tmp == pattern.replaceAll('*', c)) {
                  // debugPrint('Sub-pattern matched: $pattern');
                  return Tuple2(j, pattern.contains('*'));  // Return the index of the matching pattern and skipNext flag
              }
          }
      }
      // debugPrint('No pattern matched. Returning default index: ${defaultIndex != -1 ? defaultIndex : 0}');
      return Tuple2(defaultIndex != -1 ? defaultIndex : 0, false);  // Return the index of an empty pattern or 0 if no match
  }

}