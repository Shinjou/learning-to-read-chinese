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
      backgroundColor: '#1E1E1E'.toColor(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
          height: 300,
          width: deviceWidth,
          decoration: BoxDecoration(
            color: '#013E6D'.toColor(),
          ),
          child: Column(
            children: <Widget>[
              SizedBox(height: deviceHeight * 0.071),
              Text(
                  '年級',
                  style: TextStyle(
                      color: '#F5F5DC'.toColor(),
                      fontSize: 44,
                      fontFamily: 'Serif'
                  )
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 23.0),
                  child: Container(
                      height: 9,
                      width: 84,
                      color: '#F5F5DC'.toColor()
                  )
              ),
              Text(
                  '課本版本',
                  style: TextStyle(
                      color: '#F5F5DC'.toColor(),
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
            color: '#F8A23A'.toColor(),
            size: deviceWidth * 0.18,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.0, vertical: deviceHeight * 0.04),
            child: LeftRightSwitch(
                iconsColor: '#F5F5DC'.toColor(),
                iconsSize: deviceWidth * 0.15,
                middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: 224,
                  height: 57,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '#7DDEF8'.toColor()
                  ),
                  child: Text(
                    '一年級',
                    style: TextStyle(
                      color: '#000000'.toColor(),
                      fontSize: 34.0,
                      fontFamily: 'Serif'
                    )
                  )
                )
            )
          ),
          LeftRightSwitch(
              iconsColor: '#F5F5DC'.toColor(),
              iconsSize: deviceWidth * 0.15,
              middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: 224,
                  height: 57,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '#7DDEF8'.toColor()
                  ),
                  child: Text(
                      '翰林',
                      style: TextStyle(
                          color: '#000000'.toColor(),
                          fontSize: 34.0,
                          fontFamily: 'Serif'
                      )
                  )
              )
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(0, deviceHeight * 0.0687, 0, deviceHeight * 0.05),
            child: Container(
              alignment: AlignmentDirectional.center,
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: '#F8A23A'.toColor(),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right,
                color: '#1E1E1E'.toColor(),
                size: 80
              )
            ),
          )
        ],
      )
    );
  }
}