// import 'dart:async';
// import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/polyphonic_processor.dart';
import 'package:ltrc/views/view_utils.dart';

// import 'package:path_provider/path_provider.dart';

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
  late AudioPlayer player;
  late double fontSize;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  @override
  void dispose() {
    // ftts.stop();
    _controller.dispose();
    super.dispose();
  }

  void _initializeTts() {
    ftts = ref.read(ttsProvider);
    player = ref.read(audioPlayerProvider);
  }

  void handleStart() async {
    String text = _controller.text;
    debugPrint("Text entered: $text");
    // final stopwatchOriginal = Stopwatch()..start();
    var result = await PolyphonicProcessor.instance.process(text, fontSize * 1.2, Colors.white, true);
    // stopwatchOriginal.stop();
    // debugPrint('Process time: ${stopwatchOriginal.elapsedMicroseconds} microseconds');    
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

  BoxDecoration commonBoxDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(4.0),
  );
  
  TextStyle get commonTextStyle => TextStyle(
    fontFamily: 'BpmfIansui',
    fontSize: fontSize * 1.2,
  );

  void _speakText() async {
    debugPrint('Speaking: ${_controller.text}');
    await ftts.speak(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.read(screenInfoProvider);
    final screenInfo = ref.read(screenInfoProvider);
    fontSize = screenInfo.fontSize;   

    if (kDebugMode) {
      final stackTrace = StackTrace.current.toString().split('\n');
      final relevantStackTrace = '\n${stackTrace[0]}\n${stackTrace[1]}';
      debugPrint('DuoyinziView build: fontSize: $fontSize, stack: $relevantStackTrace');
    }    

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
          onPressed: () {
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text("標示注音符號", style: commonTextStyle), 
        actions: [
          IconButton(
            icon: Icon(Icons.home, size: fontSize * 1.5),
            onPressed: () {
              if (context.mounted) {
                navigateWithProvider(context, '/mainPage', ref);
              }
            },
          )
        ],
      ),      
      // backgroundColor: const Color(0xFFb0ebe4),
      body: Container(
        margin: EdgeInsets.all(fontSize * 0.5),
        padding: EdgeInsets.all(fontSize * 0.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Container(
                decoration: commonBoxDecoration,
                padding: const EdgeInsets.symmetric(vertical: 0), // Adjust vertical padding if necessary
                margin: const EdgeInsets.all(10), // Consistent outer margin
                child: TextField(
                  controller: _controller,
                  style: commonTextStyle,
                  decoration: InputDecoration(
                    hintText: '請貼上要標示注音符號的文字，然後按「開始」。',
                    hintMaxLines: 3,
                    hintStyle: TextStyle(color: Colors.white70, fontSize: fontSize, fontFamily: 'BpmfIansui'),
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
            
            SizedBox(height: fontSize * 0.5),
            
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
                      SizedBox(width: fontSize),
                      ElevatedButton(
                        onPressed: clearFields,
                        child: Text('清除', style: commonTextStyle),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.volume_up,
                          size: fontSize * 2.0,  // Adjusting the size to 1.5 times the base font size
                          color: Colors.white,  // Setting the icon color to white
                        ),
                        onPressed: _speakText,
                        // color: commonTextStyle.color, // Apply color from commonTextStyle
                      ),
                    ],
                  ),
                  // SizedBox(height: fontSize * 0.5),
                ],
              ),
            ),

            SizedBox(height: fontSize * 0.5),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  decoration: commonBoxDecoration,
                  // padding: const EdgeInsets.fromLTRB(12, 8, 8, 8), // Adjust padding as needed
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8,), // Adjust vertical padding if necessary                  
                  margin: const EdgeInsets.all(10),             
                  child: RichText(
                    text: TextSpan(
                      children: processedTextSpans,
                      style: commonTextStyle.copyWith(height: 1.5), // Adjust the `height` to match the upper box
                    ),
                  ),
                ),
              ),
            ),
            /* Disabled 複製 button until it can work with other mobile App
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(bottom: fontSize * 0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: handleCopy,
                    style: ElevatedButton.styleFrom(
                      textStyle: commonTextStyle.copyWith(fontSize: fontSize * 1.2), // Adjust the fontSize here
                      padding: EdgeInsets.symmetric(horizontal: fontSize, vertical: fontSize * 0.5),
                    ),
                    child: Text('複製', style: commonTextStyle), // Removed 'const' to apply the dynamic style
                  ),
                ],
              ),
            ),
            */
          ],
        ),
      ),
    );
  }
}
