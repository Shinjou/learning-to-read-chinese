import 'package:flutter/material.dart';
import 'package:ltrc/views/view_utils.dart';

class Resource {
  final String resource;
  final String description;

  Resource({required this.resource, required this.description});
}

final List<Resource> resourceList = [
  Resource(resource: "各年級生字表", description: "由中研院語言學研究所李佳穎老師提供，用於所有功能。"),
  Resource(
      resource: "注音字卡",
      description: "由郭俊成老師提供,來自fb粉絲專頁「麻辣飛天郭」,用於注音「看一看」、「用一用」及「拼拼看」。"),
  Resource(
      resource: "字型演變", description: "來自中央研究院歷史語言學研究所與資訊科學研究所開發之「小學堂」字型演變資料庫。"),
  Resource(resource: "筆順動畫", description: "來自文鼎科技開發股份有限公司提供之開源漢字、注音筆順素材與技術支持。"),
  Resource(resource: "諮詢顧問", description: "鄭漢文校長與陳素慧老師擔任諮詢顧問，分享現場教師觀點。"),
  Resource(
      resource: "APP開發", description: "林羿成、蔡伊甯、王藝錡、李昊翰合力開發此軟體，版權歸誠致教育基金會所有。")
];

class AcknowledgeView extends StatelessWidget {
  const AcknowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    double fontSize =
        getFontSize(context, 16); // 16 is the base font size for 360dp width

    int count = 0;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: fontSize * 1.0),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text("致謝",
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
                      Text("圖片資源來源：",
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: fontSize, fontWeight: FontWeight.bold)),
                      ...resourceList.map((e) {
                        count++;
                        return Padding(
                            padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                            child: Text(
                                "$count. ${e.resource}\n ${e.description}",
                                style: TextStyle(fontSize: fontSize)));
                      }).toList()
                    ]),
              ))
        ]));
  }
}
