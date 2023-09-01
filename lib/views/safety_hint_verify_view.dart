import 'package:flutter/material.dart';
import 'package:ltrc/contants/register_question_label.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/extensions.dart';

class SafetyHintVerifyView extends StatefulWidget {
  const SafetyHintVerifyView({super.key});

  @override
  State<SafetyHintVerifyView> createState() => _SafetyHintVerifyState();
}

const String notAnsweredRrrorHint = "尚未回答完安全提示問題";
const String inCorrectRrrorHint = "安全提示問題回答錯誤";

class _SafetyHintVerifyState extends State<SafetyHintVerifyView> {

  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();

  String showErrorHint = "";

  @override
  void initState(){
    showErrorHint = "";
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    User user = obj['user']; 

    String question1 = registerQuestions[user.safetyQuestionId1];
    String question2 = registerQuestions[user.safetyQuestionId2];
    String a1 = user.safetyAnswer1;
    String a2 = user.safetyAnswer2;

    return Scaffold(
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
            Text(
              '忘記密碼',
              style: TextStyle(
                color: '#F5F5DC'.toColor(),
                fontSize: 46.0,
              )
            ),
            SizedBox(height: deviceHeight * 0.015),
            Text(
              '請回答安全提示問題',
              style: TextStyle(
                color: '#F5F5DC'.toColor(),
                fontSize: 20.0,
              )
            ),
            
            SizedBox(height: deviceHeight * 0.08),
            
            SizedBox(
              height: 24,
              width: 303,
              child:Text(
                question1,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: "#F5F5DC".toColor(),
                ),
              ),
            ),
                    
            SizedBox(height: deviceHeight * 0.01),

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
                      fontSize: 16.0,
                      color: '#013E6D'.toColor()
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  )
                ),
              ),
            ),

            SizedBox(height: deviceHeight * 0.04),
            
            SizedBox(
              height: 24,
              width: 303,
              child:Text(
                question2,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 16,
                  color: "#F5F5DC".toColor(),
                ),
              ),
            ),
                    
            SizedBox(height: deviceHeight * 0.01),
            
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
                      fontSize: 16.0,
                      color: '#013E6D'.toColor()
                    ),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  )
                ),
              ),
            ),
            
            SizedBox(height: deviceHeight * 0.01),

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

            SizedBox(height: deviceHeight * 0.03),

            TextButton(
              onPressed: () {
                if (a1Controller.text == "" || a2Controller.text == "" ){
                  setState(() {
                    showErrorHint = notAnsweredRrrorHint;
                  });
                }
                else if (a1Controller.text.trim() != a1 || a2Controller.text.trim() != a2 ){
                  setState(() {
                    showErrorHint = inCorrectRrrorHint;
                  });
                }
                else{
                  Navigator.of(context).pushNamed('/setNewPwd', arguments: {'user': user});
                }
              },
              child: Text(
                '下一步',
                style: TextStyle(
                  fontSize: 24.0,
                  color: '#F5F5DC'.toColor(),
                )
              )
            )
          ]
        ),
      ),
    );
  }
}
