import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/unit_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/progress_bar.dart';

class MainPageView extends ConsumerWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    int totalWordCount = ref.watch(totalWordCountProvider);
    int learnedWordCount = ref.watch(learnedWordCountProvider);


    return Scaffold(
      backgroundColor: '#28231D'.toColor(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              size: 38,
            ), 
            onPressed: () => Navigator.of(context).pushNamed(
              '/setting'
            ),)
        ],
      ),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 54,
              alignment: Alignment.center,
              margin: EdgeInsetsDirectional.fromSTEB(0, deviceHeight * 0.0825, 0, deviceHeight * 0.193),
              child: Text(
                '學中文',
                style: TextStyle(
                  fontSize: min(deviceWidth * 46 / 360, 52),
                )
              )
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: deviceHeight * 0.2),
              child: SizedBox(
                width: deviceWidth * 0.76,
                height: deviceHeight * 0.095,
                child: ElevatedButton(
                  onPressed: () async {
                    int publisherCode = ref.watch(publisherCodeProvider);
                    List<Unit> units = await UnitProvider.getUnits(
                      inputPublisher: publisherCodeTable[publisherCode]!,
                      inputGrade: ref.watch(gradeProvider),
                      inputSemester: "上"
                    );
                    Navigator.of(context).pushNamed(
                      '/units', 
                      arguments: {'units' : units},
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all('#013E6D'.toColor()),
                    elevation: MaterialStateProperty.all(25),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                  child: Text(
                    '學生字',
                    style: TextStyle(
                      fontSize: 32,
                      color: '#F5F5DC'.toColor(),
                    )
                  )
                ),
              )
            ),
            const Text(
              '學過的生字卡',
              style: TextStyle(
                fontSize: 22,
              )
            ),
            ProgressBar(maxCount: totalWordCount, value: learnedWordCount),
          ]
        ),
      )
    );
  }
}