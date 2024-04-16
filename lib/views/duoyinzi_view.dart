import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/contants/bopomos.dart';
// import 'package:ltrc/data/models/phrase_model.dart';
// import 'package:ltrc/data/models/word_model.dart';
// import 'package:ltrc/data/models/word_status_model.dart';
// import 'package:ltrc/data/providers/phrase_provider.dart';
// import 'package:ltrc/data/models/word_phrase_sentence_model.dart';
// import 'package:ltrc/data/providers/word_phrase_sentence_provider.dart';
// import 'package:ltrc/data/providers/word_provider.dart';
// import 'package:ltrc/data/providers/word_status_provider.dart';
// import 'package:ltrc/extensions.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

// import '../contants/arabic_numerals_to_chinese.dart';
// import '../data/models/unit_model.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuple/tuple.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:file_picker/file_picker.dart';

// import 'package:ltrc/data/providers/all_provider.dart';
// import 'package:ltrc/data/providers/user_provider.dart';

// import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:ltrc/data/models/word_model.dart';
import 'package:ltrc/data/providers/word_provider.dart';

class DuoyinziView extends ConsumerStatefulWidget {
  
  const DuoyinziView({super.key});

  @override
  DuoyinziViewState createState() => DuoyinziViewState();
}

class DuoyinziViewState extends ConsumerState<DuoyinziView> {
  // List<Unit> units = [];
  Map<String, dynamic> polyphonicData = {};
  final TextEditingController _controller = TextEditingController();
  List<TextSpan> processedTextSpans = [];
  String processedUnicode = '';
  late FlutterTts ftts;
  late double fontSize;

  @override
  void initState() {
    super.initState();

    ftts = FlutterTts();
    initializeTts();
    loadPolyphonicData();
  }

  Future<void> loadPolyphonicData() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data_files/poyin_db.json');
      polyphonicData = json.decode(jsonString);
      debugPrint('DuoyinziView initialized successfully');
    } catch (e) {
      debugPrint('Failed to load polyphonic data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initializeTts() {
    ftts.setStartHandler(() {
      debugPrint("TTS Start");
    });

    ftts.setCompletionHandler(() {
      debugPrint("TTS Complete");
    });

    ftts.setErrorHandler((msg) {
      debugPrint("TTS Error: $msg");
    });

    // Set language, pitch, volume, and other parameters as needed
    ftts.setLanguage("zh-tw");
    ftts.setSpeechRate(0.5); 
    ftts.setPitch(1.0);     
  }

  void handleStart() async {
    String text = _controller.text;
    debugPrint("Text entered: $text");
    var processor = PolyphonicProcessor(polyphonicData, fontSize);
    var result = await processor.process(text);
    processedTextSpans = result.item1;
    processedUnicode = result.item2;    
    setState(() {}); // Trigger a rebuild to display the processed text
  }

  void clearFields() {
    setState(() {
      _controller.clear();
      processedTextSpans = [];
      processedUnicode = '';
    });
  }

  void handleCopy() {
    debugPrint('Copying to clipboard: $processedUnicode');
    Clipboard.setData(ClipboardData(text: processedUnicode));
    Fluttertoast.showToast(
      msg: '已複製到剪貼簿!',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
      fontSize: fontSize,
    );
  }

  Future<void> handlePrint() async {
    final textToPrint = processedUnicode;
    final pdf = pw.Document();

    try {
        debugPrint('Loading font data...');
        final font = await rootBundle.load("lib/assets/fonts/BpmfIansui-Regular.ttf");
        final ttf = pw.Font.ttf(font);  
        debugPrint('Font loaded, generating PDF...');
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Text(textToPrint, style: pw.TextStyle(font: ttf, fontSize: fontSize * 1.5)),
              );
            },
          ),
        );        
    } catch (e) {
        debugPrint("Error loading font or generating PDF: $e");
    }

    try {
        final bytes = await pdf.save();
        debugPrint('PDF generated successfully, saving and sharing...');

        // Save the PDF file in the temporary directory
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/output.pdf';
        final file = File(filePath);
        await file.writeAsBytes(bytes);

        // Share the PDF file
        final xFile = XFile(filePath);
        final result = await Share.shareXFiles([xFile], text: 'Here is your PDF.');

        if (result.status == ShareResultStatus.success) {
            debugPrint('Thank you for sharing!');
        } else {
            debugPrint('Failed to share the PDF: ${result.status}');            
        }
    } catch (e) {
        debugPrint("Error saving or sharing the document: $e");
    }
  }

  BoxDecoration commonBoxDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(4.0),
  );

  TextStyle get commonTextStyle => TextStyle(
    fontFamily: 'BpmfIansui-Regular',
    fontSize: fontSize * 1.5,
  );

  void speakText() async {
    debugPrint('Speaking: ${_controller.text}');
    await ftts.speak(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    ScreenInfo screenInfo = getScreenInfo(context);
    fontSize = screenInfo.fontSize;   

    return Scaffold(
      backgroundColor: const Color(0xFFb0ebe4),
      body: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFfff8f4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: fontSize * 1.5),
            Text(
              '請貼上要標註注音的文章，然後按下開始：',
              style: commonTextStyle,
            ),
            SizedBox(height: fontSize * 0.5),
            
            Expanded(
              child: Container(
                decoration: commonBoxDecoration,
                padding: const EdgeInsets.symmetric(vertical: 8), // Adjust vertical padding if necessary
                margin: const EdgeInsets.all(10), // Consistent outer margin
                child: TextField(
                  controller: _controller,
                  style: commonTextStyle,
                  decoration: InputDecoration(
                    hintText: '在此輸入中文',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(4.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10), // Consistent padding inside the TextField
                  ),
                  keyboardType: TextInputType.multiline,
                  maxLines: null, // Set null to enable multiline input
                  // minLines: 1, // Use a minLines to ensure it starts with a single line
                ),
              ),
            ),
            
            const SizedBox(height: 10),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: handleStart,
                        child: Text('開始', style: commonTextStyle),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: clearFields,
                        child: Text('清除', style: commonTextStyle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: speakText,
                        color: commonTextStyle.color, // Apply color from commonTextStyle
                      ),
                    ],
                  ),
                  SizedBox(height: fontSize * 0.5),
                ],
              ),
            ),

            SizedBox(height: fontSize * 0.5),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: commonBoxDecoration,
                  padding: const EdgeInsets.fromLTRB(12, 8, 8, 8), // Adjust padding as needed
                  margin: const EdgeInsets.all(10),
                  child: RichText(
                    text: TextSpan(
                      children: processedTextSpans,
                      style: commonTextStyle,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: handleCopy,
                    child: Text('複製', style: commonTextStyle),
                  ),
                  SizedBox(height: fontSize * 0.5),
                  ElevatedButton(
                    onPressed: handlePrint,
                    child: Text('打印', style: commonTextStyle),
                  ),
                ],
              ),
            ),
          
          ],
        ),
      ),
    );
  }
}

class PolyphonicProcessor {
  final Map<String, dynamic> polyphonicData;
  final double fontSize;
  String spansUnicode = '';

  PolyphonicProcessor(this.polyphonicData, this.fontSize);

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
  一聲，用 "0" 代表 default
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
    debugPrint(
        'getNewToneForYiBu: prevChar: $prevChar, currentChar: $currentChar, nextChar: $nextChar, prevTone: $prevTone, nextTone: $nextTone');

    if (currentChar == '一') {
      debugPrint('Processing tone sandhi for 一');
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
        debugPrint('Returning first tone for 一 based on special conditions');
        return "0"; // Use the default, First tone
      } else if (nextTone != null &&
          (nextTone == 1 || nextTone == 2 || nextTone == 3)) {
        debugPrint('Returning fourth tone for 一 based on nextTone');
        return "ss02"; // Change to fourth tone
      } else if (nextTone != null && nextTone == 4) {
        debugPrint('Returning second tone for 一 based on nextTone');
        return "ss01"; // Change to second tone
      } else {
        debugPrint('Returning default first tone for 一');
        return "0"; // Default to first tone if no other conditions match
      }
    } else if (currentChar == '不') {
      debugPrint('Processing tone sandhi for 不');
      if (nextTone != null &&
          (nextTone == 1 || nextTone == 2 || nextTone == 3 || nextTone == 5)) {
        debugPrint('Returning fourth tone for 不 based on nextTone');
        return "0"; // Remain fourth tone
      } else if (nextTone != null && nextTone == 4) {
        debugPrint('Returning second tone for 不 based on nextTone');
        return "ss01"; // Change to second tone
      } else {
        debugPrint('Returning default fourth tone for 不');
        return "0"; // Default to fourth tone if no other conditions match
      }
    }
    debugPrint('No tone sandhi applied, returning default tone 1');
    return "0"; // Return 1 if not "一" or "不", or no specific rule applied
  }

  Future<Tuple2<List<TextSpan>, String>> process(String text) async {
    List<TextSpan> spans = [];
    String spansUnicode = '';
    Map<int, dynamic> textinfo = {};
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

    for (int i = 0; i < characters.length; i++) {
      String character = characters[i];
      String hexUnicode = character.runes.first.toRadixString(16).toUpperCase();

      // Proceed only if the character is a valid Chinese character
      if (!chineseCharRegex.hasMatch(character)) {
        spans.add(TextSpan(text: character));
        spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
        debugPrint('Not a Chinese character: $character');
        continue;
      }

      String nextChar = (i + 1 < characters.length) ? characters[i + 1] : '';
      String prevChar = (i > 0) ? characters[i - 1] : '';
      debugPrint(
          "Processing character: $character at index $i, prevChar: $prevChar, nextChar: $nextChar");

      if (character == '一' || character == '不') { // Special handle for 一 and 不
        int prevTone = (i > 0) ? await getToneForChar(prevChar) : 0; // 0: error
        int nextTone =
            (i + 1 < characters.length) ? await getToneForChar(nextChar) : 0; // 0: error
        String newSs = getNewToneForYiBu(
          prevChar: prevChar,
          currentChar: character,
          nextChar: nextChar,
          prevTone: prevTone,
          nextTone: nextTone,
        );
        if (newSs == "0") {  // If default,
          spans.add(TextSpan(
            text: character,
            style: TextStyle(
              fontFamily: 'BpmfIansui-Regular',
              fontSize: fontSize * 1.5,
              color: Colors.black,
            )
          ));
          spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
          // debugPrint('YiBu default: $spans');
        } else {  // not default. Use newSs
          spans.add(TextSpan(
            text: character,
            style: TextStyle(
              fontFamily: 'BpmfIansui-Regular',
              fontSize: fontSize * 1.5,
              color: Colors.black,
              background: Paint()..color = Colors.yellow,  // Set the background color to yellow
              // Make sure FontFeature accepts the correct index here:
              fontFeatures: [FontFeature.enable(newSs)]
            ),
          ));
          if (newSs != "0") {
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
            spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
          } else {
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
          }

          debugPrint('YiBu not default. SS: $newSs');
        }
      } else {  // 非“一”或“不”的多音字處理
        var charData = polyphonicData['data'][character];
        if (charData != null) {
          List<dynamic>? variations = charData['v'];
          if (variations != null && variations.isNotEmpty) {
            bool matched = false;

            for (var j = 1; j < variations.length; j++) {
              // Start from 1 to skip the default variant
              var variation = variations[j];
              var variantPatterns = variation.split('/');
              String newSs = 'ss0$j';
              for (String pattern in variantPatterns) {
                if (match(character, i, pattern, j, characters, textinfo)) {
                  spans.add(TextSpan(
                    text: character,
                    style: TextStyle(
                      fontFamily: 'BpmfIansui-Regular',
                      fontSize: fontSize * 1.5,
                      color: Colors.black,
                      background: Paint()..color = Colors.yellow,  // Set the background color to yellow
                      // Make sure FontFeature accepts the correct index here:
                      fontFeatures: [FontFeature.enable(newSs)]
                    ),
                  ));
                  if (newSs != "0") {
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                    spansUnicode += String.fromCharCode(int.parse(ssMapping[newSs]!.substring(0, 5), radix: 16));
                  } else {
                    spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
                  }

                  debugPrint('non-YiBu: matched. SS: $newSs');
                  matched = true;
                  break;
                }
              }
              if (matched) break;
            }

            if (!matched) {
              spans.add(TextSpan(
                text: character,
                style: TextStyle(
                  fontFamily: 'BpmfIansui-Regular',
                  fontSize: fontSize * 1.5,
                  color: Colors.black,                      
                ),
              ));
              spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
              debugPrint('non-YiBu: not matched. Use default SS');
              // break;              
            }
          } else { // if variations == null || variations.isEmpty
            spans.add(TextSpan(
              text: character,
              style: TextStyle(
                fontFamily: 'BpmfIansui-Regular',
                fontSize: fontSize * 1.5,
                color: Colors.black,                      
              ),
            )); 
            spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
            debugPrint('non-YiBu: variations == null. Use default SS');
          }
        } else { // if charData == null
          spans.add(TextSpan(
            text: characters[i],
            style: TextStyle(
              fontFamily: 'BpmfIansui-Regular',
              fontSize: fontSize * 1.5,
              color: Colors.black,                      
            ),
          ));
          spansUnicode += String.fromCharCode(int.parse(hexUnicode, radix: 16));
          debugPrint('non-YiBu: charData == null. Use default SS');
        }
      }
    }
    debugPrint('final spansUnicode: $spansUnicode');
    return Tuple2(spans, spansUnicode);
  }

  bool match(String c, int i, String p, int j, List<String> text,
      Map<int, dynamic> textinfo) {
    int pos = p.indexOf('*');
    if (i - pos < 0 || i - pos + p.length > text.length) return false;

    String tmp = '';
    for (var z = i - pos; z < i - pos + p.length; z++) {
      tmp += text[z];
    }
    if (tmp != p.replaceAll('*', c)) return false;

    text[i] = c + (j > 0 ? String.fromCharCode(0xE01E0 + j) : '');
    textinfo[i] = {'phrase': p.replaceFirst('*', c)};

    return true;
  }

}

