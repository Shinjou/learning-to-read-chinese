// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;

// const String demoChar = "手";
// String svgJson = "";

// class GetSvgJson extends StatefulWidget {
//   const GetSvgJson({super.key});

//   @override
//   State<GetSvgJson> createState() => _GetSvgJsonState();
// }

// class _GetSvgJsonState extends State<GetSvgJson> {
//   String svg = "";

//   Future<String> readJson() async {
//     final String response =
//         await rootBundle.loadString('lib/assets/svg/word.json');
//     return response;
//   }

//   @override
//   void initState() {
//     super.initState();
//     readJson().then((result) {
//       setState(() {
//         svgJson = result;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     String word;
//     bool isBpmf;
//     dynamic obj = ModalRoute.of(context)!.settings.arguments;
//     word = obj["word"];
//     isBpmf = obj["isBpmf"];
//     Navigator.of(context)
//         .pushNamed('/teachWord', arguments: {'word': word, 'isBpmf': isBpmf});

//     return Container();
//   }
// }
