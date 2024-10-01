import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/providers.dart';
// import 'package:ltrc/views/view_utils.dart';

class Resource{
  final String resource;
  final String description;

  Resource({required this.resource, required this.description});
}

final List<Resource> resourceList = [
  Resource(
    resource: "各年級生字表",
    description: "由中研院語言學研究所李佳穎老師提供，用於所有功能。"
  ),
  Resource(
    resource: "注音字卡", 
    description: "由郭俊成老師提供，用於注音符號的學習。"
  ),
  Resource(
    resource: "字型演變",
    description: "來自中央研究院歷史語言學研究所與資訊科學研究所開發之「小學堂」字型演變資料庫。"
  ),
  Resource(
    resource: "筆順動畫",
    description: "來自文鼎科技開發股份有限公司授權之漢字及注音字型。更感謝他們的技術支持。"
  ),
  Resource(
    resource: "諮詢顧問",
    description: "鄭漢文校長與陳素慧老師擔任諮詢顧問，提供寶貴現場教學經驗。"
  ),
    Resource(
    resource: "注音符號錄音",
    description: "胡銘志老師幫忙錄製注音符號發音。"
  ),
  Resource(
    resource: "APP開發",
    description: "林羿成、蔡伊甯、李昊翰、方新舟合力開發此軟體。版權歸誠致教育基金會所有。"
  ),
  Resource(
    resource: "版權所有©2024誠致教育基金會", 
    description: ''
  )
];

class AcknowledgeView extends ConsumerWidget {
  const AcknowledgeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final screenInfo = ref.watch(screenInfoProvider);
    final screenInfo = ref.watch(screenInfoProvider);
    double fontSize = screenInfo.fontSize;
    bool isTablet = screenInfo.screenWidth > 600;
    if (isTablet && MediaQuery.of(context).orientation == Orientation.landscape) {
      fontSize *= 1.3;
    }
    
    int count = 0;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.5),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("授權與致謝",
              style: TextStyle(
                fontSize: fontSize * 1.0,
              )),
        ),
        body: CustomScrollView(slivers: [
          SliverPadding(
              padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("",           //"版權所有©2024誠致教育基金會" moved to the bottom
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: fontSize * 0.3, fontWeight: FontWeight.normal)),
                      ...resourceList.map((e) {
                        count++;
                        return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                            child: Text(
                                "$count. ${e.resource}\n ${e.description}",
                                style: TextStyle(fontSize: fontSize)));
                      // ignore: unnecessary_to_list_in_spreads
                      }).toList(),
                    ]),
              ))
        ]));
  }
}