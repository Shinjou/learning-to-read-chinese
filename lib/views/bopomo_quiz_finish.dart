import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class BopomoQuizFinishView extends ConsumerWidget {
  const BopomoQuizFinishView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;
    debugPrint("BopomoQuizFinishView fontSize: $fontSize");

    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            "拼拼看",
            style: TextStyle(fontSize: fontSize * 1.5),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.home,
                size: fontSize * 1.5,
              ),
              onPressed: () {
                if (context.mounted) {
                  navigateWithProvider(context, '/mainPage', ref);
                }
              },
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
                    height: fontSize * 5.0,
                    width: fontSize * 20.0,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: deepBlue,
                    ),
                    child: Text('⭐恭喜⭐\n完成所有題目！',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize * 1.5,
                          color: beige,
                        ))),
                SizedBox(
                  height: fontSize * 0.5,
                ),
                ElevatedButton(
                    onPressed: () {
                      if (context.mounted) {
                        navigateWithProvider(context, '/bopomoQuiz', ref);
                      }
                    },                        
                    child: Text("重新測驗",
                        style: TextStyle(
                            color: Colors.black, fontSize: fontSize * 1.5))),
                SizedBox(
                  height: fontSize * 0.5,
                ),
                ElevatedButton(
                    onPressed:() {
                      if (context.mounted) {
                        navigateWithProvider(context, '/mainPage', ref);
                      }
                    },                        
                    child: Text("回首頁",
                        style:
                            TextStyle(color: Colors.black, fontSize: fontSize * 1.5)))
              ],
            )));
  }
}
