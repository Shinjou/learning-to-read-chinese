import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late int _grade;
  late String _publisher;

  @override
  void initState() {
    super.initState();
    _loadGradeAndPublisher();
  }

  void _loadGradeAndPublisher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _grade = prefs.getInt('grade') ?? 1;
      _publisher = prefs.getString('publisher') ?? "HanLin";
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
          children:[
            FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 0.4,
              child: Card(child: Text('哈囉!')),
            ),
            FractionallySizedBox(
              widthFactor: 1.0,
              heightFactor: 0.6,
              child: Card(child: Text('哈囉!')),
            ),
          ]
        ),
    );
  }
}