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

  /* 以下處理一、不的方法是基於 jeffreyxuan 的原始碼 https://github.com/jeffreyxuan/toneoz-font-zhuyin/blob/main/src/js/ybtone.js
  同時也請參考教育部國語辭典說明：https://dict.concised.moe.edu.tw/page.jsp?ID=55，以下是摘錄：及例外說明。
  A：“一”有三個音：一聲、二聲、四聲。default 是一聲，用"0000" 代表。二聲，用 "ss01" 代表，四聲，用 "ss02" 代表。
  在以下三種情況，應將「一」讀作原調一聲：
  1. 單唸 e.g. 一
  2. 詞尾 e.g. 純一、萬一、星期一
  3. 表示序數時 e.g. 一九九一、第一座
  除以上特別情況，其餘有「一」字的詞語大都需要變調。
  4. 如果「一」字在第一聲、第二聲或第三聲的字前，需將「一」字讀第四聲。 e.g. 一天(tiān)、一年(nián)、一起(xĭ)
  5. 如果「一」字在第四聲的字前，需將「一」字讀第二聲。 e.g. 一定(dìng)、一片(piàn)、一樣(yàng)
  6. 但是還是有很多例外狀況，例如“一個”、“一會”、“一切”，用 specialYiCases 處理。另外，有一部份直接寫進
     code 裡面，例如：一對、一次、一家、某一領域、一層、一名等等。

  B：“不”在 IanSui 裡面有四個音：bu4、bu2、fou、fu。（但是教育部是：bu4、fou3、fou、fu。）
  default 是四聲，用"0000" 代表。二聲，用 "ss01" 代表，fou，用 "ss02"，fu 用 “ss03” 代表。
  在以下三種情況，應將「不」讀作原調四聲：
  1. 單唸 e.g. 不
  2. 詞尾 e.g. 從不、絕不
  3. 在第一聲、第二聲、第三聲或第五聲的字前 e.g. 不該(gāi)、不來(lái)、不管(guăn)
  除以上特別情況，其餘有「不」字的詞語大都需要變調。  
  4. 如果「不」字在第四聲的字前，需將「不」字讀第二聲。 e.g. 不要(yào)、不用(yòng)、不對(dùi)
  5. 如果「不」字在第二聲的字前，需將「不」字讀第四聲。 e.g. 不同(tóng)、不對(dùi)、不足(zú)
  6. 但是還是有很多例外狀況，例如“不禁”、“不菲”、“不勝”、“不著”，用 specialBuCases 處理。另外，有一部份直接寫進
     code 裡面，例如：不好、不一樣、不一定、不一會

  處理“一”和“不”的多音字時，先處理詞尾（例如：統一、絕不），再處理特殊情況（例如：一個、不禁），最後處理一般情況。   

  C：教育部國語辭典（https://dict.concised.moe.edu.tw/page.jsp?ID=55） 裡有提到兩個變調：輕聲變調 和 其他。
  1. 輕聲變調：單字不具輕聲字音，複詞最末音節在口語中變讀為輕聲字音時，先標本調字音，再以（變）標示輕聲字音。它用
     【葫蘆】為例：ㄏㄨˊ　ㄌㄨˊ（變）ㄏㄨˊ　˙ㄌㄨ。
     問題是：IanSui 字體不支援輕聲字音˙ㄌㄨ，因此，這裡不處理輕聲字音。
  2. 其他：部分詞語在口語中有明顯變調情形時，先標本調字音，再以（變）標示變調字音。例如：
     【嗶嗶剝剝】：ㄅㄧˋ　ㄅㄧˋ　ㄅㄛ　ㄅㄛ（變）ㄅㄧ　ㄅㄧ　ㄅㄛ　ㄅㄛ
     問題是：IanSui 字體不支援一聲字音ㄅㄧ，因此，這裡不處理一聲字音。
  上面兩種情況的例子應該很多。若有人提出，再看如何處理，目前先不再花時間考慮。
  */

  Tuple3<String, bool, bool> getNewToneForYiBu({ // String: newSs, bool: skipNext, bool: skipPrev
      String? prevChar,
      required String currentChar,
      String? nextChar,
      int? prevTone,
      int? nextTone,
      required bool skipPrev,
  }) {

      final Set<String> prevCharSet1 = {
        '第', '説', '说', '唯', '惟', '统', '統', '独', '獨', '劃', '划', '萬', '專', '某',
        '十', '九', '八', '七', '六', '五', '四', '三', '二', '一', '〇', '零'
      };

      final Set<String> nextCharSet1 = {
        // 前面兩列是Jeff原來的 code
        '是', '日', '月', '的', '或', '物', '片', '系', 
        // 下一個字是數詞
        '十', '九', '八', '七', '六', '五', '四', '三', '二', '一', '〇', '零', '百', '千', '萬',        
        // 下一個字二聲，但是「一」念一聲
        '元', '則', '節', '台', '同', '名', '回', '堂', '層', '幅', '幢', '年', '息', '成', '排', '提', 
        '搏', '擊', '擲', '旁', '時', '枚', '格', '條', '樓', '流', '環', '篇', '級', '群', '言', '連', 
        '門', '間', 
        // 我查教育部辭典查到，下面的詞尾，「一」念一聲
        '天', '經', '方', '對', '次', '家', '鳴', '命', '份', '件', '尊', '聲', '歲', '副', '本', '批',
      };    
      // debugPrint('getNewToneForYiBu: prevChar: $prevChar, currentChar: $currentChar, nextChar: $nextChar, prevTone: $prevTone, nextTone: $nextTone');
      const Map<String, Tuple3<String, bool, bool>> specialYiCases = {
        '個': Tuple3("0000", false, false), // 個平常是四聲，一個的個要念輕聲，一念一聲，個這個字下一次處理
        '个': Tuple3("0000", false, false), // 個平常是四聲，一个的个要念輕聲，一念一聲，个這個字下一次處理
        '會': Tuple3("0000", false, false), // 會平常是四聲，一會的會要念“悔”三聲，一念一聲，會這個字下一次處理
        '切': Tuple3("0000", false, false), // 切平常是一聲，一切的切念四聲，一念一聲，切這個字下一次處理
        '不': Tuple3("0000", true, true),   // 不平常是四聲，“一不”念ㄧ ㄅㄨˋ，不需要再處理上一個及下一個字
      };

      const Map<String, Tuple3<String, bool, bool>> specialBuCases = {
        '禁': Tuple3("0000", false, false), // 禁平常是四聲，不禁的禁要念一聲，不念四聲，禁這個字下一次處理
        '菲': Tuple3("0000", false, false), // 菲平常是一聲，不菲的菲要念三聲，不念四聲，菲這個字下一次處理
        '勝': Tuple3("0000", false, false), // 勝平常是四聲，不勝的勝要念一聲，不念四聲，勝這個字下一次處理
        '著': Tuple3("0000", false, false), // 著平常是一聲，不著的著要念二聲，不念四聲，著這個字下一次處理
        '了': Tuple3("0000", false, false), // 了平常是輕聲，在“吃不了"時，念三聲，不念四聲，了這個字下一次處理
        '好': Tuple3("0000", false, false), // 在處理“不好好學習”時，第二個好跟後面的學會念成四聲hao4xue2，錯了。因此，要特別處理
        '假': Tuple3("0000", false, false), // 假平常是四聲，不假的假要念三聲，不念四聲，假這個字下一次處理
        '當': Tuple3("ss01", false, false), // 當平常是一聲，不當的當要念四聲，不念二聲，當這個字下一次處理
      };

      if (currentChar == '一') {
        // Check prevChar conditions, then nextChar special conditions, then general cases
        if ((!skipPrev) && (prevChar == null || prevCharSet1.contains(prevChar))) {
          // debugPrint('$prevChar一，"一"發一聲，下一個字“$nextChar”要再處理, skipPrev: true');
          return const Tuple3("0000", false, true); // Use the default, First tone; skipNext false; skipPrev true
        } else if (specialYiCases.containsKey(nextChar)) {
          // debugPrint('一$nextChar，"一"發一聲，下一個字“$nextChar”要再處理');
          return specialYiCases[nextChar]!; // Use the default, First tone; skipNext false; skipPrev false
        } else if (nextChar == null || nextChar.isEmpty || nextCharSet1.contains(nextChar)) {
          // debugPrint('一$nextChar，"一"發一聲，$nextChar發預設值，不再處理上一個及下一個字');
          return const Tuple3("0000", true, true); // Use the default, First tone, and skipNext true; skipPrev true
        } else if (prevChar == nextChar || 
            ['看', '聽', '寫', '用', '說', '動', '搖', '問'].contains(nextChar)) {
          // debugPrint('$prevChar一$nextChar，"一"發一聲，$prevChar 跟 $nextChar 發本調，不再處理上一個及下一個字');
          return const Tuple3("0000", true, true); // Use the default, First tone, and skipNext true; skipPrev true          
        } else if (nextTone != null && (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
          return const Tuple3("ss02", true, true); // Use the fourth tone, and skipNext true; skipPrev true
        } else if (nextTone != null && nextTone == 4) {
          return const Tuple3("ss01", true, true); // Use the second tone, and skipNext true; skipPrev true
        } else {
          return const Tuple3("0000", false, true); // Default to first tone if no other conditions match; skipNext false; skipPrev true
        }          
      } else if (currentChar == '不') {
        // debugPrint('Processing 不. nextChar $nextChar, nextTone $nextTone, prevChar $prevChar, prevTone $prevTone');

        if (specialBuCases.containsKey(nextChar)) {
          // debugPrint('不$nextChar，不 四聲，$nextChar 特殊聲調');
          return specialBuCases[nextChar]!;
        }

        if (nextTone != null &&
            (nextTone == 1 || nextTone == 2 || nextTone == 3 || nextTone == 5)) {
          // debugPrint('“不$nextChar”, 不發四聲，nextSkip: false, prevSkip: true');
          return const Tuple3("0000", false, true); // Remain 四聲
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
        '好好': 'ss00', // 不好好學習
        '從從': 'ss03',
        '怔怔': 'ss01',
        '悶悶': 'ss01',
        '擔擔': 'ss01',
        '數數': 'ss01',
        '施施': 'ss01',
        '晃晃': 'ss01', // '白晃晃','明晃晃','亮晃晃','精晃晃','油晃晃' 用三聲；晃晃悠悠、晃晃蕩蕩、搖搖晃晃用四聲，default
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
        '行行': 'ss00', // 行行重行行/行行好事，行行出狀元，行行如也，念法都不同。再特別處理。
        '褶褶': 'ss01', // 褶褶有兩個念法：die2die2，zhe3zhe3，目前只處理die2die2
        '逮逮': 'ss00', 
        '那那': 'ss01',                
        '重重': 'ss01', // 重重的，重重阻礙，念法不同。再特別處理。
        '銻銻': 'ss02',
        '鰓鰓': 'ss01',
        '個個': 'ss00', // 個個或一個個，都發四聲，因此需要提前處理。
        '个个': 'ss00',
        '大大': 'ss00',
        '方方': 'ss00', 
        '喏喏': 'ss00',
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
                } else if (pair == '晃晃') {
                  if (['白','明','亮','精','油'].contains(prevChar)) {
                    styleSet = 'ss01'; // 白晃晃、明晃晃、亮晃晃、精晃晃、油晃晃 都念三聲
                  } else { // 晃晃悠悠、晃晃蕩蕩、搖搖晃晃 都念四聲，default
                    styleSet = 'ss00'; //
                  }
                  setNextBpmf = 0;

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

                  case 1: // next2Char 用 default
                    spans.add(TextSpan(text: next2Char, style: getCharStyle(fontSize, color, highlightOn)));
                    nextHexUnicode = next2Char.runes.first.toRadixString(16).toUpperCase();
                    spansUnicode += String.fromCharCode(int.parse(nextHexUnicode, radix: 16));
                    // debugPrint('Fast processing $next2Char using default at index: ${i + 1}');
                    i += 1;
                    break;

                  case 2: // 依 next2CharStyleSet，next2Char 用 default, 或用 next2CharStyleSet
                          // 依 next3CharStyleSet，next3Char 用 default, 或用 next3CharStyleSet
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
    // 我原先想法是，若下一個字也是多音字，列一個表來檢查，以便加速處理。但是這個表的維護就成問題。所以放棄這個想法。
    // final List<String> noSkipNextCharacters = ['骨頭', '參與', '參差', '檻車', '爪子', '度量', '委蛇', '暈倒'/* 這裡要列出兩個字都是多音字，而且第二個字的發音不是default */];

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
      // debugPrint('isFirstChar: $isFirstChar or skipPrev: $skipPrev. Skipping the first pass, i.e., any+$character');
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
            if (isPolyphonicChar(nextChar)) { // 如果目前的字和下一個字都是多音字，設 skipNext 跟 skipPrev 為 false。
              skipNext = false;
              skipPrev = false;
            } else { // 目前的字是多音字，下一個字不是，skipNext 要設 true。
              skipNext = true;
              skipPrev = pattern.startsWith('*') && pos == 0;
            }
            if (isPolyphonicChar(nextChar)) { // 下一個字也是多音字
              /* 我原先想法是，若下一個字也是多音字，列一個表來檢查，以便加速處理。但是這個表的維護就成問題。所以放棄這個想法。
              if (noSkipNextCharacters.contains(character + nextChar)) {
                skipNext = false;
                skipPrev = false;
              } else {
                skipPrev = true; // Set skipPrev to true if a pattern is matched
                skipNext = pattern.startsWith('*') && pos == 0;
              }
              */
              skipNext = false;
              skipPrev = false;              
            } else { // 目前的字是多音字，下一個字不是，要設 true。
              skipPrev = true; // Set skipPrev to true if a pattern is matched
              skipNext = pattern.startsWith('*') && pos == 0;
            }            
            // debugPrint('Sub-pattern matched (*+any) ($character+$nextChar): $pattern, matchIndex: $j, skipNext: $skipNext, skipPrev: $skipPrev');
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