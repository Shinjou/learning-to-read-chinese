import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/contants/arabic_numerals_to_chinese.dart';
import 'package:ltrc/contants/publisher_code.dart';
import 'package:ltrc/data/models/user_model.dart';
import 'package:ltrc/data/providers/user_provider.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  RegisterViewState createState() => RegisterViewState();
}

class RegisterViewState extends ConsumerState<RegisterView> {

  @override
  void initState() {
    super.initState();
    ref.read(gradeProvider);
    ref.read(publisherCodeProvider);
  }


  @override
  Widget build(BuildContext context) {

    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    final grade = ref.watch(gradeProvider);
    final publisherCode = ref.watch(publisherCodeProvider);
    final pwd = ref.watch(pwdProvider);
    final account = ref.watch(accountProvider);

    dynamic obj = ModalRoute.of(context)!.settings.arguments;

    return Scaffold(
      backgroundColor: '#1E1E1E'.toColor(),
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
                onLeftClicked: () => {ref.read(gradeProvider.notifier).state = (ref.read(gradeProvider.notifier).state-2) % 6 + 1},
                onRightClicked: () => {ref.read(gradeProvider.notifier).state = (ref.read(gradeProvider.notifier).state) % 6 + 1},
                middleWidget: Container(
                  alignment: AlignmentDirectional.center,
                  width: deviceWidth * 0.57,
                  height: deviceHeight * 0.067,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.circular(20),
                      color: '7DDEF8'.toColor()
                  ),
                  child: Text(
                    '${numeralToChinese[grade]}年級',
                    style: TextStyle(
                      color: '000000'.toColor(),
                      fontSize: 34.0,
                    )
                  )
                )
              )
            ),
            LeftRightSwitch(
              iconsColor: 'F5F5DC'.toColor(),
              iconsSize: deviceWidth * 0.15,
              onLeftClicked: () => {ref.read(publisherCodeProvider.notifier).state = (ref.read(publisherCodeProvider.notifier).state-1) % 3},
              onRightClicked: () => {ref.read(publisherCodeProvider.notifier).state = (ref.read(publisherCodeProvider.notifier).state+1) % 3},
              middleWidget: Container(
                alignment: AlignmentDirectional.center,
                width: deviceWidth * 0.57,
                height: deviceHeight * 0.067,
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(20),
                  color: '7DDEF8'.toColor()
                ),
                child: Text(
                  publisherCodeTable[publisherCode]!,
                  style: TextStyle(
                    color: '000000'.toColor(),
                    fontSize: 34.0,
                  )
                )
              )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(0, deviceHeight * 0.0687, 0, deviceHeight * 0.05),
              child: Container(
                alignment: AlignmentDirectional.center,
                width: deviceHeight * 0.095,
                height: deviceHeight * 0.095,
                decoration: BoxDecoration(
                  color: '#F8A23A'.toColor(),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  color: '#1E1E1E'.toColor(),
                  iconSize: deviceHeight * 0.09,
                  onPressed: () async {
                    try{
                      await UserProvider.addUser(
                        user: User(
                          account: account,
                          password: pwd,
                          safetyQuestionId1: obj['q1'],
                          safetyAnswer1: obj['a1'] as String,
                          safetyQuestionId2: obj['q2'],
                          safetyAnswer2: obj['a2'] as String,
                          grade: grade,
                          publisher: publisherCodeTable[publisherCode]!,
                        ), 
                      );
                    } catch(e){
                      throw("create user error: $e");
                    }
                    Navigator.of(context).pushNamed('/mainPage');
                  },
                )
              ),
            )
          ],
        ),
      ),
    );
  }
}