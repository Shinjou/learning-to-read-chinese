import 'package:flutter/material.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';

class ResetPwdView extends ConsumerStatefulWidget {
  const ResetPwdView({super.key});

  @override
  ConsumerState<ResetPwdView> createState() => _ResetPwdViewState();
}

const String pwdLengthErrorHint = "密碼長度不足 4 位英/數字";
const String pwdConfirmErrorHint = "確認密碼錯誤";

class _ResetPwdViewState extends ConsumerState<ResetPwdView> {
  bool showPasswordHint = false;
  bool pwdVisible = false;
  bool confirmPwdVisible = false;
  String showErrorHint = "";
  TextEditingController pwdController = TextEditingController();
  TextEditingController confirmPwdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    pwdVisible = true;
    confirmPwdVisible = true;
    showErrorHint = "";
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;

    dynamic obj = ModalRoute.of(context)!.settings.arguments;
    User user = obj['user'];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.08),
              Text('重設密碼',
                  style: TextStyle(
                    fontSize: fontSize * 2.7,
                  )),
              SizedBox(height: deviceHeight * 0.08),
              Visibility(
                  visible: showPasswordHint,
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Container(
                      height: fontSize * 1.4,
                      width: fontSize * 17.8,
                      alignment: AlignmentDirectional.topStart,
                      child: Text('至少4個數字',
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                          )))),
              Container(
                  height: fontSize * 3.5,
                  width: fontSize * 17.8,
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
                            color: Colors.black,
                            fontSize: fontSize,
                          ),
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
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
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
                  width: fontSize * 17.8,
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
                          color: Colors.black,
                          fontSize: fontSize,
                        ),
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
                  )),
              Visibility(
                  visible: (showErrorHint != ""),
                  maintainAnimation: true,
                  maintainSize: true,
                  maintainState: true,
                  child: Container(
                      height: fontSize * 1.4,
                      width: fontSize * 17.8,
                      alignment: AlignmentDirectional.topStart,
                      child: Text(showErrorHint,
                          style: TextStyle(
                            fontSize: fontSize * 0.8,
                          )))),
              SizedBox(height: deviceHeight * 0.0627),
              TextButton(
                  onPressed: () {
                    if (pwdController.text.length < 4) {
                      setState(() {
                        showErrorHint = pwdLengthErrorHint;
                      });
                    } else if (pwdController.text !=
                        confirmPwdController.text) {
                      setState(() {
                        showErrorHint = pwdConfirmErrorHint;
                      });
                    } else {
                      user.password = pwdController.text;
                      UserProvider.updateUser(user: user);
                      // Navigator.of(context).pushNamed('/login');
                      navigateWithProvider(context, '/login', ref);
                    }
                  },
                  child: Text('完成',
                      style: TextStyle(
                        fontSize: fontSize * 1.4,
                        color: '#F5F5DC'.toColor(),
                      )))
            ]),
      ),
    );
  }
}
