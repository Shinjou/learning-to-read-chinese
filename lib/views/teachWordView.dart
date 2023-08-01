import 'package:flutter/material.dart';

class TeachWordView extends StatefulWidget {
  const TeachWordView({super.key});

  @override
  State<TeachWordView> createState() => _TeachWordViewState();
}

class _TeachWordViewState extends State<TeachWordView> {

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
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton( 
            onPressed: ()=>{}, 
            icon: const Icon(Icons.home_filled)),
        ] 
      ),
      body: Column(
        children: [
          TabBar(
            tabs: teachWordTabs
          ),
          TabBarView(
            children: [
              Text("Hi"),
              Text("There"),
              Text("How")
            ]
          )
        ]
      )
    );
  }
}
