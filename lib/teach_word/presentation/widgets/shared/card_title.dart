// lib/teach_word/presentation/widgets/shared/card_title.dart

import 'package:flutter/material.dart';

class TeachWordCardTitle extends StatelessWidget {
  final String title;
  final Color iconsColor;
  final bool canNavigatePrevious;
  final bool canNavigateNext;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const TeachWordCardTitle({
    super.key,
    required this.title,
    required this.iconsColor,
    this.canNavigatePrevious = false,
    this.canNavigateNext = false,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: canNavigatePrevious ? iconsColor : iconsColor.withOpacity(0.3),
          ),
          onPressed: canNavigatePrevious ? onPrevious : null,
        ),
        Text(
          title,
          style: TextStyle(
            color: iconsColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_forward,
            color: canNavigateNext ? iconsColor : iconsColor.withOpacity(0.3),
          ),
          onPressed: canNavigateNext ? onNext : null,
        ),
      ],
    );
  }
}
