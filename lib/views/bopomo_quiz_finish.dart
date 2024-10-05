import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:ltrc/extensions.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/providers.dart';
import 'package:ltrc/views/view_utils.dart';


class BopomoQuizFinishView extends ConsumerWidget {
  const BopomoQuizFinishView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;

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
              // onPressed: () => Navigator.of(context).pushNamed('/mainPage'),
              onPressed: () => navigateWithProvider(context, '/mainPage', ref)
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
                    decoration: const BoxDecoration(
                      color: deepBlue,
                    ),
                    child: Text('⭐恭喜⭐\n完成所有題目！',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: beige,
                        ))),
                SizedBox(
                  height: fontSize * 0.3,
                ),
                ElevatedButton(
                    onPressed: () =>
                        // Navigator.of(context).pushNamed("/bopomoQuiz"),
                        navigateWithProvider(context, '/bopomoQuiz', ref),
                    child: Text("重新測驗",
                        style: TextStyle(
                            color: Colors.black, fontSize: fontSize))),
                SizedBox(
                  height: fontSize * 0.3,
                ),
                ElevatedButton(
                    onPressed: () =>
                        // Navigator.of(context).pushNamed("/mainPage"),
                        navigateWithProvider(context, '/mainPage', ref),
                    child: Text("回首頁",
                        style:
                            TextStyle(color: Colors.black, fontSize: fontSize)))
              ],
            )));
  }
}
