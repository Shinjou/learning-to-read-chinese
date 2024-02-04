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
        leading: IconButton(icon: Icon(Icons.chevron_left, size: fontSize * 1.2), onPressed: () => Navigator.pop(context),),
        title: const Text("拼拼看"),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
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
              height: 60,
              width: 240,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: '#013E6D'.toColor(),
              ),
              child: Text(
                '⭐恭喜⭐\n完成所有題目！',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: "#F5F5DC".toColor(),
                )
              )
            ),
            const SizedBox(
              height: 30
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed("/bopomoQuiz"), 
              child: const Text(
                "重新測驗",
                style: TextStyle(color: Colors.black, fontSize: 16)
              )
            ),
            const SizedBox(
              height: 15
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed("/mainPage"), 
              child: const Text(
                "回首頁",
                style: TextStyle(color: Colors.black, fontSize: 16)  
              )
            )
          ],
        )
      )
    );
  }
}