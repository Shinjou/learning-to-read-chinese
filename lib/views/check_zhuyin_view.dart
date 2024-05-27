import 'dart:async';
import 'dart:io';

import 'package:flutter_tts/flutter_tts.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/word_phrase_sentence_model.dart';
// import 'package:ltrc/data/models/word_status_model.dart';
import 'package:ltrc/data/providers/word_phrase_sentence_provider.dart';

import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';  // Import this for Uint8List
import 'package:intl/intl.dart';  // For date formatting

// import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/views/polyphonic_processor.dart';

class CheckZhuyinView extends ConsumerStatefulWidget {
  
  const CheckZhuyinView({super.key});

  @override
  CheckZhuyinViewState createState() => CheckZhuyinViewState();
}

class CheckZhuyinViewState extends ConsumerState<CheckZhuyinView> {
  Map<String, dynamic> polyphonicData = {};
  TextEditingController idController = TextEditingController();
  // List<TextSpan> processedTextSpans = [];
  // String processedUnicode = '';
  late FlutterTts ftts;
  late double fontSize;
  List<TextSpan> concatenatedTextSpans = [];
  List<TextSpan> tempTextSpans = [];
  String concatenatedUnicode = '';  
  int maxId = 3085; // For initial testing with 10 entries
  int currentId = 1;
  final int entriesPerPage = 10;
  int totalProcessed = 0;
  int maxEntries = 1000; 
  // Create an instance of ScreenshotController
  late String directory;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  Future<void> initializeState() async {
    // directory = (await getApplicationDocumentsDirectory()).path; // from path_provider package
    directory = '/Users/shinjou/Desktop'; // For macOS, the path is '/Users/username/Desktop
    // directory = '${(await getApplicationDocumentsDirectory()).parent.parent.parent.parent.path}/Desktop';    
    maxId = await WordPhraseSentenceProvider.getMaxId(); // Assuming this method fetches the maximum ID
    debugPrint('Max ID: $maxId');
    ftts = FlutterTts();
    initializeTts();    
    setState(() {});
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

  void _speakText() async {
    debugPrint('Speaking: ${idController.text}');
    await ftts.speak(idController.text);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeFontSize();
  }

  void initializeFontSize() {
    final mediaQueryData = MediaQuery.of(context);
    fontSize = mediaQueryData.size.width * 0.04; // Dynamically setting the font size based on screen width
  }

  @override
  void dispose() {
    super.dispose();
  }

  BoxDecoration commonBoxDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey),
    borderRadius: BorderRadius.circular(4.0),
  );
  
  TextStyle get commonTextStyle => TextStyle(
    fontFamily: 'BpmfIansui',
    fontSize: fontSize * 0.9,
    // color: Colors.black,
  );

  void handleStart() async {
    if (validateId()) {
      clearFields();
      await processMaxEntries(); // Ensures all processing is done before updating the UI
    }
  }

  void updateUI() {
    if (mounted) {
      setState(() {
        // By copying to a new list, we're ensuring any state change is recognized by Flutter.
        concatenatedTextSpans = List.from(concatenatedTextSpans);
        print("Data ready to display, setState to update UI now.");
      });
    }
  }

  void clearFields() {
    // idController.clear();
    print("Clearing fields");
    concatenatedTextSpans.clear();
    tempTextSpans.clear();
    concatenatedUnicode = '';
    updateUI();
    // Other clearing logic if necessary
  }

  bool validateId() {
    int id = int.tryParse(idController.text) ?? 0;
    if (id == 0) {id = 1;}
    if (id < 1 || id > maxId) {
      debugPrint('Invalid ID. Please enter a valid number between 1 and $maxId.');
      return false;
    }
    debugPrint('Valid ID: $id (Max ID: $maxId)');
    currentId = id;
    return true;
  }

  void handleContinue() async {
    clearFields(); // Clear previous data to start fresh
    // currentId = currentId + entriesPerPage;
    totalProcessed = 0;
    await processMaxEntries(); 
  }

  Future<void> processMaxEntries() async {
    while (currentId <= maxId && totalProcessed <= maxEntries) {
      await processTenEntries();
      await waitForCapture();
      if (mounted) {   
        // Ensure the widget is still mounted and the new spans are not empty before updating the UI
        // (This is to avoid unnecessary updates when there's no new data to display      
        setState (() {
          totalProcessed += entriesPerPage;
          currentId += entriesPerPage;               
          concatenatedTextSpans.clear();
          concatenatedTextSpans = List.from(concatenatedTextSpans);
        });
      }      
    }
  }

  Future<void> processTenEntries() async {
    print('Processing entries from ID $currentId to ${currentId + entriesPerPage -1} or $maxId');
    List<TextSpan> newSpans = [];
    for (int id = currentId; id <= maxId && id < currentId + entriesPerPage; id++) {
      try {
        var spans = await processWordPhraseSentenceById(id);
        newSpans.addAll(spans);
        print('Processing ID = $id, ${spans.length} spans; total ${newSpans.length} spans.');
      } catch (e) {
        print('Failed to process entry with ID $id: $e');
      }
    }
    if (mounted && newSpans.isNotEmpty) {
      // Ensure the widget is still mounted and the new spans are not empty before updating the UI
      // (This is to avoid unnecessary updates when there's no new data to display      
      setState (() {
        concatenatedTextSpans.addAll(newSpans);
        concatenatedTextSpans = List.from(concatenatedTextSpans);
        // print("processTenEntries: Data ready to display, update UI now. ${concatenatedTextSpans.length} $concatenatedTextSpans");        
      });
    }
  }

  Future<List<TextSpan>> processWordPhraseSentenceById(int id) async {
    List<TextSpan> tempTextSpans = [];
    try {
      WordPhraseSentence? entry = await WordPhraseSentenceProvider.getWordPhraseSentenceById(inputWordPhraseSentenceId: id);
      if (entry == null) {
        // Handle the case where the entry does not exist
        print("No entry found for ID $id.");
        return tempTextSpans;
      }
      
      var processedWord = await PolyphonicProcessor.instance.process(entry.word, fontSize * 0.9, Colors.black, true);
      var processedPhrase = await PolyphonicProcessor.instance.process(entry.phrase, fontSize * 0.9, Colors.black, true);
      var processedSentence = await PolyphonicProcessor.instance.process(entry.sentence, fontSize * 0.9, Colors.black, true);
      var processedPhrase2 = await PolyphonicProcessor.instance.process(entry.phrase2, fontSize * 0.9, Colors.black, true);
      var processedSentence2 = await PolyphonicProcessor.instance.process(entry.sentence2, fontSize * 0.9, Colors.black, true);
      
      // Concatenating results for TextSpans
      tempTextSpans.add(TextSpan(text: "$id: ", style: const TextStyle(color: Colors.black)));
      tempTextSpans.addAll(processedWord.item1);
      tempTextSpans.add(const TextSpan(text: " : "));
      tempTextSpans.addAll(processedPhrase.item1);
      tempTextSpans.add(const TextSpan(text: " "));
      tempTextSpans.addAll(processedSentence.item1);
      tempTextSpans.add(const TextSpan(text: " "));
      tempTextSpans.addAll(processedPhrase2.item1);
      tempTextSpans.add(const TextSpan(text: " "));
      tempTextSpans.addAll(processedSentence2.item1);
      tempTextSpans.add(const TextSpan(text: "\n"));
      
      // Concatenating results for Unicode Strings
      concatenatedUnicode += "$id: ${processedWord.item2} : ";
      concatenatedUnicode += "${processedPhrase.item2} ";
      concatenatedUnicode += "${processedSentence.item2} ";
      concatenatedUnicode += "${processedPhrase2.item2} ";
      concatenatedUnicode += "${processedSentence2.item2}\n";
      
    } catch (e) {
      print('Error processing data: $e');
    }
    return tempTextSpans;
  }

  Future<void> captureAndSave() async {
    try {
      String formattedDateTime = DateFormat('yyyy-MM-dd-HH-mm-ss').format(DateTime.now());
      String fileName = '字詞_$currentId-${currentId + entriesPerPage - 1}_$formattedDateTime.png';
      String fullPath = '$directory/$fileName';
      debugPrint('Saving screenshot to $fullPath');

      Uint8List? image = await screenshotController.capture();
      if (image != null) {
        File imgFile = File(fullPath);
        await imgFile.writeAsBytes(image);
        debugPrint("Screenshot saved to $fullPath");
      } else {
        debugPrint("captureAndSave error: Screenshot capture returned null");
      }
    } catch (e) {
      debugPrint("captureAndSave error: $e");
    }
  }

  Future<void> waitForCapture() async {
    await Future.delayed(const Duration(seconds: 1));
    await captureAndSave();
  }

  @override
  Widget build(BuildContext context) {
    print("Building CheckZhuyinView widget...");
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("詞句注音/多音字", style: commonTextStyle), 
        actions: [
          IconButton(
            icon: Icon(Icons.home, size: fontSize * 1.5),
            onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
          )
        ],
      ),      

      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: idController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                    decoration: const InputDecoration(
                      labelText: 'Start ID',
                      hintText: '生字 id',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    ),
                    style: TextStyle(fontSize: fontSize, color: Colors.black),
                    maxLength: 7,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => handleStart(),
                  child: Text(
                    '開始', style: TextStyle(fontSize: fontSize),
                  ),
                ),
                // if (concatenatedTextSpans.isNotEmpty)
                //   RichText(text: TextSpan(children: concatenatedTextSpans)),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => handleContinue(),
                  child: Text(
                    '繼續', style: TextStyle(fontSize: fontSize),
                  ),                  
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => clearFields(),
                  child: Text(
                    '清除', style: TextStyle(fontSize: fontSize),
                  ),                  
                ),

              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Screenshot(
                controller: screenshotController,              
                child: Container(
                  color: Colors.white,
                  // decoration: commonBoxDecoration,
                  padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  margin: const EdgeInsets.all(10),
                  child: RichText(
                    text: TextSpan(
                      children: concatenatedTextSpans,
                      style: commonTextStyle.copyWith(height: 1.2),
                    ),
                  ),         
                )
              ),
            ),
          ),        
        ],
      )

    );
  }

}
