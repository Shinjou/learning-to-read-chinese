import 'package:flutter/material.dart';
import 'package:ltrc/extensions.dart';
import 'package:ltrc/widgets/mainPage/left_right_switch.dart';
import 'package:ltrc/widgets/teach_word/tab_bar_view.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
    Tab(icon: Icon(Icons.create)),
    Tab(icon: Icon(Icons.school)),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: teachWordTabs.length,
      child: Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.chevron_left),
          centerTitle: true,
          title: const Text("1|手拉手"),
          titleTextStyle: TextStyle(
            color: "#F5F5DC".toColor(),
            fontSize: 34,
          ),
          actions: <Widget>[
            IconButton( 
              onPressed: ()=>{}, 
              icon: const Icon(Icons.home_filled)),
          ],
          bottom: TabBar(
              tabs: teachWordTabs,
              controller: _tabController,
              labelColor: '#28231D'.toColor(),
              dividerColor: '#999999'.toColor(),
              unselectedLabelColor: '#999999'.toColor(),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), 
                  topRight: Radius.circular(10),
                ),
                color: '#999999'.toColor(),
              ),
            ),
        ),
        body: 
            TabBarView(
              controller: _tabController,
              children: const [
                TeachWordTabBarView(),
                TeachWordTabBarView(),
                TeachWordTabBarView(),
                TeachWordTabBarView(),
              ]
            )
      )
    );
  }
}
