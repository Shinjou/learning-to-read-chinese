import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/widgets/grade_and_provider_button.dart';
import 'package:flutter/cupertino.dart';

class SettingView extends ConsumerStatefulWidget {
  const SettingView({super.key});

  @override
  SettingViewState createState() => SettingViewState();
}

class SettingViewState extends ConsumerState<SettingView> {
  late TextEditingController controller;
  late String userName;
  late String account;

  @override 
  void initState() {
    super.initState();
    controller = TextEditingController();
    userName = "";
    account = "";
  }

  @override
  void dispose(){
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    setState(() {
      userName = ref.watch(userNameProvider);
      account = ref.watch(accountProvider);
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: '#1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Stack(
          children: <Widget>[
            Container(
              height: deviceHeight * 0.3673,
              width: deviceWidth,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )
              )
            ),
            SafeArea(
              child: Container(
                padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
                alignment: AlignmentDirectional.topEnd,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: '#F5F5DC'.toColor(),
                    size: 40,
                    shadows: const [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4.5))],
                  ),
                  onPressed: () => Navigator.pop(context),
                )
              )
            ),
            Container(
              padding: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.138, deviceHeight * 0.064, 0, 0),
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.settings,
                    color: '#F5F5DC'.toColor(),
                    size: 36
                  ),
                  Container(
                    padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                    child: const Text(
                      '設定',
                      style: TextStyle(
                        fontSize: 36,
                      )
                    )
                  )
                ]
              )
            ),
            Positioned(
              top: deviceHeight * 0.156,
              left: deviceWidth * 0.058,
              child: Container(
                height: deviceHeight * 0.8,
                width: deviceWidth * 0.882,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: '#F5F5DC'.toColor(),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 50,
                      width: deviceWidth * 0.85,
                      margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.0513, deviceHeight * 0.032, 0, deviceHeight * 0.024),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_circle,
                            color: '#1C1B1F'.toColor(),
                            size: 48
                          ),
                          Container( width: 15 ),
                          Text(
                            userName,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                            )
                          ),
                          Container( width: 30 ),
                          InkWell(
                            onTap: (){
                              showDialog(
                                context: context, 
                                builder: (context) => AlertDialog(
                                  backgroundColor: "#F5F5DC".toColor(),
                                  title: const Text("編輯名稱"),
                                  content: const TextField(
                                    decoration: InputDecoration(
                                      hintText: "請輸入你的名稱"
                                    ),

                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        setState(() {
                                          userName = controller.text;
                                        });
                                        User userToUpdate = await UserProvider.getUser(inputAccount: account);
                                        userToUpdate.username = userName;
                                        await UserProvider.updateUser(user: userToUpdate);
                                      },
                                      child: const Text('確認')
                                    )
                                  ],
                                )
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.mode,
                                  color: "#999999".toColor(),
                                ),
                                Text(
                                  "編輯",
                                  style: TextStyle(
                                    color: "#999999".toColor(),
                                  ),
                                )
                              ],
                            )
                          )
                        ]
                      ),
                    ),
                    Divider(
                      color: '#999999'.toColor(),
                      indent: 12,
                      endIndent: 12,
                      height: 4,
                    ),
                    Container(
                      height: 30,
                      width: deviceWidth * 0.882,
                      margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.064, 0, 0, 5),
                      child: const Text(
                        '年級',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black
                        )
                      )
                    ),
                    SizedBox(
                      height: deviceHeight * 0.035,
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '一'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '二'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '三')
                        ]
                      )
                    ),
                    Container(
                      height: deviceHeight * 0.035,
                      width: deviceWidth * 0.8,
                      margin: EdgeInsetsDirectional.only(top: deviceHeight * 0.027),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '四'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '五'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '六')
                        ]
                      )
                    ),
                    Divider(
                      color: '#999999'.toColor(),
                      indent: 12,
                      endIndent: 12,
                      height: 4,
                    ),
                    Container(
                      height: 30,
                      width: deviceWidth * 0.882,
                      margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.064, deviceHeight * 0.039, 0, 5),
                      child: const Text(
                        '課本版本',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black
                        )
                      )
                    ),
                    SizedBox(
                      height: deviceHeight * 0.035,
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '康軒'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '翰林'),
                          GradeAndProviderButton(buttonWidth: deviceWidth * 0.25, buttonHeight: deviceHeight * 0.035, text: '南一')
                        ]
                      )
                    ),
                    Divider(
                      color: '#999999'.toColor(),
                      indent: 12,
                      endIndent: 12,
                      height: 4,
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 0, vertical: deviceHeight * 0.04),
                      child: SizedBox(
                        height: 30,
                        width: deviceWidth * 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            const Text(
                              '聲音',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                              )
                            ),
                            CupertinoSwitch(
                              onChanged: (bool? value){
                                ref.read(soundOnProvider.notifier).state = !ref.read(soundOnProvider.notifier).state;
                              },
                              value: ref.watch(soundOnProvider),
                              activeColor: CupertinoColors.black,
                            )
                          ]
                        )
                      )
                    ),
                    Divider(
                      color: '#999999'.toColor(),
                      indent: 12,
                      endIndent: 12,
                      height: 4,
                    ),
                    SizedBox(
                      height: 26,
                      width: deviceWidth * 0.8,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          const Text(
                            '資源出處',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                            )
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).pushNamed('/acknowledge'),
                            icon: const Icon(Icons.arrow_forward_ios),
                            color: Colors.black,
                            iconSize: 25
                          )
                        ]
                      )
                    ),
                    SizedBox(
                      height: deviceHeight * 0.09,
                      width: deviceWidth * 0.882,
                    ),
                    Expanded(
                      child:TextButton(
                        onPressed: (){
                          Navigator.of(context).pushNamed('/login');
                          ref.read(accountProvider.notifier).state = "";
                          ref.read(userNameProvider.notifier).state = "";  
                        },
                        style: TextButton.styleFrom(
                          fixedSize: const Size.fromHeight(30),
                        ),
                        child: const Text(
                          '登出',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                          )
                        ),
                      )
                    )
                  ]
                )
              )
            ),
          ]
        ),
      ),
    );
  }
}

