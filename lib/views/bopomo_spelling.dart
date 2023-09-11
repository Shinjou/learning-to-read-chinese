import 'package:flutter/material.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/bopomo/bopomo_container.dart';


class BopomoSpellingView extends StatefulWidget {
  const BopomoSpellingView({super.key});

  @override
  State<BopomoSpellingView> createState() => _BopomoSpellingState();
}

class _BopomoSpellingState extends State<BopomoSpellingView>{ 
  final vowels = List.from(prenuclear)..addAll(finals);
  late String caughtTone;
  late String caughtInitial;
  late String caughtPrenuclear;
  late String caughtFinal;

  @override
  void initState() {
    super.initState();
    caughtFinal = "";
    caughtInitial = "";
    caughtPrenuclear = "";
    caughtTone = "";
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
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
                  return (tones[index] == caughtTone) ? 
                    BopomoContainer(
                      character: tones[index], 
                      color: "#404040".toColor(),
                      onPressed: () => setState(() {
                        caughtTone = '';
                      }),
                    ) : 
                    BopomoContainer(
                      character: tones[index], 
                      color: "#01316D".toColor(),
                      onPressed: () => setState(() {
                        caughtTone = tones[index];
                      }),
                    );
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
                  return initials[index] == caughtInitial ?
                  BopomoContainer(
                    character: initials[index], 
                    color: "#404040".toColor(),
                    onPressed: () => setState(() {
                      caughtInitial = '';
                    }),  
                  ) :
                  BopomoContainer(
                    character: initials[index], 
                    color: "#48742C".toColor(),
                    onPressed: () => setState(() {
                      caughtInitial = initials[index];
                    }),  
                  );
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
                    mainAxisSize: MainAxisSize.max,
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
                                    BopomoContainer( 
                                      character : (caughtInitial.isNotEmpty && caughtTone == "˙") ? null :
                                        (caughtTone == "˙") ? "˙" : caughtInitial,
                                      innerWidget: (caughtInitial.isNotEmpty && caughtTone == "˙") ? Column(
                                        children: [
                                          const Text(
                                            "˙",
                                            style: TextStyle(
                                              fontSize: 16
                                            ),
                                          ),
                                          Text(
                                            caughtInitial,
                                            style: const TextStyle(
                                              fontSize: 16
                                            ),
                                          )
                                        ],
                                      ) : null,
                                      color : "#48742C".toColor(),
                                      onPressed: () => setState(() {
                                        caughtInitial = '';
                                        if (caughtTone == '˙'){
                                          caughtTone = '';
                                        }
                                      }),
                                    ),
                                    BopomoContainer( 
                                      character: (caughtPrenuclear.isNotEmpty && caughtFinal.isNotEmpty) ? null :
                                        (caughtPrenuclear.isNotEmpty) ? caughtPrenuclear : caughtFinal, 
                                      innerWidget: (caughtPrenuclear.isNotEmpty && caughtFinal.isNotEmpty) ? Column(
                                        children: [
                                          Text(
                                            caughtPrenuclear,
                                            style: const TextStyle(
                                              fontSize: 16
                                            ),
                                          ),
                                          Text(
                                            caughtFinal,
                                            style: const TextStyle(
                                              fontSize: 16
                                            ),
                                          )
                                        ],
                                      ) : null,
                                      color : "#D19131".toColor(),
                                      onPressed: () => setState(() {
                                        caughtFinal = '';
                                        caughtPrenuclear = '';
                                      }),
                                    ),
                                  ],
                                ),
                                BopomoContainer( 
                                  character : caughtTone == "˙" ? "" : caughtTone, 
                                  color : "#01316D".toColor(),
                                  onPressed: () => setState(() {
                                    caughtTone = '';
                                  }),
                                ),
                              ]
                            ),
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.replay,
                              color: "#F5F5DC".toColor(),
                            ),
                            onPressed: (){
                              setState(() {
                                caughtFinal = "";
                                caughtInitial = "";
                                caughtPrenuclear = "";
                                caughtTone = "";
                              });
                            },
                          ),
                          const Text('清除'),
                          IconButton(
                            icon: Icon(
                              Icons.done_outline,
                              color: "#F5F5DC".toColor(),
                            ), 
                            onPressed: (){},),
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
                  if (index < 3){
                    return prenuclear[index] == caughtPrenuclear?
                      BopomoContainer(
                        character: prenuclear[index], 
                        color: "#404040".toColor(),
                        onPressed: () => setState(() {
                          caughtPrenuclear = '';
                        }),  
                      ):
                      BopomoContainer(
                        character: prenuclear[index], 
                        color: "#D19131".toColor(),
                        onPressed: () => setState(() {
                          caughtPrenuclear = prenuclear[index];
                        }),
                      );
                  }
                  else {
                    return finals[index-3] == caughtFinal?
                      BopomoContainer(
                        character: finals[index-3], 
                        color: "#404040".toColor(),
                        onPressed: () => setState(() {
                          caughtFinal = '';
                        }),  
                      ):
                      BopomoContainer(
                        character: finals[index-3], 
                        color: "#D19131".toColor(),
                        onPressed: () => setState(() {
                          caughtFinal = finals[index-3];
                        }),  
                      );
                  }
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