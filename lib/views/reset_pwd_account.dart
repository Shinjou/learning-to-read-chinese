import 'package:flutter/material.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';

class ResetPwdAccountView extends StatefulWidget {
  const ResetPwdAccountView({super.key});

  @override
  State<ResetPwdAccountView> createState() => _ResetPwdAccountViewState();
}

const String pwdLengthErrorHint = "帳號長度不足 6 位英/數字";
const String noAccountErrorHint = "帳號輸入錯誤或不存在";

class _ResetPwdAccountViewState extends State<ResetPwdAccountView> {

  bool showAccountHint = false;
  String showErrorHint = "";
  TextEditingController accountController = TextEditingController();

  @override
  void initState(){
    super.initState(); 
    showErrorHint = "";
  }  

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;

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
            SizedBox(height: deviceHeight * 0.15),
            const Text(
              '忘記密碼',
              style: TextStyle(
                fontSize: 42.0,
              )
            ),
            SizedBox(height: deviceHeight * 0.04),
            const Text(
              '請輸入帳號',
              style: TextStyle(
                fontSize: 20.0,
              )
            ),
    
            SizedBox(height: deviceHeight * 0.08),
            Visibility(
              visible: showAccountHint,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                height: 24,
                width: 303,
                alignment: AlignmentDirectional.topStart,
                child: const Text(
                  '至少6個字母/數字',
                  style: TextStyle(
                    fontSize: 14,
                  )
                )
              )
            ),
            Container(
              height: 60.0,
              width: 303.0,
              decoration: BoxDecoration(
                color: '#7DDEF8'.toColor(),
                borderRadius: BorderRadius.circular(5),
                border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                child: Focus(
                  onFocusChange: (hasFocus){
                    setState(() {
                      showAccountHint = !showAccountHint;
                      if (showErrorHint == pwdLengthErrorHint && accountController.text.length >= 4){
                        showErrorHint = "";
                      }}
                    );
                  },
                  child: TextField(
                    controller: accountController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        size: 30.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      hintText: '請輸入帳號',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                        color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    )
                  ),
                ),
              )
            ),
            
            Visibility(
              visible: (showErrorHint != ""),
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                height: 24,
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
            SizedBox(height: deviceHeight * 0.0627),
            TextButton(
              onPressed: () async {
                try {
                  if (accountController.text.length < 6){
                    setState(() {
                      showErrorHint = pwdLengthErrorHint;
                    });
                  }
                  else {
                    User user = await UserProvider.getUser(inputAccount: accountController.text);
                    Navigator.of(context).pushNamed(
                      '/safetyHintVerify', 
                      arguments: {
                        'user': user
                      }
                    );
                  }
                } catch (e){
                  setState(() {
                    showErrorHint = noAccountErrorHint;
                  });
                  throw("[Reset Pwd Account] Find user account exception: $e");
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
    );
  }
}
