import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class ResetPwdAccountView extends ConsumerStatefulWidget {
  const ResetPwdAccountView({super.key});

  @override
  ConsumerState<ResetPwdAccountView> createState() => _ResetPwdAccountViewState();
}

const String pwdLengthErrorHint = "帳號長度不足 6 位英/數字";
const String noAccountErrorHint = "帳號輸入錯誤或不存在";

class _ResetPwdAccountViewState extends ConsumerState<ResetPwdAccountView> {
  bool showAccountHint = false;
  String showErrorHint = "";
  TextEditingController accountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    showErrorHint = "";
  }

  @override
  Widget build(BuildContext context) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;    
    double deviceHeight = screenInfo.screenHeight;

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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        resizeToAvoidBottomInset: false,
        backgroundColor: veryDarkGray,
        body: SizedBox.expand(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.15),
                Text('忘記密碼',
                    style: TextStyle(
                      fontSize: fontSize * 2.5,
                    )),
                SizedBox(height: deviceHeight * 0.04),
                Text('請輸入帳號',
                    style: TextStyle(
                      fontSize: fontSize * 1.2,
                    )),
                SizedBox(height: deviceHeight * 0.08),
                Visibility(
                    visible: showAccountHint,
                    maintainAnimation: true,
                    maintainSize: true,
                    maintainState: true,
                    child: Container(
                        height: fontSize * 1.4,
                        width: fontSize * 17.8,
                        alignment: AlignmentDirectional.topStart,
                        child: Text('至少6個字母/數字',
                            style: TextStyle(
                              fontSize: fontSize * 0.8,
                            )))),
                Container(
                    height: fontSize * 3.5,
                    width: fontSize * 17.8,
                    decoration: BoxDecoration(
                        color: lightSkyBlue,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            width: 0.3 * fontSize, color: beige)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                      child: Focus(
                        onFocusChange: (hasFocus) {
                          setState(() {
                            showAccountHint = !showAccountHint;
                            if (showErrorHint == pwdLengthErrorHint &&
                                accountController.text.length >= 4) {
                              showErrorHint = "";
                            }
                          });
                        },
                        child: TextField(
                            controller: accountController,
                            style: TextStyle(
                              color: veryDarkGrayishBlue,
                              fontSize: fontSize,
                            ),
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.account_circle,
                                size: fontSize * 1.8,
                                color: veryDarkGrayishBlue,
                              ),
                              hintText: '請輸入帳號',
                              hintStyle: TextStyle(
                                  fontSize: fontSize * 1.2,
                                  color: deepBlue),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            )),
                      ),
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
                              color: brightRed,
                              fontSize: fontSize * 0.8,
                            )))),
                SizedBox(height: deviceHeight * 0.0627),
                TextButton(
                    onPressed: () async {
                      try {
                        if (accountController.text.length < 6) {
                          setState(() {
                            showErrorHint = pwdLengthErrorHint;
                          });
                        } else {
                          User user = await UserProvider.getUser(
                              inputAccount: accountController.text);
                          // Navigator.of(context).pushNamed('/safetyHintVerify',arguments: {'user': user});
                          if (!context.mounted) return;
                          navigateWithProvider(
                            context, 
                            '/safetyHintVerify', 
                            ref, 
                            arguments: {'user': user}
                          );

                        }
                      } catch (e) {
                        setState(() {
                          showErrorHint = noAccountErrorHint;
                        });
                        throw ("[Reset Pwd Account] Find user account exception: $e");
                      }
                    },
                    child: Text('下一步',
                        style: TextStyle(
                          fontSize: fontSize * 1.4,
                          color: beige,
                        )))
              ]),
        ),
      ),
    );
  }
}
