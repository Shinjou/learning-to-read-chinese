import 'package:flutter/material.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/bopomo/bopomo_block.dart';
import '../widgets/bopomo/bopomo_container.dart';


class BopomoSpellingView extends StatelessWidget {
  BopomoSpellingView({super.key});
  final vowels = List.from(prenuclear)..addAll(finals);

  @override
  Widget build(BuildContext context) {
    String caughtInitial ='';
    String caughtFinal ='';
    String caughtTone ='';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
        title: const Text("00|學注音"),
        actions: [
          IconButton(icon: const Icon(Icons.home), onPressed: ()=>{},)
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(87, 5, 87, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 50,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 39/52,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return BopomoBlock(character: tones[index], color: "#01316D".toColor(),);
                },
                childCount: tones.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(31, 5, 31, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 39,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 39/55,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return BopomoBlock(character: initials[index], color: "#48742C".toColor(),);
                },
                childCount: initials.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(92, 8, 92, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 260,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 210/140,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return Row(
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Container(
                            decoration: BoxDecoration(
                              color: '023E6E'.toColor(),
                              border: Border.all(
                                width: 5,
                                color: '#F5F5DC'.toColor(),
                              ),
                            ),
                            child: Row (
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    DragTarget<String>(
                                      onAccept: (data) => {caughtInitial = data},
                                      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                                        return BopomoContainer( 
                                          character : accepted.isEmpty ? caughtInitial : ' ', 
                                          color : "#48742C".toColor()
                                        );
                                      },
                                      onWillAccept: (data) => initials.contains(data),
                                    ),
                                    DragTarget<String>(
                                      onAccept: (data) => {caughtFinal = data},
                                      builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                                        return BopomoContainer( 
                                          character : accepted.isEmpty ? caughtFinal : ' ', 
                                          color : "#404040".toColor()
                                        );
                                      },
                                      onWillAccept: (data) => (List.from(prenuclear)..addAll(vowels)).contains(data),
                                    ),
                                  ],
                                ),
                                DragTarget<String>(
                                  onAccept: (data) => {caughtTone = data},
                                  builder: (BuildContext context, List<dynamic> accepted, List<dynamic> rejected) {
                                    return BopomoContainer( 
                                          character : accepted.isEmpty ? caughtTone : ' ', 
                                          color : "#01316D".toColor()
                                        );
                                  },
                                  onWillAccept: (data) => tones.contains(data),
                                ),
                              ]
                            ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(icon: const Icon(Icons.replay), onPressed: (){},),
                          const Text('清除'),
                          IconButton(icon: const Icon(Icons.done_outline), onPressed: (){},),
                          const Text('確認'),
                        ],
                      ),
                    ],
                  );
                },
                childCount: 1,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(31, 5, 31, 5),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 39,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 39/55,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return BopomoBlock(character: vowels[index], color: "#404040".toColor(),);
                },
                childCount: vowels.length,
              ),
            ),
          ),
        ],
      )
    );
  }
}