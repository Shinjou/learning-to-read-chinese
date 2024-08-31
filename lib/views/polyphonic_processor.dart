// polyphonic_processor.dart
// import 'dart:convert';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:path/path.dart';
import 'package:tuple/tuple.dart';

import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';

class PolyphonicProcessor {
  late Map<String, dynamic> _polyphonicData;
  String spansUnicode = '';
  // bool skipPrev = false;  moved to process function
  RegExp chineseCharRegex = RegExp(r'[\u4e00-\u9fa5]');

  static final PolyphonicProcessor _instance = PolyphonicProcessor._internal();

  PolyphonicProcessor._internal();

  static PolyphonicProcessor get instance => _instance;

  Future<void> loadPolyphonicData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data_files/poyin_db.json');
      Map<String, dynamic> polyphonicData = json.decode(jsonString);

      if (!polyphonicData.containsKey('data')) {
        throw Exception('Polyphonic data is improperly formatted or missing key data');
      }

      _polyphonicData = removeComments(polyphonicData);

      // debugPrint('Polyphonic data loaded successfully');
    } catch (e) {
      // debugPrint('Failed to load polyphonic data: $e');
      throw Exception('Failed to load polyphonic data: $e');
    }
  }

  Map<String, dynamic> removeComments(Map<String, dynamic> data) {
    Map<String, dynamic> filteredData = {};
    data.forEach((key, value) {
      if (key != '_comment') {
        if (value is Map<String, dynamic>) {
          filteredData[key] = removeComments(value);
        } else if (value is List) {
          filteredData[key] = value.map((item) {
            if (item is Map<String, dynamic>) {
              return removeComments(item);
            }
            return item;
          }).toList();
        } else {
          filteredData[key] = value;
        }
      }
    });
    return filteredData;
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

  /* 
  “一”有三個音：一聲、二聲、四聲。在處理“一”時，若下一個字是
  一聲，“一”為一聲，用 "0000" 代表 default
  二聲，“一”為二聲，用 "ss01" 代表
  四聲，“一”為四聲，用 "ss02" 代表
  有些字，例如“個”，也是多音，需要特別處理“一個”。

  “不”有四個音：四聲、二聲、fou、fu。在處理“不”時，若下一個字是
  四聲，例如不要，用 “0000” 代表 二聲，default
  二聲，例如不同，用 “ss01” 代表 四聲
  有些字，例如“禁”，也是多音，需要特別處理“不禁”。
  */

  Tuple3<String, bool, bool> getNewToneForYiBu({
      String? prevChar,
      required String currentChar,
      String? nextChar,
      int? prevTone,
      int? nextTone,
      required bool skipPrev,
  }) {
      // debugPrint('getNewToneForYiBu: prevChar: $prevChar, currentChar: $currentChar, nextChar: $nextChar, prevTone: $prevTone, nextTone: $nextTone');
      const Map<String, Tuple3<String, bool, bool>> specialYiCases = {
        '個': Tuple3("0000", false, false), // 個平常是四聲，一個的個要念輕聲，一念一聲，個這個字下一次處理
        '个': Tuple3("0000", false, false), // 個平常是四聲，一个的个要念輕聲，一念一聲，个這個字下一次處理
        '會': Tuple3("0000", false, false), // 會平常是四聲，一會的會要念“悔”三聲，一念一聲，會這個字下一次處理
        '切': Tuple3("0000", false, false), // 切平常是一聲，一切的切念四聲，一念一聲，切這個字下一次處理
      };

      const Map<String, Tuple3<String, bool, bool>> specialBuCases = {
        '禁': Tuple3("0000", false, false), // 禁平常是四聲，不禁的禁要念一聲，不念四聲，禁這個字下一次處理
        '菲': Tuple3("0000", false, false), // 菲平常是一聲，不菲的菲要念三聲，不念四聲，菲這個字下一次處理
        '勝': Tuple3("0000", false, false), // 勝平常是四聲，不勝的勝要念一聲，不念四聲，勝這個字下一次處理
        '著': Tuple3("0000", false, false), // 著平常是一聲，不著的著要念二聲，不念四聲，著這個字下一次處理
        '了': Tuple3("0000", false, false), // 了平常是輕聲，在“吃不了"時，念三聲，不念四聲，了這個字下一次處理
      };

      if (currentChar == '一') {
        // Check prevChar conditions, then nextChar special conditions, then general cases
        if ((!skipPrev) && (prevChar == null ||
          ['第', '説', '说', '唯', '惟', '统', '統', '独', '獨', '劃', '划', '萬', '專'].contains(prevChar) ||
          ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零'].contains(prevChar))) {
          // debugPrint('Returning first tone for 一 based on special prevChar');
          return const Tuple3("0000", false, true); // Use the default, First tone
        } else if (specialYiCases.containsKey(nextChar)) {
          // check if nextChar is in specialYiCases
          // debugPrint('一$nextChar，一 一聲，$nextChar 特殊聲調');
          return specialYiCases[nextChar]!;
        } else if (nextChar == null || nextChar.isEmpty ||
            ['是', '日', '月', '的', '或', '物', '片', '系'].contains(nextChar) ||
            ['十', '九', '八', '七', '六', '五', '四', '三', '二', '〇', '零', '千'].contains(nextChar)) {
          // debugPrint('Skipping $nextChar for 一 based on special nextChar');
          return const Tuple3("0000", true, true); // Use the default, First tone, and skip the next character
        } else if (nextTone != null && (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
          return const Tuple3("ss02", true, true); // Change to fourth tone
        } else if (nextTone != null && nextTone == 4) {
          return const Tuple3("ss01", true, true); // Change to second tone
        } else {
          return const Tuple3("0000", false, true); // Default to first tone if no other conditions match
        }          
      } else if (currentChar == '不') {
        // debugPrint('Processing 不. nextChar $nextChar, nextTone $nextTone, prevChar $prevChar, prevTone $prevTone');

        if (specialBuCases.containsKey(nextChar)) {
          // debugPrint('不$nextChar，不 四聲，$nextChar 特殊聲調');
          return specialBuCases[nextChar]!;
        }

        if (nextTone != null &&
            (nextTone == 1 || nextTone == 2 || nextTone == 3 || nextTone == 5)) {
          // debugPrint('Returning 四聲 for 不 based on nextTone');
          return const Tuple3("0000", true, true); // Remain 四聲
        } else if (nextTone != null && nextTone == 4) {
          // debugPrint('Returning second tone for 不 based on nextTone');
          return const Tuple3("ss01", true, true); // Change to second tone
        } else {
          // debugPrint('Returning default 四聲 for 不');
          return const Tuple3("0000", false, true); // Default to 四聲 if no other conditions match
        }          
      }
      // debugPrint('Error: not 一 nor 不. $currentChar');
      return const Tuple3("0000", false, false); // Default case
  }


  Future<Tuple2<List<TextSpan>, String>> process(String text, double fontSize, Color color, bool highlightOn) async {
      List<TextSpan> spans = [];
      String spansUnicode = '';
      List<String> characters = text.split('');
      int length = characters.length; // Cache the length for better performance
      bool skipPrev = false; // Flag to skip the previous character processing
      var ssMapping = {
          "ss01": "E01E1",
          "ss02": "E01E2",
          "ss03": "E01E3",
          "ss04": "E01E4",
          "ss05": "E01E5",
      };
      final Map<String, String> specialDoubleCharacters = {
        '一一': 'ss00', // “一”在前面已處理，不會在這裡用到
        '仆仆': 'ss01',
        '便便': 'ss01',
        '剌剌': 'ss01',
        '厭厭': 'ss01',
        '呀呀': 'ss01',
        '呱呱': 'ss00',
        '咯咯': 'ss01',
        '啞啞': 'ss01',
        '啦啦': 'ss01',
        '喔喔': 'ss00',
        '嗑嗑': 'ss01',
        '嚇嚇': 'ss01',
        '好好': 'ss00',
        '從從': 'ss03',
        '怔怔': 'ss01',
        '悶悶': 'ss01',
        '擔擔': 'ss01',
        '數數': 'ss01',
        '施施': 'ss01',
        '晃晃': 'ss01',
        '朴朴': 'ss02',
        '棲棲': 'ss01',
        '殷殷': 'ss01',
        '比比': 'ss01',
        '泄泄': 'ss01',
        '洩洩': 'ss01',
        '湛湛': 'ss00',
        '湯湯': 'ss01',
        '濕濕': 'ss02',
        '濟濟': 'ss01',
        '濺濺': 'ss01',
        '父父': 'ss02',
        '種種': 'ss00',
        '答答': 'ss01',
        '粥粥': 'ss02',
        '累累': 'ss01',
        '繆繆': 'ss02',
        '脈脈': 'ss01',
        '菲菲': 'ss00',
        '蔚蔚': 'ss01',
        '藉藉': 'ss01',
        '虎虎': 'ss01',
        '處處': 'ss01',
        '蛇蛇': 'ss01',
        '行行': 'ss00', // 行行重行行/行行好事，行行出狀元，行行如也，念法都不同
        '褶褶': 'ss01', // 褶褶有兩個念法：die2die2，zhe3zhe3，目前只處理die2die2
        '逮逮': 'ss00', 
        '那那': 'ss01',                
        '重重': 'ss01', // 重重的，重重阻礙，念法不同
        '銻銻': 'ss02',
        '鰓鰓': 'ss01',
        '個個': 'ss00', // 個個或一個個，都發四聲，因此需要提前處理。
        '个个': 'ss00',
        '大大': 'ss00',
        '方方': 'ss00', 
      };      
      // "多"會造成下面句子很難判斷，因此特別處理。”他任內完成了許多重要工作。“，”壓力很大，要從多重管道接觸客戶。“      
      final List<String> duoCommonPhrases = ['許多', '很多', '大多', '眾多', '太多', '極多', '何多', '沒多', '甚多', '更多', '幾多',/* Add more common phrases here if needed */];      

      for (int i = 0; i < length; i++) {
          String character = characters[i];
          String hexUnicode = character.runes.first.toRadixString(16).toUpperCase();
          String nextChar = (i + 1 < length) ? characters[i + 1] : '';
          String next2Char = (i + 2 < length) ? characters[i + 2] : '';
          String next3Char = (i + 3 < length) ? characters[i + 3] : '';
          String prevChar = (i > 0) ? characters[i - 1] : '';
          // debugPrint("prevChar: $prevChar, curChar: $character, nextChar: $nextChar");          
          bool skipPrevTemp = skipPrev; // Save the current skipPrev value
          skipPrev = false; // Reset skipPrev for the next character          
          // debugPrint('Processing character: $character at index $i, skipPrev: $skipPrevTemp');

          if (!chineseCharRegex.hasMatch(character)) {
              // debugPrint('Not a Chinese character: $character');
              spans.add(TextSpan(text: character, style: TextStyle(fontSize: fontSize, color: color)));
              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
              skipPrev = true; // 非中文字，處理下一個字時，不需要回頭看
              continue;
          }

          if (character == '一' || character == '不') { // Special handle for 一 and 不
            // Handle special cases for "一“ and "不" where the third character is a polyphonic character
            if (character == '一') { // 一部、一部分、一會、一會兒
                if (nextChar == '部') { 
                    // Handle "一部" with default tone for both "一" and "部"
                    spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn))); // Default for "一"
                    hexUnicode = character.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));

                    spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn))); // Default for "部"
                    hexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));

                    if (next2Char == '分') {
                        // Handle "一部分" with 四聲 for "分"
                        String styleSet = 'ss01'; // 四聲 for "分"
                        spans.add(TextSpan(text: next2Char, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                        hexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                        spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                        spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));

                        i += 2; // Skip the next 2 characters
                    } else {
                        i += 1; // Skip the next character
                    }
                    continue;
                } else if (nextChar == '會') {
                    // Handle "一會" with default tone for "一" and 三聲 for "會"
                    spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn))); // Default for "一"
                    hexUnicode = character.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));

                    String styleSet = 'ss02'; // 三聲 for "會"
                    spans.add(TextSpan(text: nextChar, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                    hexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));                    

                    if (next2Char == '兒') {
                        String styleSet = 'ss01'; // 一會兒，輕聲 for "兒"
                        spans.add(TextSpan(text: next2Char, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                        hexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                        spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                        spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));

                        i += 2; // Skip the next 2 characters
                    } else {
                        i += 1; // Skip the next character
                    }
                    continue;
                }
            }

            if (character == '不') { // 不得不、不一定
                if (nextChar == '得' && next2Char == '不') {
                    // Handle "不得不" 都是用 default tone
                    for (String char in [character, nextChar, next2Char]) {
                        spans.add(TextSpan(text: char, style: getCharStyle(fontSize, color, highlightOn)));
                        hexUnicode = char.runes.first.toRadixString(16).toUpperCase();
                        spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    }                
                    i += 2; // Skip the next 2 characters 
                    skipPrev = true; // This is a complete phrase, so when processing the next character, we don't have to look back
                    continue;
                } else if (nextChar == '一' && next2Char == '定') {
                    // Handle "不一定"
                    spans.add(TextSpan(text: character, style: getCharStyle(fontSize, color, highlightOn))); // Default for "不"
                    hexUnicode = character.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));

                    String styleSet = 'ss01'; // 二聲 for "一"
                    spans.add(TextSpan(text: nextChar, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                    hexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));

                    spans.add(TextSpan(text: next2Char, style: getCharStyle(fontSize, color, highlightOn))); // Default for "定"
                    hexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    
                    i += 2; // Skip the next 2 characters 
                    skipPrev = true; // This is a complete phrase, so when processing the next character, we don't have to look back
                    continue;
                }
            }

            int prevTone = (i > 0) ? await getToneForChar(prevChar) : 0; // 0: error
            int nextTone = (i + 1 < length) ? await getToneForChar(nextChar) : 0; // 0: error
            // debugPrint("prevChar: $prevChar, prevTone: $prevTone; nextChar: $nextChar, nextTone: $nextTone");
            var result = getNewToneForYiBu(
                prevChar: prevChar,
                currentChar: character,
                nextChar: nextChar,
                prevTone: prevTone,
                nextTone: nextTone,
                skipPrev: skipPrevTemp,
            );

            String newSs = result.item1;
            bool skipNext = result.item2;
            skipPrev = result.item3; // 一* 或 *一，或 不*, 在處理下一個字時，都不需要回頭看
            // debugPrint("newSs for $character: $newSs, skipNext: $skipNext, skipPrev: $skipPrev");
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
              // Check for special double characters. For single character, call "match" function
              // 個個或一個個，都發四聲，因此需要提前處理。
              // 目前的 code 可以處理下面的情況：個個都是英雄好漢，一個個都是美女，他是個性情中人。但是無法處理下面的情況：
              // 一個個性溫柔的人，他是個個性溫柔的人。需要把這兩句改成：一位個性溫柔的人，他是位個性溫柔的人。              
              String pair = character + nextChar;
              int setNextBpmf = 0;
              String next2CharStyleSet = '';
              String next3CharStyleSet = '';
              
              if (specialDoubleCharacters.containsKey(pair)) {
                String nextPair = next2Char + next3Char;
                String styleSet = specialDoubleCharacters[pair]!;
                if (pair == '重重' && next2Char == '的') {  // 重重的，重發四聲，
                  styleSet = 'ss00';
                  setNextBpmf = 1; // 加速處理'的'
                } else if (pair == '行行') {
                  if (nextPair == '出狀') {
                    styleSet = 'ss01';
                    setNextBpmf = 2; // 加速處理'出狀'
                  } else if (nextPair == '重行') {
                    styleSet = 'ss00'; // 行行重行, 重是二聲，需特別處理
                    setNextBpmf = 2; // 加速處理'重行'
                    next2CharStyleSet = 'ss01'; // 重行重行，行是四聲，需特別處理
                  } else if (nextPair == '如也') {
                    styleSet = 'ss03';
                    setNextBpmf = 2; // 加速處理'如也'
                  }
                } else if (pair == '呱呱' && (nextPair == '墜地' || nextPair == '墮地' || nextPair == '而泣')) {  // 哇哇墜地，呱呱而泣ad個發四聲，
                  styleSet = 'ss01';
                  setNextBpmf = 2; // 加速處理'墜地'、'墮地'、'而泣'                  
                }

                String nextHexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                // debugPrint("$pair: applied style $styleSet");
                if (styleSet == 'ss00') {
                  // For 'ss00' style set, use the default getCharStyle
                  spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn)));
                  spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn)));
                  spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                  spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                } else {
                  // For other style sets, use getCharPolyStyle
                  spans.add(TextSpan(text: nextChar, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                  spans.add(TextSpan(text: nextChar, style: getCharPolyStyle(fontSize, color, styleSet, highlightOn)));
                  spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                  spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));
                  spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                  spansUnicode += String.fromCharCode(int.parse(ssMapping[styleSet]!.substring(0, 5), radix: 16));
                }
                i += 1; // Skip the next character since it's part of the phrase
                skipPrev = true; // 這是一個完整的詞語，所以在處理下一個字時，不需要回頭看

                switch (setNextBpmf) { // 加速處理下面二、三個字
                  case 0:
                    // Skip this iteration if setNextBpmf == 0
                    break;

                  case 1:
                    spans.add(TextSpan(text: next2Char, style: getCharStyle(fontSize, color, highlightOn)));
                    nextHexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                    // debugPrint('Fast processing $next2Char using default at index: ${i + 1}');
                    i += 1;
                    break;

                  case 2:
                    if (next2CharStyleSet == '') {
                      spans.add(TextSpan(text: next2Char, style: getCharStyle(fontSize, color, highlightOn)));
                      nextHexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                      spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                    } else {
                      spans.add(TextSpan(text: next2Char, style: getCharPolyStyle(fontSize, color, next2CharStyleSet, highlightOn)));
                      nextHexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                      spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                      spansUnicode += String.fromCharCode(int.parse(ssMapping[next2CharStyleSet]!.substring(0, 5), radix: 16));
                    }
                    if (next3CharStyleSet == '') {
                      spans.add(TextSpan(text: next3Char, style: getCharStyle(fontSize, color, highlightOn)));
                      nextHexUnicode = next3Char.runes.first.toRadixString(16).toUpperCase();
                      spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                    } else {
                      spans.add(TextSpan(text: next3Char, style: getCharPolyStyle(fontSize, color, next3CharStyleSet, highlightOn)));
                      nextHexUnicode = next3Char.runes.first.toRadixString(16).toUpperCase();
                      spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                      spansUnicode += String.fromCharCode(int.parse(ssMapping[next3CharStyleSet]!.substring(0, 5), radix: 16));
                    }
                    // debugPrint('Fast processing $next2Char and $next3Char at index: ${i + 1} and ${i + 2}');
                    i += 2; // Skip the next character since it's part of the phrase
                    break;

                  default:
                    // Handle any unexpected values if necessary
                    // debugPrint('Unexpected setNextBpmf value: $setNextBpmf');
                    break;
                }
                continue; // Skip to the next loop iteration to avoid processing the skipped character again
              }

              List<dynamic>? variations = charData['v'];
              if (variations != null && variations.isNotEmpty) {
                  List<String> patterns = variations.map((v) => v.toString()).toList();
                  var matchResult = match(character, i, patterns, characters, skipPrev: skipPrevTemp);
                  int matchIndex = matchResult.item1;
                  bool skipNext = matchResult.item2;
                  skipPrev = matchResult.item3;              
                  // debugPrint("matchIndex: $matchIndex, skipNext: $skipNext, skipPrev: $skipPrev");

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
                      String nextHexUnicode = nextChar.runes.first.toRadixString(16).toUpperCase();
                      spans.add(TextSpan(text: nextChar, style: getCharStyle(fontSize, color, highlightOn))); // Add next character
                      spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                      // debugPrint("Skipping $nextChar at index: ${i + 1}");
                      i += 1; // Skip the next character since it's part of the phrase
                      continue; // Skip to the next loop iteration to avoid processing the skipped character again
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
              // Check if the prevChar and character are in the common phrases list. If so, set skipPrev to true
              String phrase = prevChar + character;
              if (duoCommonPhrases.contains(phrase)) {
                skipPrev = true; // This is a common phrase, so when processing the next character, we don't have to look back
                // debugPrint('Common phrase found: $phrase, setting skipPrev to true');
              } else {
                skipPrev = false; // 目前的字沒有多音字，但是下一個字可能會有，因此要設 false。
              }
            }

          }
      }
      return Tuple2(spans, spansUnicode);
  }

  Tuple3<int, bool, bool> match(String character, int index, List<String> patterns, List<String> text, {bool skipPrev = false}) {
    int defaultIndex = -1; // To handle empty patterns as fallback
    String prev2Char = (index > 1) ? text[index - 2] : '';
    String prevChar = (index > 0) ? text[index - 1] : '';
    String threeCharPhrase = prev2Char + prevChar + character;
    String nextChar = (index + 1 < text.length) ? text[index + 1] : '';
    bool isFirstChar = (prevChar == '' || !isChineseCharacter(prevChar)) ? true : false;
    bool isLastChar = (nextChar == '' || !isChineseCharacter(nextChar)) ? true : false;
    bool isStandalone = (text.length == 1) || (isFirstChar && isLastChar);
    bool skipNext = false; // Flag to skip the next character processing
    final List<String> noSkipNextCharacters = ['骨頭', '參與', '參差', '檻車', '爪子', '度量',/* 這裡要列出兩個字都是多音字，而且第二個字的發音不是default */];

    // debugPrint('Starting match function. Character: $character, prevChar: $prevChar, nextChar: $nextChar, patterns: $patterns, skipPrev: $skipPrev');

    if (isStandalone) {
      // debugPrint('Character $character is standalone. Returning default index.');
      return const Tuple3(0, false, true); // Return default tone index with proper skip flags set
    }

    // Special handle for '地' with 'de5' sound
    final Set<String> phrasesEndsWithDi = {
      '一十地', '大方地', '大聲地', '小心地', '小聲地', '不休地', '不安地', 
      '不倦地', '不停地', '不堪地', '不絕地', '不諱地', '不斷地', '亢奮地', 
      '仔細地', '叨叨地', '可憐地', '巧妙地', '平整地', '正當地', '正經地', 
      '生氣地', '生動地', '示弱地', '交替地', '吁吁地', '合適地', '吐吐地', 
      '如實地', '安靜地', '忙碌地', '成功地', '有味地', '有效地', '自主地', 
      '自由地', '自在地', '自信地', '自然地', '下氣地', '低聲地', '克難地', 
      '冷漠地', '吾吾地', '均勻地', '完整地', '忘我地', '快速地', '快樂地', 
      '抖擻地', '決然地', '牢固地', '狂暴地', '狂熱地', '甫定地', '迅速地', 
      '屈膝地', '周到地', '呱呱地', '和藹地', '坦率地', '委婉地', '怯步地', 
      '所能地', '易舉地', '虎嚥地', '采烈地', '勇敢地', '思索地', '急速地', 
      '筍般地', '耐心地', '重複地', '飛快地', '容易地', '恣意地', '悄悄地', 
      '特別地', '特定地', '真實地', '秘密地', '虔誠地', '究柢地', '高興地', 
      '乾脆地', '停蹄地', '偷偷地', '堅定地', '堅強地', '堅毅地', '專注地', 
      '康康地', '強烈地', '得意地', '悠悠地', '悠揚地', '悠閒地', '情願地', 
      '授權地', '敏感地', '敏銳地', '淡寫地', '深刻地', '深深地', '清楚地', 
      '甜甜地', '細心地', '許可地', '尊敬地', '悲傷地', '惺忪地', '愉快地', 
      '無私地', '無償地', '猶豫地', '痛苦地', '絮絮地', '間斷地', '意外地', 
      '意料地', '準確地', '溫柔地', '煞氣地', '痴痴地', '經意地', '詳細地', 
      '誠意地', '誠懇地', '嘆氣地', '慢慢地', '慣性地', '漂亮地', '漸漸地', 
      '瘋狂地', '盡力地', '盡瘁地', '緊緊地', '輕盈地', '輕微地', '輕輕地', 
      '輕聲地', '遠遠地', '嘩啦地', '熟慮地', '熟練地', '熱心地', '熱情地', 
      '範圍地', '緩慢地', '緩緩地', '踏實地', '整齊地', '激動地', '興奮地', 
      '諱言地', '錯誤地', '隨意地', '靜靜地', '靦腆地', '默默地', '優雅地', 
      '翼翼地', '闊步地', '禮貌地', '簡單地', '謹慎地', '穩固地', '穩穩地', 
      '嚴厲地', '歡快地', '驕傲地', '驚恐地', '靈活地', '究底地', '大大地',
    };

    if (character == '地') {
      if (phrasesEndsWithDi.contains(threeCharPhrase)) {
        // debugPrint('“$threeCharPhrase” pattern matched. 地的發音是"de5".');
        return const Tuple3(1, false, true); // de5
      } else {
        // debugPrint('“$threeCharPhrase” pattern NO matched. 地的發音是"di4".');
        return const Tuple3(0, false, true); // di4
      }
    }

    if (character == '著') {
      // Check if the neighbor characters are "著作權"
      String secondLine = patterns.length > 1 ? patterns[1] : '';
      if (index >= 0 && index + 2 < text.length) {
        String prefix = character + text[index + 1] + text[index + 2];
        if (prefix == "著作權") {
          // debugPrint('Special pattern "著作權" matched');
          skipNext = false; // Set skipNext to false if a pattern is matched
          skipPrev = false; // Set skipPrev to true if a pattern is matched
          return Tuple3(patterns.indexOf(secondLine), skipNext, skipPrev);
        }
      }
    }

    // First pass: Checking all patterns for "any+*" or "any+*+any"
    if (isFirstChar || skipPrev) {
      // debugPrint('isFirstChar: $isFirstChar or skipPrev: $skipPrev is true. Skipping the first pass, i.e., any+$character');
    } else {
      // debugPrint('First pass for $character: Checking patterns for "any+* or "any+*+any"');
      for (int j = 0; j < patterns.length; j++) {
        String combinedPattern = patterns[j];
        List<String> subPatterns = combinedPattern.split('/'); // Split into sub-patterns
        // debugPrint('First pass - combinedPattern $j: $combinedPattern, subPatterns: $subPatterns');

        for (String pattern in subPatterns) {
          // debugPrint('First pass - Checking ($prevChar+$character) in subPatterns: $pattern');
          if (pattern.isEmpty) {
            defaultIndex = j; // Save the index of the empty pattern
            // debugPrint('Empty pattern, setting defaultIndex to $j');
            continue; // Continue to check other patterns
          }

          if (pattern.startsWith('*')) {
            // debugPrint('Skipping sub-pattern as it starts with "*": $pattern');
            continue; // Skip if not starting with '*'
          }

          int pos = pattern.indexOf('*');
          if (pos == -1) {
            // debugPrint('Skipping sub-pattern as no "*" found: $pattern');
            continue; // Skip if no '*' found
          }

          int start = index - pos;
          int end = index - pos + pattern.length;
          if (start < 0 || end > text.length) {
            // debugPrint('Skipping sub-pattern as out of bounds: $pattern, start: $start, end: $end, text length: ${text.length}');
            continue; // Skip if out of bounds
          }

          if (matchPattern(pattern, pos, start, end, text, character)) {
            skipNext = false; // Set skipNext to false if a pattern is matched
            skipPrev = true; // Set skipPrev to true if a pattern is matched
            // debugPrint('Sub-pattern matched (any+*) ($prevChar+$character): $pattern, $j, skipNext: $skipNext, skipPrev: $skipPrev');
            return Tuple3(j, skipNext, skipPrev); // Returning with skipNext=false, skipPrev=true
          }
        }
      }
    }

    // Second pass: Checking patterns for "*+any"
    if (isLastChar) {
      // debugPrint('Last character. Skip the second pass for $character');
    } else {
      // debugPrint('Second pass for $character: Checking patterns for "*+any"');
      for (int j = 0; j < patterns.length; j++) {
        String combinedPattern = patterns[j];
        List<String> subPatterns = combinedPattern.split('/'); // Split into sub-patterns
        // debugPrint('Second pass - combinedPattern $j: $combinedPattern, subPatterns: $subPatterns');

        for (String pattern in subPatterns) {
          // debugPrint('Second pass - Checking sub-pattern: $pattern');
          if (pattern.isEmpty) {
            defaultIndex = j; // Save the index of the empty pattern
            // debugPrint('Empty pattern, setting defaultIndex to $j');
            continue; // Skip empty patterns
          }

          if (!pattern.startsWith('*')) {
            // debugPrint('Skipping sub-pattern as it does not start with $character: $pattern');
            continue; // Skip if not starting with '*'
          }

          int pos = pattern.indexOf('*');
          if (pos == -1) {
            // debugPrint('Skipping sub-pattern as no "*" found: $pattern');
            continue; // Skip if no '*' found
          }

          int start = index - pos;
          int end = index - pos + pattern.length;
          if (start < 0 || end > text.length) {
            // debugPrint('Skipping sub-pattern as out of bounds: $pattern, start: $start, end: $end, text length: ${text.length}');
            continue; // Skip if out of bounds
          }

          if (matchPattern(pattern, pos, start, end, text, character)) {
            if (isPolyphonicChar(nextChar)) { // 如果目前的字和下一個字都是多音字，要進一步檢查下一個字是否用 default。因此兩個 flags 都要設 false。
              if (noSkipNextCharacters.contains(character + nextChar)) {
                skipNext = false;
                skipPrev = false;
              } else {
                skipPrev = true; // Set skipPrev to true if a pattern is matched
                skipNext = pattern.startsWith('*') && pos == 0;
              }
            } else { // 目前的字是多音字，下一個字不是，要設 true。
              skipPrev = true; // Set skipPrev to true if a pattern is matched
              skipNext = pattern.startsWith('*') && pos == 0;
            }
            // debugPrint('Sub-pattern matched (*+any) ($character$nextChar): $pattern, matchIndex: $j, skipNext: $skipNext, skipPrev: $skipPrev');
            return Tuple3(j, skipNext, skipPrev); // Returning with skipNext and skipPrev=false
          }
        }
      }
    }

    skipPrev = false; // 目前的字沒有多音字，但是下一個字可能會有，因此要設 false。
    // debugPrint('No pattern matched for $character. Use default index: ${defaultIndex != -1 ? defaultIndex : 0}, skipNext: $skipNext, skipPrev: $skipPrev');
    return Tuple3(defaultIndex != -1 ? defaultIndex : 0, skipNext, skipPrev); // Returning the default index with skip flags as false
  }

  // Helper function to determine if a character is polyphonic
  bool isPolyphonicChar(String character) {
    var charData = _polyphonicData['data'][character];
    if (!isChineseCharacter(character) || charData == null) {
      return false;
    } else {
      return true;
    }
  }

  // Helper function to check pattern and construct substring using StringBuffer
  bool matchPattern(String pattern, int pos, int start, int end, List<String> text, String character) {
    StringBuffer tmp = StringBuffer();
    for (int z = start; z < end; z++) {
      tmp.write(text[z]);
    }
    return tmp.toString() == pattern.replaceAll('*', character);
  }

  // Helper function to check if a character is a Chinese character
  bool isChineseCharacter(String char) {
      // final chineseCharRegEx = RegExp(r'[\u4E00-\u9FFF]');
      return chineseCharRegex.hasMatch(char);
  }

}