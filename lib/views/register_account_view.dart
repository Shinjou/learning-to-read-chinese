import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/register_question_label.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class RegisterAccountView extends ConsumerStatefulWidget {
  const RegisterAccountView({super.key});

  @override
  ConsumerState<RegisterAccountView> createState() => _RegisterAccountViewState();
}

const String accountLengthErrorHint = "帳號長度不足 6 位英/數字";
const String pwdLengthErrorHint = "密碼長度不足 4 位英/數字";
const String pwdConfirmErrorHint = "確認密碼錯誤";
const String duplicateAccountErrorHint = "此帳號已被建立";

class _RegisterAccountViewState extends ConsumerState<RegisterAccountView> {
  bool showAccountHint = false;
  bool showPasswordHint = false;
  bool pwdVisible = false;
  bool confirmPwdVisible = false;
  String showErrorHint = "";
  TextEditingController accountController = TextEditingController();
  TextEditingController pwdController = TextEditingController();
  TextEditingController confirmPwdController = TextEditingController();
  
  // We will shortcut these security questions by using 1234
  final TextEditingController q1Controller = TextEditingController();
  final TextEditingController a1Controller = TextEditingController();
  final TextEditingController q2Controller = TextEditingController();
  final TextEditingController a2Controller = TextEditingController();
  RegisterQuestionLabel? selectedQuestion1 = RegisterQuestionLabel.pet;
  RegisterQuestionLabel? selectedQuestion2 = RegisterQuestionLabel.name;
  
  @override
  void initState() {
    super.initState();
    pwdVisible = true;
    confirmPwdVisible = true;
    showErrorHint = "";
      // Set initial text
    a1Controller.text = "1234";
    a2Controller.text = "1234";  
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = getScreenInfo(context);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;
    double deviceWidth = screenInfo.screenWidth;

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: '#1E1E1E'.toColor(),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        backgroundColor: '#1E1E1E'.toColor(),
        body: SizedBox.expand(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.050),
                Text('學國語',
                    style: TextStyle(
                      color: '#F5F5DC'.toColor(),
                      fontSize: deviceWidth * 46 / 360,
                    )),
                SizedBox(height: deviceHeight * 0.050),
                Visibility(
                    visible: showAccountHint,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Container(
                        height: fontSize * 1.4,
                        width: deviceWidth * 5 / 6,
                        alignment: AlignmentDirectional.topStart,
                        child: Text('至少6個字母/數字',
                            style: TextStyle(
                              color: '#F5F5DC'.toColor(),
                              fontSize: fontSize * 0.8,
                            )))),
                Container(
                  height: fontSize * 3.5,
                  width: deviceWidth * 5 / 6,
                  decoration: BoxDecoration(
                      color: '#7DDEF8'.toColor(),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          width: 0.3 * fontSize, color: '#F5F5DC'.toColor())),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        setState(() {
                          showAccountHint = !showAccountHint;
                          if (showErrorHint == accountLengthErrorHint &&
                              accountController.text.length >= 6) {
                            showErrorHint = "";
                          }
                        });
                      },
                      child: TextField(
                          controller: accountController,
                          style: TextStyle(
                              color: '#1C1B1F'.toColor(), fontSize: fontSize),
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.account_circle,
                              size: fontSize * 1.8,
                              color: '#1C1B1F'.toColor(),
                            ),
                            hintText: '帳號名稱',
                            hintStyle: TextStyle(
                                fontSize: fontSize * 1.2,
                                color: '#013E6D'.toColor()),
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                          )),
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
                        height: fontSize * 1.4,
                        width: deviceWidth * 5 / 6,
                        alignment: AlignmentDirectional.topStart,
                        child: Text('至少4個數字',
                            style: TextStyle(
                              color: '#F5F5DC'.toColor(),
                              fontSize: fontSize * 0.8,
                            )))),
                Container(
                    height: fontSize * 3.5,
                    width: deviceWidth * 5 / 6,
                    decoration: BoxDecoration(
                        color: '#7DDEF8'.toColor(),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 0.3 * fontSize,
                            color: '#F5F5DC'.toColor())),
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            showPasswordHint = !showPasswordHint;
                            if (showErrorHint == pwdLengthErrorHint &&
                                pwdController.text.length >= 4) {
                              showErrorHint = "";
                            }
                          });
                        },
                        child: TextField(
                            controller: pwdController,
                            obscureText: pwdVisible,
                            style: TextStyle(
                                color: '#1C1B1F'.toColor(),
                                fontSize: fontSize),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.lock,
                                size: fontSize * 1.8,
                                color: '#1C1B1F'.toColor(),
                              ),
                              hintText: '密碼',
                              hintStyle: TextStyle(
                                  fontSize: fontSize * 1.2,
                                  color: '#013E6D'.toColor()),
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              suffixIcon: IconButton(
                                icon: Icon(pwdVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                iconSize: fontSize,
                                onPressed: () {
                                  setState(() {
                                    pwdVisible = !pwdVisible;
                                  });
                                },
                              ),
                            )),
                      ),
                    )),
                SizedBox(height: deviceHeight * 0.0343),
                Container(
                  height: fontSize * 3.5,
                  width: deviceWidth * 5 / 6,
                  decoration: BoxDecoration(
                      color: '#7DDEF8'.toColor(),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          width: 0.3 * fontSize, color: '#F5F5DC'.toColor())),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                    child: TextField(
                        controller: confirmPwdController,
                        obscureText: confirmPwdVisible,
                        style: TextStyle(
                            color: '#1C1B1F'.toColor(), fontSize: fontSize),
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.lock,
                            size: fontSize * 1.8,
                            color: '#1C1B1F'.toColor(),
                          ),
                          hintText: '確認密碼',
                          hintStyle: TextStyle(
                              fontSize: fontSize * 1.2,
                              color: '#013E6D'.toColor()),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          suffixIcon: IconButton(
                            icon: Icon(confirmPwdVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            iconSize: fontSize,
                            onPressed: () {
                              setState(() {
                                confirmPwdVisible = !confirmPwdVisible;
                              });
                            },
                          ),
                        )),
                  ),
                ),
                SizedBox(height: deviceHeight * 0.012),
                Visibility(
                    visible: (showErrorHint != ""),
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Container(
                        height: fontSize * 1.4,
                        width: deviceWidth * 5 / 6,
                        alignment: AlignmentDirectional.topStart,
                        child: Text(showErrorHint,
                            style: TextStyle(
                              color: '#FF0303'.toColor(),
                              fontSize: fontSize * 0.8,
                            )))),
                Consumer(builder: (context, ref, child) {
                  return TextButton(
                      onPressed: () async {
                        if (accountController.text.length < 6) {
                          setState(() {
                            showErrorHint = accountLengthErrorHint;
                          });
                        } else {
                          List<String> userAccounts =
                              await UserProvider.getAllUserAccounts();
                          if (userAccounts.contains(accountController.text)) {
                            setState(() {
                              showErrorHint = duplicateAccountErrorHint;
                            });
                          } else if (pwdController.text.length < 4) {
                            setState(() {
                              showErrorHint = pwdLengthErrorHint;
                            });
                          } else if (pwdController.text !=
                              confirmPwdController.text) {
                            setState(() {
                              showErrorHint = pwdConfirmErrorHint;
                            });
                          } else {
                            ref.read(accountProvider.notifier).state =
                                accountController.text;
                            ref.read(pwdProvider.notifier).state =
                                pwdController.text;
                            if (!context.mounted) return;
                            // Navigator.of(context).pushNamed('/safetyHintRegister');
                            // navigateWithProvider(context, '/safetyHintRegister', ref);
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
                            fontSize: fontSize * 1.4,
                            color: '#F5F5DC'.toColor(),
                          )));
                })
              ]),
        ),
      ));

  }
}
