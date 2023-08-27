import 'package:flutter/material.dart';
import 'package:ltrc/data/providers/unit_provider.dart';
import 'package:ltrc/extensions.dart';

import '../contants/arabic_numerals_to_chinese.dart';
import '../data/models/unit_model.dart';

class UnitsView extends StatefulWidget {
  
  const UnitsView({super.key, required this.units});

  final List<Unit> units;

  @override
  _UnitsViewState createState() => _UnitsViewState();
}
class _UnitsViewState extends State<UnitsView> {
  @override
  void initState() {
    super.initState();
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void getTodoList() async {
      final list = await UnitProvider.getUnits(inputGrade:1, inputSemester:"上");
      debugPrint(list.toString());
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
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
                    return InkWell( 
                      onTap: (){
                        Navigator.of(context).pushNamed('/bopomos');
                      },
                      child: Container(
                        width: 297,
                        height: 80,
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
                    return InkWell( 
                      onTap: (){
                        Navigator.of(context).pushNamed('/words');
                      },
                      child: Container(
                        width: 140,
                        height: 140,
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
                              widget.units[index].unitTitle, 
                              style: TextStyle(
                                fontSize: 24,
                                color: "#F5F5DC".toColor(),
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: widget.units.length,
                ),
              ),
            )
          ],
        ),
    );
  }
}