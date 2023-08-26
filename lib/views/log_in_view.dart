import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    return  Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: '#1E1E1E'.toColor(),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.157),
              Text(
                  '學中文',
                  style: TextStyle(

                    color: '#F5F5DC'.toColor(),
                    fontSize: 46.0,
                    fontFamily: 'Serif',
                  )
              ),
              SizedBox(height: deviceHeight * 0.162),
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
                    child: TextField(
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
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          enabledBorder: InputBorder.none,
                        )
                    ),
                  )
              ),
              SizedBox(height: deviceHeight * 0.073),
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
                    child: TextField(
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
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          enabledBorder: InputBorder.none,
                        )
                    ),
                  )
              ),
              Center(
                child: Container(
                  height: 50.0,
                  width: 303.0,
                  child: Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        fixedSize: const Size(110, 14),
                      ),
                      child: Text(
                          '忘記密碼',
                          style: TextStyle(
                            color: '#F5F5DC'.toColor(),
                            fontSize: 14.0,
                            fontFamily: 'Serif',
                          )
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: deviceHeight * 0.0379),
              Center(
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              fixedSize: const Size(110, 45),
                            ),
                            child: Text(
                                '登入',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontFamily: 'Serif',
                                  color: '#F5F5DC'.toColor(),
                                )
                            )
                        ),
                        Text(
                            '/',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'Serif',
                              color: '#F5F5DC'.toColor(),
                            )
                        ),
                        TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              fixedSize: const Size(110, 45),
                            ),
                            child: Text(
                                '註冊',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontFamily: 'Serif',
                                  color: '#F5F5DC'.toColor(),
                                )
                            )
                        )
                      ])
              ),
            ]
        )
    );
  }
}