import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ltrc/extensions.dart';

class SettingView extends StatefulWidget {
  const SettingView({super.key});

  @override
  State<SettingView> createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: '1E1E1E'.toColor(),
      body: Stack(
        children: <Widget>[
          Container(
            height: deviceHeight * 0.3673,
            width: deviceWidth,
            decoration: BoxDecoration(
              color: '013E6D'.toColor(),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              )
            )
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 10),
              alignment: AlignmentDirectional.topEnd,
              child: Icon(
                Icons.close,
                color: 'F5F5DC'.toColor(),
                size: 40,
                shadows: const [Shadow(color: Colors.black, blurRadius: 10, offset: Offset(0, 4.5))],
              )
            )
          ),
          Container(
            padding: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.138, deviceHeight * 0.064, 0, 0),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.settings,
                  color: 'F5F5DC'.toColor(),
                  size: 36
                ),
                Container(
                  padding: EdgeInsetsDirectional.fromSTEB(20, 0, 0, 0),
                  child: Text(
                    '設定',
                    style: TextStyle(
                      color: 'F5F5DC'.toColor(),
                      fontSize: 36,
                      fontFamily: 'Serif'
                    )
                  )
                )
              ]
            )
          ),
          Positioned(
            top: deviceHeight * 0.156,
            left: deviceWidth * 0.059,
            child: Container(
              height: deviceHeight * 0.844,
              width: deviceWidth * 0.882,
              decoration: BoxDecoration(
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(16),
                  topStart: Radius.circular(16)
                ),
                color: 'F5F5DC'.toColor(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 55,
                    width: 165,
                    margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.0513, deviceHeight * 0.032, 0, deviceHeight * 0.034),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                              Icons.account_circle,
                              color: '1C1B1F'.toColor(),
                              size: 49
                          ),
                          Text(
                            'A12345',
                            style: TextStyle(
                              color: '000000'.toColor(),
                              fontSize: 28,
                              fontFamily: 'Serif'
                            )
                          )
                        ]
                    ),
                  ),
                  Container(
                    height: 30,
                    width: 80,
                    margin: EdgeInsetsDirectional.fromSTEB(deviceWidth * 0.064, 0, 0, 5),
                    child: Text(
                      '年級',
                      style: TextStyle(
                        fontSize: 24,
                        fontFamily: 'Serif',
                        color: '000000'.toColor()
                      )
                    )
                  ),
                  //年級按鍵
                  //課本版本
                  //課本版本按鍵
                  //聲音 ＋ switch鍵
                ]
              )
            )
          ),
        ]
      )
    );
  }
}
