import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';

class TeachWordView extends StatefulWidget {
  const TeachWordView({super.key});

  @override
  State<TeachWordView> createState() => _TeachWordViewState();
}

class _TeachWordViewState extends State<TeachWordView> 
  with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState(){
    _tabController = TabController(length: 6, vsync: this);
    super.initState();
  }

  @override 
  void dispose(){
    super.dispose();
    _tabController.dispose();
  }

  static const List<Tab> teachWordTabs = [
    Tab(icon: Icon(Icons.image)),
    Tab(icon: Icon(Icons.hearing)),
    Tab(icon: Icon(Icons.pan_tool_alt)),
    Tab(icon: Icon(Icons.create)),
    Tab(icon: Icon(Icons.fact_check)),
    Tab(icon: Icon(Icons.school)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.chevron_left),
          actions: <Widget>[
            IconButton( 
              onPressed: ()=>{}, 
              icon: const Icon(Icons.home_filled)),
          ],
          bottom: TabBar(
              tabs: teachWordTabs,
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: "#28231D".toColor(),
              indicator: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.blue, width: 2, style: BorderStyle.solid))
              ),
            ),
        ),
        body: Column(
          children: [
            TabBarView(
              controller: _tabController,
              children: const [
                Text("Hi"),
                Text("There"),
                Text("How"),
                Text("Do"),
                Text("You"),
                Text("Do ?")
              ]
            )
          ]
        )
      )
    );
  }
}
