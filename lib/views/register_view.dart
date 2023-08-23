import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late int _grade;
  late String _publisher;

  @override
  void initState() {
    super.initState();
    _loadGradeAndPublisher();
  }

  void _loadGradeAndPublisher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _grade = prefs.getInt('grade') ?? 1;
      _publisher = prefs.getString('publisher') ?? "HanLin";
    });
  }

  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: '1E1E1E'.toColor(),
      body: SizedBox.expand(
        child: Column(
          children: <Widget>[
            Container(
            height: deviceHeight * 0.33,
            width: deviceWidth,
            decoration: BoxDecoration(
              color: '013E6D'.toColor(),
            ),
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                SizedBox(height: deviceHeight * 0.06),
                Text(
                    '年級',
                    style: TextStyle(
                        color: 'F5F5DC'.toColor(),
                        fontSize: 44,
                        fontFamily: 'Serif'
                    )
                ),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: deviceHeight * 0.027),
                    child: Container(
                        height: 9,
                        width: 84,
                        color: 'F5F5DC'.toColor()
                    )
                ),
                Text(
                    '課本版本',
                    style: TextStyle(
                        color: 'F5F5DC'.toColor(),
                        fontSize: 44,
                        fontFamily: 'Serif'
                    )
                )
              ],
              )
            ),
            SizedBox(height: deviceHeight * 0.057),
            Icon(
              Icons.home_filled,
              color: 'F8A23A'.toColor(),
              size: deviceHeight * 0.083,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: deviceHeight * 0.04),
              child: LeftRightSwitch(
                  iconsColor: 'F5F5DC'.toColor(),
                  iconsSize: deviceWidth * 0.15,
                  middleWidget: Container(
                    alignment: AlignmentDirectional.center,
                    width: deviceWidth * 0.57,
                    height: deviceHeight * 0.067,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(20),
                        color: '7DDEF8'.toColor()
                    ),
                    child: Text(
                      '一年級',
                      style: TextStyle(
                        color: '000000'.toColor(),
                        fontSize: 34.0,
                        fontFamily: 'Serif'
                      )
                    )
                  )
              )
            ),
            LeftRightSwitch(
                iconsColor: 'F5F5DC'.toColor(),
                iconsSize: deviceWidth * 0.15,
                middleWidget: Container(
                    alignment: AlignmentDirectional.center,
                    width: deviceWidth * 0.57,
                    height: deviceHeight * 0.067,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.circular(20),
                        color: '7DDEF8'.toColor()
                    ),
                    child: Text(
                        '翰林',
                        style: TextStyle(
                            color: '000000'.toColor(),
                            fontSize: 34.0,
                            fontFamily: 'Serif'
                        )
                    )
                )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, deviceHeight * 0.02, 0, deviceHeight * 0.05),
              child: Container(
                alignment: AlignmentDirectional.center,
                width: deviceHeight * 0.095,
                height: deviceHeight * 0.095,
                decoration: BoxDecoration(
                  color: 'F8A23A'.toColor(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.chevron_right,
                  color: '1E1E1E'.toColor(),
                  size: deviceHeight * 0.09
                )
              ),
            )
          ],
        ),
      )
    );
  }
}