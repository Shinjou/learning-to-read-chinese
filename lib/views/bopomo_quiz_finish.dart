import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/views/view_utils.dart';

class BopomoQuizFinishView extends StatelessWidget {
  const BopomoQuizFinishView({super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize = getFontSize(context, 16); // 16 is the base font size for 360dp width

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "拼拼看",
            style: TextStyle(fontSize: fontSize * 1.0),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: fontSize * 1.5,
              ),
              onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
            )
          ],
        ),
        body: Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    height: fontSize * 3.5,
                    width: fontSize * 14.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: '#013E6D'.toColor(),
                    ),
                    child: Text('⭐恭喜⭐\n完成所有題目！',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: "#F5F5DC".toColor(),
                        ))),
                SizedBox(
                  height: fontSize * 0.3,
                ),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed("/bopomoQuiz"),
                    child: Text("重新測驗",
                        style: TextStyle(
                            color: Colors.black, fontSize: fontSize))),
                SizedBox(
                  height: fontSize * 0.3,
                ),
                ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed("/mainPage"),
                    child: Text("回首頁",
                        style:
                            TextStyle(color: Colors.black, fontSize: fontSize)))
              ],
            )));
  }
}
