import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ltrc/extensions.dart';

class RegisterAccountView extends StatefulWidget {
  const RegisterAccountView({super.key});

  @override
  State<RegisterAccountView> createState() => _RegisterAccountViewState();
}

const String accountLengthErrorHint = "帳號長度不足 6 位英/數字";
const String pwdLengthErrorHint = "密碼長度不足 4 位英/數字";
const String pwdConfirmErrorHint = "確認密碼錯誤";

class _RegisterAccountViewState extends State<RegisterAccountView> {

  bool showAccountHint = false;
  bool showPasswordHint = false;
  bool pwdVisible = false; 
  bool confirmPwdVisible = false;
  String showErrorHint = "";
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController confirmPwdController = TextEditingController();

  @override
  void initState(){
    super.initState();
    pwdVisible = true; 
    confirmPwdVisible = true;
    showErrorHint = "";
  }  

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: '#1E1E1E'.toColor(),
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: deviceHeight * 0.15),
            Text(
              '學中文',
              style: TextStyle(
                color: '#F5F5DC'.toColor(),
                fontSize: 46.0,
                fontFamily: 'Serif',
              )
            ),
            SizedBox(height: deviceHeight * 0.096),
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
                borderRadius: BorderRadius.circular(20),
                border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 6.0),
                child: Focus(
                  onFocusChange: (hasFocus) {
                    setState(() {
                      showAccountHint = !showAccountHint;
                      if (showErrorHint == accountLengthErrorHint && accountController.text.length >= 6){
                        showErrorHint = "";
                      }
                    });
                  },
                  child: TextField(
                    controller: accountController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.account_circle,
                        size: 30.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      hintText: '帳號名稱',
                      hintStyle: TextStyle(
                        fontSize: 20.0,
                        fontFamily: 'Serif',
                        color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                    )
                  ),
                ),
              ),
            ),
            SizedBox(height: deviceHeight * 0.012),
            Visibility(
              visible: showPasswordHint,
              maintainAnimation: true,
              maintainSize: true,
              maintainState: true,
              child: Container(
                height: 24,
                width: 303,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  '至少4個數字',
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 6.0),
                  child: Focus(
                    onFocusChange: (hasFocus){
                      setState(() {
                        showPasswordHint = !showPasswordHint;
                        if (showErrorHint == pwdLengthErrorHint && pwdController.text.length >= 4){
                          showErrorHint = "";
                        }}
                      );
                    },
                    child: TextField(
                      controller: pwdController,
                      obscureText: pwdVisible,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          size: 30.0,
                          color: '#1C1B1F'.toColor(),
                        ),
                        hintText: '密碼',
                        hintStyle: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Serif',
                            color: '#013E6D'.toColor()
                        ),
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
                  ),
                )
            ),
            SizedBox(height: deviceHeight * 0.0343),
            Container(
                height: 60.0,
                width: 303.0,
                decoration: BoxDecoration(
                    color: '#7DDEF8'.toColor(),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(width: 5.0, color: '#F5F5DC'.toColor())
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 6.0),
                  child: TextField(
                    controller: confirmPwdController,
                    obscureText: confirmPwdVisible,
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Icons.lock,
                        size: 30.0,
                        color: '#1C1B1F'.toColor(),
                      ),
                      hintText: '確認密碼',
                      hintStyle: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Serif',
                          color: '#013E6D'.toColor()
                      ),
                      enabledBorder: InputBorder.none,
                      suffixIcon: IconButton(
                        icon: Icon(confirmPwdVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            confirmPwdVisible = !confirmPwdVisible;
                          });
                        },
                      ),
                    )
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
                if (accountController.text.length < 6){
                  setState(() {
                    showErrorHint = accountLengthErrorHint;
                  });
                }
                else if (pwdController.text.length < 4){
                  setState(() {
                    showErrorHint = pwdLengthErrorHint;
                  });
                }
                else if (pwdController.text != confirmPwdController.text){
                  setState(() {
                    showErrorHint = pwdConfirmErrorHint;
                  });
                }
                // TODO: Check if account is created before.
                else{
                  Navigator.of(context).pushNamed('/register');
                }
              },
              child: Text(
                '註冊並登入',
                style: TextStyle(
                  fontSize: 24.0,
                  fontFamily: 'Serif',
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
