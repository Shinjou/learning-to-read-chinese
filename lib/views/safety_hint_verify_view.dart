import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/register_question_label.dart';
import 'package:ltrc/data/models/user_model.dart';

import 'package:ltrc/providers.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class SafetyHintVerifyView extends ConsumerStatefulWidget {
  const SafetyHintVerifyView({super.key});

  @override
  ConsumerState<SafetyHintVerifyView> createState() => _SafetyHintVerifyState();
}

const String notAnsweredRrrorHint = "尚未回答完安全提示問題";
const String inCorrectRrrorHint = "安全提示問題回答錯誤";

class _SafetyHintVerifyState extends ConsumerState<SafetyHintVerifyView> {
  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();

  String showErrorHint = "";

  @override
  void initState() {
    showErrorHint = "";
    super.initState();
  }

  @override
  void dispose() {
    a1Controller.dispose();
    a2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.read(screenInfoProvider);
    final screenInfo = ref.read(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    User user = obj['user'];

    String question1 = registerQuestions[user.safetyQuestionId1];
    String question2 = registerQuestions[user.safetyQuestionId2];
    String a1 = user.safetyAnswer1;
    String a2 = user.safetyAnswer2;

    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
              onPressed: () {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            ),
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: veryDarkGray,
          body: SizedBox.expand(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: deviceHeight * 0.04),
                  Text('忘記密碼',
                      style: TextStyle(
                        fontSize: fontSize * 2.7,
                      )),
                  SizedBox(height: deviceHeight * 0.015),
                  Text('請回答安全提示問題',
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                      )),
                  SizedBox(height: deviceHeight * 0.08),
                  SizedBox(
                    height: fontSize * 1.4,
                    width: fontSize * 17.8,
                    child: Text(
                      question1,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.01),
                  Container(
                    height: fontSize * 3.2,
                    width: fontSize * 17.8,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 0.1 * fontSize, color: beige)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: TextField(
                          controller: a1Controller,
                          style: const TextStyle(
                            color: veryDarkGrayishBlue,
                          ),
                          decoration: InputDecoration(
                            hintText: '回答 1',
                            hintStyle: TextStyle(
                                fontSize: fontSize, color: deepBlue),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )),
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.04),
                  SizedBox(
                    height: fontSize * 1.4,
                    width: fontSize * 17.8,
                    child: Text(
                      question2,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: fontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.01),
                  Container(
                    height: fontSize * 3.2,
                    width: fontSize * 17.8,
                    decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 0.1 * fontSize, color: beige)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: TextField(
                          controller: a2Controller,
                          style: const TextStyle(
                            color: veryDarkGrayishBlue,
                          ),
                          decoration: InputDecoration(
                            hintText: '回答 2',
                            hintStyle: TextStyle(
                                fontSize: fontSize, color: deepBlue),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )),
                    ),
                  ),
                  SizedBox(height: deviceHeight * 0.01),
                  Visibility(
                      visible: (showErrorHint != ""),
                      maintainAnimation: true,
                      maintainSize: true,
                      maintainState: true,
                      child: Container(
                          height: fontSize,
                          width: fontSize * 17.8,
                          alignment: AlignmentDirectional.topStart,
                          child: Text(showErrorHint,
                              style: TextStyle(
                                color: brightRed,
                                fontSize: fontSize * 0.8,
                              )))),
                  SizedBox(height: deviceHeight * 0.03),
                  TextButton(
                      onPressed: () {
                        if (a1Controller.text == "" ||
                            a2Controller.text == "") {
                          setState(() {
                            showErrorHint = notAnsweredRrrorHint;
                          });
                        } else if (a1Controller.text.trim() != a1 ||
                            a2Controller.text.trim() != a2) {
                          setState(() {
                            showErrorHint = inCorrectRrrorHint;
                          });
                        } else {
                          if (context.mounted) {
                            navigateWithProvider(
                              context, 
                              '/setNewPwd', 
                              ref, 
                              arguments: {'user': user}
                            );
                          }                              
                        }
                      },
                      child: Text('下一步',
                          style: TextStyle(
                            fontSize: fontSize * 1.4,
                            color: beige
,
                          )))
                ]),
          ),
        ));
  }
}
