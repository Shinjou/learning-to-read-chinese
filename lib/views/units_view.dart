import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

import '../contants/ArabicNumeralsToChinese.dart';

class UnitsView extends StatelessWidget {
  const UnitsView({super.key});

  @override
  Widget build(BuildContext context) {
    const units = ["手拉手", "排一排", "來數數", "找一找", "雨來了",
      "山坡上的學校", "值日生", "運動會", "做卡片"];
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => {},),
        title: const Text("課程單元"),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: ()=>{},)
        ],
      ),

      body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(46, 20, 46, 14),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int idx){
                    return SizedBox(
                      width: 297,
                      height: 80,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                          color: "#013E6D".toColor(),
                        ),
                        child: Text(
                          "學注音", 
                          style: TextStyle(
                            fontSize: 32,
                            color: "#F5F5DC".toColor(),
                          ), 
                          textAlign: TextAlign.center,),
                      ),
                    );
                  },
                  childCount: 1,
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(46, 14, 46, 20),
                sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180.0,
                  mainAxisSpacing: 13.0,
                  crossAxisSpacing: 13.0,
                  childAspectRatio: 1.05,
                ),
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    String? classNum = numeralToChinese[index+1];
                    return SizedBox(
                      width: 140,
                      height: 140,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.all(Radius.circular(14)),
                          color: "#013E6D".toColor(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "第$classNum課", 
                              style: TextStyle(
                                fontSize: 16,
                                color: "#F5F5DC".toColor(),
                              )
                            ),
                            Text(
                              units[index], 
                              style: TextStyle(
                                fontSize: 24,
                                color: "#F5F5DC".toColor(),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: units.length,
                ),
              ),
            )
          ],
        ),
    );
  }
}