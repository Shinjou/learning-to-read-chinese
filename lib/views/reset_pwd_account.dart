import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class ResetPwdAccountView extends StatefulWidget {
  const ResetPwdAccountView({super.key});

  @override
  State<ResetPwdAccountView> createState() => _ResetPwdAccountViewState();
}

const String pwdLengthErrorHint = "帳號長度不足 6 位英/數字";
const String pwdConfirmErrorHint = "確認密碼錯誤";

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
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: deviceHeight * 0.08),
            Text(
              '請輸入帳號',
              style: TextStyle(
                color: '#F5F5DC'.toColor(),
                fontSize: 46.0,
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
                child: Text(
                  '至少6個字母/數字',
                  style: TextStyle(
                    color: '#F5F5DC'.toColor(),
                    fontSize: 14,
                    fontFamily: 'Serif'
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
                    color: '#F5F5DC'.toColor(),
                    fontSize: 14,
                    fontFamily: 'Serif'
                  )
                )
              )
            ),
            SizedBox(height: deviceHeight * 0.0627),
            TextButton(
              onPressed: () {
                if (accountController.text.length < 4){
                  setState(() {
                    showErrorHint = pwdLengthErrorHint;
                  });
                }
                // TODO: Update account to database
                else{
                  Navigator.of(context).pushNamed('/main');
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
