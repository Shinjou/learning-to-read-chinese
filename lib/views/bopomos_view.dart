import 'package:flutter/material.dart';
import 'package:ltrc/contants/bopomos.dart';
import 'package:ltrc/extensions.dart';
import '../widgets/wordWithImage.dart';

class BopomosView extends StatelessWidget {
  BopomosView({super.key});
  final List<String> bopomos = List.from(initials)..addAll(prenuclear)..addAll(finals);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => {},),
        title: const Text("00|學注音"),
        actions: [
          IconButton(icon: const Icon(Icons.home), onPressed: ()=>{},)
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 125.0,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 113/166,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return WordWithImage(word : bopomos[index]);
                },
                childCount: bopomos.length,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(46, 16, 46, 16),
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
                        color: "#F5F5DC".toColor(),
                      ),
                      child: Text(
                        "拼拼看", 
                        style: TextStyle(
                          fontSize: 32,
                          color: "#28231D".toColor(),
                        ), 
                        textAlign: TextAlign.center,),
                    ),
                  );
                },
                childCount: 1,
              )
            ),
          ),
        ],
      )
    );
  }
}