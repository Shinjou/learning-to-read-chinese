import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/progressBar.dart';

class MainPageView extends StatelessWidget {
  const MainPageView({super.key});

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: '#28231D'.toColor(),
      body: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 63,
              width: deviceWidth,
              padding: EdgeInsetsDirectional.fromSTEB(0, deviceHeight * 0.05, deviceWidth * 0.04, 0),
              alignment: AlignmentDirectional.centerEnd,
              child: Icon(
                Icons.settings,
                color: '#F5F5DC'.toColor(),
                size: 38
              ),
            ),
            Container(
              height: 54,
              width: 210,
              margin: EdgeInsetsDirectional.fromSTEB(0, deviceHeight * 0.0825, 0, deviceHeight * 0.193),
              child: Text(
                '學中文',
                style: TextStyle(
                  color: '#F5F5DC'.toColor(),
                  fontSize: 46,
                  fontFamily: 'Serif'
                )
              )
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(bottom: deviceHeight * 0.27),
              child: SizedBox(
                width: deviceWidth * 0.76,
                height: deviceHeight * 0.095,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all('#013E6D'.toColor()),
                    elevation: MaterialStateProperty.all(25),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      )
                    ),
                  ),
                  child: Text(
                    '學生字',
                    style: TextStyle(
                      color: '#F5F5DC'.toColor(),
                      fontSize: 32,
                      fontFamily: 'Serif'
                    )
                  )
                ),
              )
            ),
            Text(
                '收集生字卡',
                style: TextStyle(
                    color: '#F5F5DC'.toColor(),
                    fontSize: 22,
                    fontFamily: 'Serif'
                )
            ),
            ProgressBar(value: 0.0)
          ]
        ),
      )
    );
  }
}