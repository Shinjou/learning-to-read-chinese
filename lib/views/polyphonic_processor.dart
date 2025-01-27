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
      // debugPrint('Polyphonic data loaded successfully');
    } catch (e) {
      // debugPrint('Failed to load polyphonic data: $e');
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
      debugPrint('Error fetching tone for character $char: $e');
      // Return a default tone in case of an error
      return 0; // ?? default is not necessary 1, e.g., 不 is 4
    }
  }

  /* 在處理“一”時，若最後是
  一聲，用 "0000" 代表 default
  二聲，用 "ss01" 代表
  四聲，用 "ss02" 代表

  在處理“不”時，若最後是
  四聲，用 “0” 代表 default
  二聲，用 “ss01” 代表 
  */
  String getNewToneForYiBu({
    String? prevChar,
    required String currentChar,
    String? nextChar,
    int? prevTone,
    int? nextTone,
  }) {
    debugPrint('getNewToneForYiBu: prevChar: $prevChar, currentChar: $currentChar, nextChar: $nextChar, prevTone: $prevTone, nextTone: $nextTone');

    if (currentChar == '一') {
      // debugPrint('Processing tone sandhi for 一');
      // Check conditions for maintaining the original tone
      if (prevChar == null ||
          nextChar == null ||
          nextChar.isEmpty ||
          ['是', '日', '月', '個', '个', '的', '或'].contains(nextChar) ||
          ['第', '説', '说', '唯', '惟', '统', '統', '独', '獨', '劃', '划']
              .contains(prevChar) ||
          ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零']
              .contains(prevChar) ||
          ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零']
              .contains(nextChar)) {
        // debugPrint('Returning first tone for 一 based on special conditions');
        return "0000"; // Use the default, First tone
      } else if (nextTone != null &&
          (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
        // debugPrint('Returning fourth tone for 一 based on nextTone');
        return "ss02"; // Change to fourth tone
      } else if (nextTone != null && nextTone == 4) {
        // debugPrint('Returning second tone for 一 based on nextTone');
        return "ss01"; // Change to second tone
      } else {
        // debugPrint('Returning default first tone for 一');
        return "0000"; // Default to first tone if no other conditions match
      }
    } else if (currentChar == '不') {
      // debugPrint('Processing tone sandhi for 不');
      if (nextChar == '禁') { // 不禁 special case
        // debugPrint('不禁，不 fourth tone，禁 first tone');
        return "0000"; // Remain fourth tone
      }
      if (nextTone != null &&
          (nextTone == 1 || nextTone == 2 || nextTone == 3 || nextTone == 5)) {
        // debugPrint('Returning fourth tone for 不 based on nextTone');
        return "0000"; // Remain fourth tone
      } else if (nextTone != null && nextTone == 4) {
        // debugPrint('Returning second tone for 不 based on nextTone');
        return "ss01"; // Change to second tone
      } else {
        // debugPrint('Returning default fourth tone for 不');
        return "0000"; // Default to fourth tone if no other conditions match
      }
    }
    debugPrint('Error: not 一 nor 不');
    return "0000"; 
  }

  Future<Tuple2<List<TextSpan>, String>> process(String text, double fontSize, Color color, bool highlightOn) async {
    List<TextSpan> spans = [];
    String spansUnicode = '';
    // Map<int, dynamic> textinfo = {};
    List<String> characters = text.split('');
    // This regular expression matches any Chinese character
    RegExp chineseCharRegex = RegExp(r'[\u4e00-\u9fa5]');
    var ssMapping = {
      "ss01": "E01E1",
      "ss02": "E01E2",
      "ss03": "E01E3",
      "ss04": "E01E4",
      "ss05": "E01E5",
    };
    String newSs = "ss00"; // must be 4 characters

    for (int i = 0; i < characters.length; i++) {
      String character = characters[i];
      String hexUnicode = character.runes.first.toRadixString(16).toUpperCase();

      // Proceed only if the character is a valid Chinese character
      if (!chineseCharRegex.hasMatch(character)) {
        spans.add(TextSpan(text: character, style: TextStyle(fontSize: fontSize, color: color)));
        spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
        debugPrint('Not a Chinese character: $character');
        continue;
      }


      String nextChar = (i + 1 < characters.length) ? characters[i + 1] : '';
      String prevChar = (i > 0) ? characters[i - 1] : '';
      debugPrint("Processing character: $character at index $i, prevChar: $prevChar, nextChar: $nextChar");

      if (character == '一' || character == '不') { // Special handle for 一 and 不
        int prevTone = (i > 0) ? await getToneForChar(prevChar) : 0; // 0: error
        int nextTone =
            (i + 1 < characters.length) ? await getToneForChar(nextChar) : 0; // 0: error
        newSs = getNewToneForYiBu(
          prevChar: prevChar,
          currentChar: character,
          nextChar: nextChar,
          prevTone: prevTone,
          nextTone: nextTone,
        );
        if (newSs == "0000") {  // If default,
          spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
          spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
          // debugPrint('YiBu default: $spans');
        } else {  // not default. Use newSs
          // debugPrint('YiBu not default. newSs = $newSs');
          spans.add(TextSpan(text: character, style: getCharPolyStyle(fontSize, color, newSs, highlightOn)));
          if (newSs != "0000") {
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
            spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
          } else {
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
          }
        }
      } else {  // 非“一”或“不”的多音字處理
        
        var charData = _polyphonicData['data'][character];
        // debugPrint('Processing character: $character at index $i, prevChar: $prevChar, nextChar: $nextChar');
        // debugPrint('non-YiBu: charData: $charData');
        if (charData != null) {
            List<dynamic>? variations = charData['v'];
            if (variations != null && variations.isNotEmpty) {
                List<String> patterns = variations.map((v) => v.toString()).toList();  // Convert variations to a list of strings
                int matchIndex = match(character, i, patterns, characters);

                if (matchIndex != 0) {
                    String newSs = 'ss0$matchIndex';
                    // debugPrint('non-YiBu: matched. SS: $newSs');
                    spans.add(TextSpan(text: character, style: getCharPolyStyle(fontSize, color, newSs, highlightOn)));
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
                } else {
                    spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    // debugPrint('non-YiBu: not matched or using default SS');
                }
            } else { // if variations == null or variations.isEmpty
                spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
                spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                // debugPrint('non-YiBu: variations are null. Use default SS');
            }
        } else { // if charData == null
            spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn)));
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
            // debugPrint('non-YiBu: charData is null. Use default SS');
        }
      }
    }
    // debugPrint('final spans: $spans');
    return Tuple2(spans, spansUnicode);
  }

  int match(String c, int i, List<String> patterns, List<String> text) {
      int defaultIndex = -1;  // To handle empty patterns as fallback
      // debugPrint('Starting match function. Character: $c, Index: $i');

      for (int j = 0; j < patterns.length; j++) {
          String combinedPattern = patterns[j];
          List<String> subPatterns = combinedPattern.split('/');  // Split into sub-patterns
          // debugPrint('Checking pattern $j: $combinedPattern');

          for (String pattern in subPatterns) {
              if (pattern.isEmpty) {
                  defaultIndex = j;  // Save the index of the empty pattern
                  // debugPrint('Found empty sub-pattern at index $j');
                  continue;  // Continue to check other patterns
              }

              int pos = pattern.indexOf('*');
              if (pos == -1 || i - pos < 0 || i - pos + pattern.length > text.length) {
                  // debugPrint('Skipping sub-pattern due to no "*" or out of bounds. Sub-Pattern: $pattern, Position: $pos, Pattern Length: ${pattern.length}');
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
              // debugPrint('Constructed substring for sub-pattern: $tmp');

              if (tmp == pattern.replaceAll('*', c)) {
                  // debugPrint('Sub-pattern matched: $pattern');
                  return j;  // Return the index of the matching pattern
              }
          }
      }
      // debugPrint('No pattern matched. Returning default index: ${defaultIndex != -1 ? defaultIndex : 0}');
      return defaultIndex != -1 ? defaultIndex : 0;  // Return the index of an empty pattern or 0 if no match
  }

  
}

