import 'package:flutter/material.dart';

class Resource{
  final String resource;
  final String description;

  Resource({required this.resource, required this.description});
}

final List<Resource> resourceList = [
  Resource(
    resource: "注音字卡", 
    description: "由郭俊成老師提供,來自fb粉絲專頁「麻辣飛天郭」。"
  ),
  Resource(
    resource: "字型演變",
    description: "來自中央研究院開發之「小學堂」字型演變資料庫。"
  )
];

class AcknowledgeView extends StatelessWidget {
  const AcknowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => Navigator.pop(context),),
        title: const Text("致謝"),
      ),
      body: CustomScrollView(
        slivers: [
            SliverPadding(
            padding: const EdgeInsets.fromLTRB(23, 14, 23, 20),
            sliver: SliverToBoxAdapter( 
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "圖片資源來源：",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold
                    )
                  ),
                  ...resourceList.map((e){
                    count ++;
                    return Padding( 
                      padding: const EdgeInsets.fromLTRB(0, 7, 0, 7),
                      child:Text(
                        "$count. ${e.resource}\n ${e.description}",
                        style: const TextStyle(
                          fontSize: 16
                        )
                      )
                    );
                  }).toList()
                ]
              ),
            )
          )
        ]
      )
    );
  }
}