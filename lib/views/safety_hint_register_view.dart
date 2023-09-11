import 'package:flutter/material.dart';
import 'package:ltrc/contants/register_question_label.dart';
import 'package:ltrc/extensions.dart';

class SafetyHintRegisterView extends StatefulWidget {
  const SafetyHintRegisterView({super.key});

  @override
  State<SafetyHintRegisterView> createState() => _SafetyHintRegisterState();
}

const String notSelectQuestionRrrorHint = "尚未選擇安全提示問題";
const String noAnswerRrrorHint = "尚未回答安全提示問題";

class _SafetyHintRegisterState extends State<SafetyHintRegisterView> {

  final TextEditingController q1Controller = TextEditingController();
  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController q2Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();

  String showErrorHint = "";
  RegisterQuestionLabel? selectedQuestion1;
  RegisterQuestionLabel? selectedQuestion2;

  @override
  void initState(){
    showErrorHint = "";
    selectedQuestion1 = RegisterQuestionLabel.initial;
    selectedQuestion2 = RegisterQuestionLabel.initial;
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {

    final List<DropdownMenuEntry<RegisterQuestionLabel>> q1Entries = <DropdownMenuEntry<RegisterQuestionLabel>>[];
    final List<DropdownMenuEntry<RegisterQuestionLabel>> q2Entries = <DropdownMenuEntry<RegisterQuestionLabel>>[];

    for (final RegisterQuestionLabel question in RegisterQuestionLabel.values) {
      if (question.question!=""){
        q1Entries.add(
          DropdownMenuEntry<RegisterQuestionLabel>(
            value: question, 
            label: question.question, 
            enabled: question.question != "請選擇問題" && question.question != selectedQuestion2!.question,
          )
        );
      }
    }

    for (final RegisterQuestionLabel question in RegisterQuestionLabel.values) {
      if (question.question!=""){
        q2Entries.add(
          DropdownMenuEntry<RegisterQuestionLabel>(
            value: question, 
            label: question.question, 
            enabled: question.question != "請選擇問題"  && question.question != selectedQuestion1!.question,
          ),
        );
      }
    }

    double deviceHeight = MediaQuery.of(context).size.height;

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
            icon: const Icon(Icons.chevron_left), 
            onPressed: () => Navigator.pop(context),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: '#1E1E1E'.toColor(),
        body: SizedBox.expand(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.04),
              
              const Text(
                '選取安全提示',
                style: TextStyle(
                  fontSize: 28.0,
                )
              ),
              const Text(
                '問題&答案',
                style: TextStyle(
                  fontSize: 28.0,
                )
              ),
              
              SizedBox(height: deviceHeight * 0.04),
              
              Container(
                decoration: BoxDecoration(
                  color: '#7DDEF8'.toColor(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownMenu<RegisterQuestionLabel>(
                  label: const Text(
                    "請選擇問題 1 ",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  controller: q1Controller,
                  width: 303,
                  textStyle: const TextStyle(
                    fontSize: 18,
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
                height: 55.0,
                width: 303.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: '#D9D9D9'.toColor(),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    controller: a1Controller,
                    decoration: InputDecoration(
                      hintText: '回答 1',
                      hintStyle: TextStyle(
                        fontSize: 18.0,
                        color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    )
                  ),
                ),
              ),

              SizedBox(height: deviceHeight * 0.015),
              
              Container(
                decoration: BoxDecoration(
                  color: '#7DDEF8'.toColor(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownMenu<RegisterQuestionLabel>(
                  label: const Text(
                    "請選擇問題 2 ",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  controller: q2Controller,
                  width: 303,
                  textStyle: const TextStyle(
                    fontSize: 16,
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
                height: 55.0,
                width: 303.0,
                decoration: BoxDecoration(
                  color: '#D9D9D9'.toColor(),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 1.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    controller: a2Controller,
                    decoration: InputDecoration(
                      hintText: '回答 2',
                      hintStyle: TextStyle(
                        fontSize: 18.0,
                        color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    )
                  ),
                ),
              ),
              
              SizedBox(height: deviceHeight * 0.02),

              Visibility(
                visible: (showErrorHint != ""),
                maintainAnimation: true,
                maintainSize: true,
                maintainState: true,
                child: Container(
                  height: 18,
                  width: 303,
                  alignment: AlignmentDirectional.topStart,
                  child: Text(
                    showErrorHint,
                    style: TextStyle(
                      color: '#FF0303'.toColor(),
                      fontSize: 14,
                    )
                  )
                )
              ),
              
              SizedBox(height: deviceHeight * 0.02),

              const Text(
                '如果你忘記你的密碼，',
                style: TextStyle(
                  fontSize: 14.0,
                )
              ),

              const Text(
                '這些問題可用來驗證你的身分，',
                style: TextStyle(
                  fontSize: 14.0,
                )
              ),

              const Text(
                '協助你取回密碼。',
                style: TextStyle(
                  fontSize: 14.0,
                )
              ),

              SizedBox(height: deviceHeight * 0.03),

              TextButton(
                onPressed: () {
                  if (q1Controller.text == "請選擇問題" || q2Controller.text == "請選擇問題" ){
                    setState(() {
                      showErrorHint = notSelectQuestionRrrorHint;
                    });
                  }
                  else if (a1Controller.text == "" || a2Controller.text == "" ){
                    setState(() {
                      showErrorHint = noAnswerRrrorHint;
                    });
                  }
                  else{
                    Navigator.of(context).pushNamed(
                      '/register',
                      arguments: {
                        'q1': selectedQuestion1?.value,
                        'a1': a1Controller.text,
                        'q2': selectedQuestion2?.value,
                        'a2': a2Controller.text,
                      }
                    );
                  }
                },
                child: const Text(
                  '下一步',
                  style: TextStyle(
                    fontSize: 24.0,
                  )
                )
              )
            ]
          ),
        ),
      )
    );
  }
}
