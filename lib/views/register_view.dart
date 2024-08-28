import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/arabic_numerals_to_chinese.dart';
import 'package:ltrc/contants/semester_code.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/view_utils.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';


class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends ConsumerState<RegisterView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;
    bool isTablet = screenInfo.screenWidth > 600;

    final grade = ref.watch(gradeProvider);
    final semesterCode = ref.watch(semesterCodeProvider);
    final publisherCode = ref.watch(publisherCodeProvider);
    final pwd = ref.watch(pwdProvider);
    final account = ref.watch(accountProvider);

    dynamic obj = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        
        child: Column(
          children: <Widget>[
            SizedBox(height: isTablet ? fontSize * 1.5 : fontSize * 3.0), // 避開 iPhone 11 Pro Max 的瀏海
            /*
            Container(
              height: fontSize * 6.0, // was 7.5 before 學期
              width: deviceWidth * 0.7,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
              ),
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text('請選擇：年級、學期、課本版本',
                      style: TextStyle(
                        color: '#F5F5DC'.toColor(),
                        fontSize: fontSize * 1.2,
                      )),
                ],
              )
            ),
            */
            Container(
              height: fontSize * 6.0, // Adjust as needed
              width: deviceWidth * 0.7,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
              ),
              alignment: Alignment.center,  // Centers the content within the container
              child: Center(  // Ensures the text is centered both vertically and horizontally
                child: Text(
                  '請選擇：年級、學期、課本版本',
                  style: TextStyle(
                    color: '#F5F5DC'.toColor(),
                    fontSize: fontSize * 1.2,
                  ),
                  textAlign: TextAlign.center,  // Centers the text within its own bounds
                ),
              ),
            ),

            SizedBox(height: fontSize * 1.0),
            Icon(
              Icons.home_filled,
              color: '#F8A23A'.toColor(),
              size: deviceHeight * 0.083,
            ),
            LeftRightSwitch(
              // 年級
              iconsColor: '#F5F5DC'.toColor(),
              iconsSize: fontSize * 1.5,
              rightBorder: false,
              onLeftClicked: () => {
                ref.read(gradeProvider.notifier).state =
                    (ref.read(gradeProvider.notifier).state - 2) % 6 + 1
              },
              onRightClicked: () => {
                ref.read(gradeProvider.notifier).state =
                    (ref.read(gradeProvider.notifier).state) % 6 + 1
              },
              middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: deviceWidth * 0.57,
                  height: deviceHeight * 0.067,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '#7DDEF8'.toColor()),
                  child: Text('${numeralToChinese[grade]}年級',
                      style: TextStyle(
                        color: '#000000'.toColor(),
                        fontSize:
                            min(deviceWidth * 0.166, deviceHeight * 0.044),
                      ))),
              isFirst: false,
              isLast: false,
            ),
            SizedBox(height: fontSize * 0.3),
            LeftRightSwitch(
              // 學期
              iconsColor: '#F5F5DC'.toColor(),
              iconsSize: fontSize * 1.5,
              rightBorder: false,
              onLeftClicked: () => {
                ref.read(semesterCodeProvider.notifier).state =
                    (ref.read(semesterCodeProvider.notifier).state - 1) % 2
              },
              onRightClicked: () => {
                ref.read(semesterCodeProvider.notifier).state =
                    (ref.read(semesterCodeProvider.notifier).state + 1) % 2
              },
              middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: deviceWidth * 0.57,
                  height: deviceHeight * 0.067,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '#7DDEF8'.toColor()),
                  child: Text(semesterCodeTable[semesterCode]!,
                      style: TextStyle(
                        color: '#000000'.toColor(),
                        fontSize:
                            min(deviceWidth * 0.166, deviceHeight * 0.044),
                      ))),
              isFirst: false,
              isLast: false,
            ),
            SizedBox(height: fontSize * 0.3),
            LeftRightSwitch(
              // 出版商
              iconsColor: '#F5F5DC'.toColor(),
              iconsSize: fontSize * 1.5,
              rightBorder: false,
              onLeftClicked: () => {
                ref.read(publisherCodeProvider.notifier).state =
                    (ref.read(publisherCodeProvider.notifier).state - 1) % 3
              },
              onRightClicked: () => {
                ref.read(publisherCodeProvider.notifier).state =
                    (ref.read(publisherCodeProvider.notifier).state + 1) % 3
              },
              middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: deviceWidth * 0.57,
                  height: deviceHeight * 0.067,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '#7DDEF8'.toColor()),
                  child: Text(publisherCodeTable[publisherCode]!,
                      style: TextStyle(
                        color: '#000000'.toColor(),
                        fontSize:
                            min(deviceWidth * 0.166, deviceHeight * 0.044),
                      ))),
              isFirst: false,
              isLast: false,
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  0, deviceHeight * 0.0687, 0, fontSize * 1.0),
              child: Container(
                  alignment: AlignmentDirectional.center,
                  width: deviceHeight * 0.095,
                  height: deviceHeight * 0.095,
                  decoration: BoxDecoration(
                    color: '#F8A23A'.toColor(),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chevron_right, size: fontSize * 1.2),
                    color: '#1E1E1E'.toColor(),
                    iconSize: deviceHeight * 0.09,
                    onPressed: () async {
                      try {
                        await UserProvider.addUser(
                          user: User(
                            account: account,
                            password: pwd,
                            safetyQuestionId1: obj['q1'],
                            safetyAnswer1: obj['a1'] as String,
                            safetyQuestionId2: obj['q2'],
                            safetyAnswer2: obj['a2'] as String,
                            grade: grade,
                            semester: semesterCodeTable[semesterCode]!,
                            publisher: publisherCodeTable[publisherCode]!,
                          ),
                        );
                      } catch (e) {
                        throw ("create user error: $e");
                      }

                      ref.read(totalWordCountProvider.notifier).state =
                          await UnitProvider.getTotalWordCount(
                        inputPublisher: publisherCodeTable[publisherCode]!,
                        inputGrade: grade,
                        // inputSemester: "上", // Need to enhance
                        inputSemester: semesterCodeTable[semesterCode]!,
                      );

                      ref.read(learnedWordCountProvider.notifier).state = 0;
                      if (!context.mounted) return;
                      // Navigator.of(context).pushNamed('/mainPage');
                      navigateWithProvider(context, '/mainPage', ref);
                    },
                  )),
            )
          ],
        ),
      ),
    );
  }
}
