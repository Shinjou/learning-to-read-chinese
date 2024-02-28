// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/semester_code.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/progress_bar.dart';
import 'package:ltrc/views/view_utils.dart';

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ScreenInfo screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    int totalWordCount = ref.watch(totalWordCountProvider);
    int learnedWordCount = ref.watch(learnedWordCountProvider);

    // for unknown reason, totalWordCount is 0. Set it here 186 to work around.
    if (totalWordCount == 0) {
      debugPrint('MainPageView WordCount: total $totalWordCount, learned $learnedWordCount');
      totalWordCount = 186;
    }

    return Scaffold(
        backgroundColor: '#28231D'.toColor(),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: Icon(
                Icons.settings,
                size: fontSize * 1.5,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/setting'),
            )
          ],
        ),
        body: SizedBox.expand(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: fontSize * 3.2,
                    alignment: Alignment.center,
                    margin: EdgeInsetsDirectional.fromSTEB(
                        0, deviceHeight * 0.0825, 0, deviceHeight * 0.193),
                    child: Text('學國語',
                        style: TextStyle(
                          fontSize: fontSize * 2.0,
                        ))),
                Padding(
                    padding:
                        EdgeInsetsDirectional.only(bottom: deviceHeight * 0.15),
                    child: SizedBox(
                      width: deviceWidth * 0.76,
                      height: deviceHeight * 0.095,
                      child: ElevatedButton(
                          onPressed: () async {
                            int semesterCode =
                                ref.watch(semesterCodeProvider);
                            int publisherCode =
                                ref.watch(publisherCodeProvider);

                            List<Unit> units = await UnitProvider.getUnits(
                                inputPublisher:
                                    publisherCodeTable[publisherCode]!,
                                inputGrade: ref.watch(gradeProvider),
                                // inputSemester: "上");
                                inputSemester: semesterCodeTable[semesterCode]!);
                            Navigator.of(context).pushNamed(
                              '/units',
                              arguments: {'units': units},
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all('#013E6D'.toColor()),
                            elevation: MaterialStateProperty.all(25),
                            shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                          ),
                          child: Text('學生字',
                              style: TextStyle(
                                fontSize: fontSize * 1.5,
                                color: '#F5F5DC'.toColor(),
                              ))),
                    )),
                Text('學過的生字卡',
                    style: TextStyle(
                      fontSize: fontSize * 1.3,
                    )),
                ProgressBar(maxCount: totalWordCount, value: learnedWordCount),
              ]),
        ));
  }
}
