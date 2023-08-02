import 'package:flutter/material.dart';

class WordsView extends StatelessWidget {
  const WordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => {},),
        title: const Text("01|拍拍手"),
        actions: [
          IconButton(icon: const Icon(Icons.home), onPressed: ()=>{},)
        ],
      ),
      body: Column(
        
      )
    );
  }
}