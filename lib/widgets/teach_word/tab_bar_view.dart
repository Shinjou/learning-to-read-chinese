import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ltrc/extensions.dart';


class TeachWordTabBarView extends ConsumerWidget {
  final Widget content;
  const TeachWordTabBarView({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        width: MediaQuery.of(context).size.width,
        child: Container(
          decoration: BoxDecoration(
            color: '#28231D'.toColor(),
            border: Border.all(color: '#999999'.toColor(), width: 6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    ]);
  }
}
