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
    return  Scaffold(
        backgroundColor: '#1E1E1E'.toColor(),
        // works
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 133),
              Text(
                  '學中文',
                  style: TextStyle(
                    color: 'F5F5DC'.toColor(),
                    fontSize: 46.0,
                    fontFamily: 'BpmfZihiSerif',
                  )
              ),
              const SizedBox(height: 137),
              Container(
                  height: 60.0,
                  width: 303.0,
                  decoration: BoxDecoration(
                      color: '7DDEF8'.toColor(),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(width: 5.0, color: 'F5F5DC'.toColor())
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 6.0),
                    child: TextField(
                      //maxLength: 6,
                        decoration: InputDecoration(
                          icon: Icon(
                            Icons.account_circle,
                            size: 30.0,
                            color: '1C1B1F'.toColor(),
                          ),
                          labelText: '帳號名稱',
                          labelStyle: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'BpmfZihiSerif',
                              color: '013E6D'.toColor()
                          ),
                          floatingLabelBehavior: FloatingLabelBehavior.always,
                          floatingLabelAlignment: FloatingLabelAlignment.center,
                          enabledBorder: InputBorder.none,
                        )
                    ),
                  )
              ),
              const SizedBox(height: 65),
              SizedBox(
                  height: 60.0,
                  width: 303.0,
                  child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.lock,
                        color: '1C1B1F'.toColor(),

                      ),
                      label: Text(
                          '密碼',
                          style: TextStyle(
                              fontSize: 20.0,
                              fontFamily: 'BpmfZihiSerif',
                              color: '013E6D'.toColor()
                          )
                      ),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: '7DDEF8'.toColor(),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)
                          )
                      )
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
                            color: 'F5F5DC'.toColor(),
                            fontSize: 14.0,
                            fontFamily: 'BpmfZihiSerif',
                          )
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 32,
              ),
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
                                  fontFamily: 'BpmfZihiSerif',
                                  color: 'F5F5DC'.toColor(),
                                )
                            )
                        ),
                        Text(
                            '/',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'BpmfZihiSerif',
                              color: 'F5F5DC'.toColor(),
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
                                  fontFamily: 'BpmfZihiSerif',
                                  color: 'F5F5DC'.toColor(),
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