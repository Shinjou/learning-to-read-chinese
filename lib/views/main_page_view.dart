import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/semester_code.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
// import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';
// import 'package:ltrc/widgets/progress_bar.dart';


class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    debugPrint('main_page_view: H: $deviceHeight, W: $deviceWidth, F: $fontSize');
    String account = ref.read(accountProvider);
    int totalWordCount = ref.watch(totalWordCountProvider);
    int learnedWordCount = ref.watch(learnedWordCountProvider);

    // for unknown reason, totalWordCount is 0. Set it here 186 to work around.
    if (totalWordCount == 0) {
      debugPrint('MainPageView WordCount: total $totalWordCount, learned $learnedWordCount');
      totalWordCount = 186;
    }

    return Scaffold(
      backgroundColor: darkBrown,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              size: fontSize * 1.5,
            ),
            // onPressed: () => Navigator.of(context).pushNamed('/setting'),
            onPressed: () => navigateWithProvider(context, '/setting', ref),
          )
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600), // Adjust this value as needed
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[        
              Text(
                '學國語',
                style: TextStyle(
                  fontSize: fontSize * 2.0,
                  color: beige,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: deviceHeight * 0.05),
              _buildButton(
                context,
                ref,
                '學生字',
                () async {
                  int semesterCode = ref.watch(semesterCodeProvider);
                  int publisherCode = ref.watch(publisherCodeProvider);
                  List<Unit> units = await UnitProvider.getUnits(
                    inputPublisher: publisherCodeTable[publisherCode]!,
                    inputGrade: ref.watch(gradeProvider),
                    inputSemester: semesterCodeTable[semesterCode]!);
                  if (!context.mounted) return;    
                  navigateWithProvider(
                    context, 
                    '/units', 
                    ref, 
                    arguments: {'units': units}
                  );
                },
                fontSize,
              ),
              SizedBox(height: deviceHeight * 0.02),
              if (account == 'tester' || account == 'testerbpmf') 
                _buildButton(
                  context,
                  ref,
                  '檢查字詞的注音',
                  () => navigateWithProvider(context, '/checkzhuyin', ref),
                  fontSize,
                ),
                SizedBox(height: deviceHeight * 0.02),
              _buildButton(
                context,
                ref,
                '標示注音符號',
                () => navigateWithProvider(context, '/duoyinzi', ref),
                fontSize,
              ),
              // You can add more widgets here if needed
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, String text, VoidCallback onPressed, double fontSize) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(deepBlue),
        elevation: WidgetStateProperty.all(25),
        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12))),
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize * 1.5,
          color: beige,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }        
}
