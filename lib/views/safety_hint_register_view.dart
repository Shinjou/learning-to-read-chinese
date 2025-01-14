import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/register_question_label.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class SafetyHintRegisterView extends ConsumerStatefulWidget {
  const SafetyHintRegisterView({super.key});

  @override
  ConsumerState<SafetyHintRegisterView> createState() => _SafetyHintRegisterState();
}

const String notSelectQuestionRrrorHint = "尚未選擇安全提示問題";
const String noAnswerRrrorHint = "尚未回答安全提示問題";

class _SafetyHintRegisterState extends ConsumerState<SafetyHintRegisterView> {
  final TextEditingController q1Controller = TextEditingController();
  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController q2Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();

  String showErrorHint = "";
  RegisterQuestionLabel? selectedQuestion1;
  RegisterQuestionLabel? selectedQuestion2;

  @override
  void initState() {
    showErrorHint = "";
    selectedQuestion1 = RegisterQuestionLabel.initial;
    selectedQuestion2 = RegisterQuestionLabel.initial;
    super.initState();
  }

  @override
  void dispose() {
    q1Controller.dispose();
    a1Controller.dispose();
    q2Controller.dispose();
    a2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.read(screenInfoProvider);
    final screenInfo = ref.read(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;

    final List<DropdownMenuEntry<RegisterQuestionLabel>> q1Entries =
        <DropdownMenuEntry<RegisterQuestionLabel>>[];
    final List<DropdownMenuEntry<RegisterQuestionLabel>> q2Entries =
        <DropdownMenuEntry<RegisterQuestionLabel>>[];

    for (final RegisterQuestionLabel question in RegisterQuestionLabel.values) {
      if (question.question != "") {
        q1Entries.add(DropdownMenuEntry<RegisterQuestionLabel>(
          label: question.question,
          value: question,
          style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(
              TextStyle(
                fontSize: fontSize * 0.6,
                color: veryDarkGrayishBlue,
              ),
            ),
          ),
          enabled: question.question != "請選擇問題" &&
              question.question != selectedQuestion2!.question,
        ));
      }
    }

    for (final RegisterQuestionLabel question in RegisterQuestionLabel.values) {
      if (question.question != "") {
        q2Entries.add(
          DropdownMenuEntry<RegisterQuestionLabel>(
            label: question.question,
            value: question,
            style: ButtonStyle(
              textStyle: MaterialStateProperty.all<TextStyle>(
                TextStyle(
                  fontSize: fontSize * 0.6,
                  color: veryDarkGrayishBlue,
                ),
              ),
            ),
            enabled: question.question != "請選擇問題" &&
                question.question != selectedQuestion1!.question,
          ),
        );
      }
    }

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
              },
            ),
          ),
          resizeToAvoidBottomInset: false,
          backgroundColor: veryDarkGray,
          body: SizedBox.expand(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // SizedBox(height: deviceHeight * 0.04),

                  Text('選取安全提示',
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                      )),
                  Text('問題&答案',
                      style: TextStyle(
                        fontSize: fontSize * 1.2,
                      )),

                  // SizedBox(height: deviceHeight * 0.04),

                  Container(
                    decoration: BoxDecoration(
                      color: lightSkyBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownMenu<RegisterQuestionLabel>(
                      label: Text(
                        "請選擇問題 1 ",
                        style: TextStyle(
                          fontSize: fontSize,
                        ),
                      ),
                      controller: q1Controller,
                      width: 17.8 * fontSize,
                      textStyle: TextStyle(
                        fontSize: fontSize,
                        color: veryDarkGrayishBlue,
                      ),
                      dropdownMenuEntries: q1Entries,
                      onSelected: (RegisterQuestionLabel? questionLabel) {
                        setState(() {
                          selectedQuestion1 = questionLabel;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: deviceHeight * 0.015),
                  Container(
                    height: 2.5 * fontSize,
                    width: 17.8 * fontSize,
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
                          style: TextStyle(
                              fontSize:
                                  fontSize, // Set your desired font size here
                              color: veryDarkGrayishBlue),
                          decoration: InputDecoration(
                            hintText: '回答 1',
                            hintStyle: TextStyle(
                                fontSize:
                                    fontSize, // Also set font size for hint text if needed
                                color: veryDarkGrayishBlue),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )),
                    ),
                  ),

                  SizedBox(height: deviceHeight * 0.015),

                  Container(
                    decoration: BoxDecoration(
                      color: lightSkyBlue,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: DropdownMenu<RegisterQuestionLabel>(
                      label: Text(
                        "請選擇問題 2 ",
                        style: TextStyle(
                          fontSize: fontSize,
                          color: veryDarkGrayishBlue,
                        ),
                      ),
                      controller: q2Controller,
                      width: 17.8 * fontSize,
                      textStyle: TextStyle(
                        fontSize: fontSize,
                        color: veryDarkGrayishBlue,
                      ),
                      dropdownMenuEntries: q2Entries,
                      onSelected: (RegisterQuestionLabel? questionLabel) {
                        setState(() {
                          selectedQuestion2 = questionLabel;
                        });
                      },
                    ),
                  ),

                  SizedBox(height: deviceHeight * 0.015),
                  Container(
                    height: 2.5 * fontSize,
                    width: 17.8 * fontSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: lightGray,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 0.1 * fontSize, color: beige)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: TextField(
                          controller: a2Controller,
                          style: TextStyle(
                              fontSize:
                                  fontSize, // Set your desired font size here
                              color: veryDarkGrayishBlue),
                          decoration: InputDecoration(
                            hintText: '回答 2',
                            hintStyle: TextStyle(
                                fontSize:
                                    fontSize, // Also set font size for hint text if needed
                                color: veryDarkGrayishBlue),
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                          )),
                    ),
                  ),

                  SizedBox(height: fontSize),

                  Visibility(
                      visible: (showErrorHint != ""),
                      maintainAnimation: true,
                      maintainSize: true,
                      maintainState: true,
                      child: Container(
                          height: fontSize * 0.5,
                          width: fontSize * 17.8,
                          alignment: AlignmentDirectional.topStart,
                          child: Text(showErrorHint,
                              style: TextStyle(
                                color: brightRed,
                                fontSize: fontSize * 0.8,
                              )))),

                  SizedBox(height: fontSize * 0.5),

                  Text('如果你忘記密碼，',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                      )),

                  Text('這些問題可驗證你的身份，',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                      )),

                  Text('協助你取回密碼。',
                      style: TextStyle(
                        fontSize: fontSize * 0.8,
                      )),

                  SizedBox(height: fontSize * 0.5),

                  TextButton(
                      onPressed: () {
                        if (q1Controller.text == "請選擇問題" ||
                            q2Controller.text == "請選擇問題") {
                          setState(() {
                            showErrorHint = notSelectQuestionRrrorHint;
                          });
                        } else if (a1Controller.text == "" ||
                            a2Controller.text == "") {
                          setState(() {
                            showErrorHint = noAnswerRrrorHint;
                          });
                        } else {
                          if (context.mounted) {
                            navigateWithProvider(
                              context, 
                              '/register', 
                              ref, 
                              arguments: {
                              'q1': selectedQuestion1?.value,
                              'a1': a1Controller.text,
                              'q2': selectedQuestion2?.value,
                              'a2': a2Controller.text,
                            });
                          }
                        }
                      },
                      child: Text('下一步',
                          style: TextStyle(
                            fontSize: fontSize * 1.2,
                            color: beige,
                          )))
                ]),
          ),
        ));
  }
}
