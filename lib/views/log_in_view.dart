import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';

class LogInView extends ConsumerStatefulWidget {
  const LogInView({super.key});

  @override
  LogInViewState createState() => LogInViewState();
}

const String pwdConfirmErrorHint = "帳號/密碼錯誤";
const String accountLengthErrorHint = "帳號長度不足 6 位英/數字";
const String abnormalErrorHint = "不正常的錯誤發生了，請告知老師";
class LogInViewState extends ConsumerState<LogInView> {

  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();

  bool pwdVisible = false;
  String showErrorHint = "";

  @override
  void initState(){
    super.initState();
    pwdVisible = true;
    showErrorHint = "";
  }  

  @override
  Widget build(BuildContext context) {
    
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    
    // create a fake user for app review
    UserProvider.addUser(
      user: User(
        account: "testuser", 
        password: "20230022", 
        safetyQuestionId1: 0, 
        safetyAnswer1: "ABC", 
        safetyQuestionId2: 1, 
        safetyAnswer2: "234", 
        grade: 2, 
        publisher: "翰林",
      )
    );

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: '#1E1E1E'.toColor(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: deviceHeight * 0.157),
            Text(
                '學中文',
                style: TextStyle(
                  fontSize: deviceWidth * 46/360,
                )
            ),
            SizedBox(height: deviceHeight * 0.162),
            Container(
              height: deviceHeight * 60/712,
              width: deviceWidth * 5/6,
              decoration: BoxDecoration(
                color: '#7DDEF8'.toColor(),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: TextField(
                  controller: accountController,
                  style: TextStyle(color: '#1C1B1F'.toColor(),),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.account_circle,
                      size: 30.0,
                      color: '#1C1B1F'.toColor(),
                    ),
                    hintText: '帳號名稱',
                    hintStyle: TextStyle(
                      fontSize: 20.0,
                      color: '#1C1B1F'.toColor(),
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    floatingLabelAlignment: FloatingLabelAlignment.center,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  )
                ),
              )
            ),
            SizedBox(height: deviceHeight * 0.073),
            Container(
                height: deviceHeight * 60/712,
                width: deviceWidth * 5/6,
                decoration: BoxDecoration(
                  color: '#7DDEF8'.toColor(),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                  child: TextField(
                    controller: pwdController,
                    obscureText: pwdVisible,
                    style: TextStyle(color: '#1C1B1F'.toColor(),),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 30.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      hintText: '密碼',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      floatingLabelAlignment: FloatingLabelAlignment.center,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(pwdVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            pwdVisible = !pwdVisible;
                          });
                        },
                      ),
                    )
                  ),
                )
            ),
            Center(
              child: SizedBox(
                width: deviceWidth * 5/6,
                child: Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/resetPwdAccount'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(110, 16),
                    ),
                    child: Text(
                      '忘記密碼',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: '#F5F5DC'.toColor(),
                      )
                    ),
                  ),
                ),
              ),
            ),
            Visibility(
              visible: (showErrorHint != ""),
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                width: deviceWidth * 5/6,
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
            SizedBox(height: deviceHeight * 0.038),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () async {
                      if (accountController.text.length < 6){
                        setState(() {
                          showErrorHint = accountLengthErrorHint;
                        });
                      }
                      else {
                        try {
                          User user = await UserProvider.getUser(inputAccount: accountController.text);
                          if (user.password != pwdController.text){
                            setState(() {
                              showErrorHint = pwdConfirmErrorHint;
                            });
                          }
                          else {
                            ref.read(accountProvider.notifier).state = accountController.text;
                            ref.read(userNameProvider.notifier).state = user.username;
                            ref.read(gradeProvider.notifier).state = user.grade;
                            ref.read(publisherCodeProvider.notifier).state = publisherCodeTable.keys.firstWhere((e) => publisherCodeTable[e] == user.publisher);
                            ref.read(totalWordCountProvider.notifier).state = await UnitProvider.getTotalWordCount(
                              inputPublisher: user.publisher, 
                              inputGrade: user.grade, 
                              inputSemester: "上",
                            );
                            ref.read(learnedWordCountProvider.notifier).state = await UnitProvider.getLearnedWordCount(
                              inputAccount: accountController.text,
                              inputPublisher: user.publisher, 
                              inputGrade: user.grade, 
                              inputSemester: "上",
                            );
                            Navigator.of(context).pushNamed('/mainPage');
                          }
                        } catch (e){
                          setState(() {
                            showErrorHint = abnormalErrorHint;
                          });
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                      minimumSize: const Size(110, 30),
                    ),
                    child: Text(
                      '登入',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: '#F5F5DC'.toColor(),
                      )
                    )
                  ),
                  const Text(
                    '/',
                    style: TextStyle(
                      fontSize: 24.0,
                    )
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/registerAccount'),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(110, 30),
                    ),
                    child: Text(
                      '註冊',
                      style: TextStyle(
                        fontSize: 24.0,
                        color: '#F5F5DC'.toColor(),
                      )
                    )
                  )
                ]
              )
            ),
          ]
        )
      )
    );
  }
}