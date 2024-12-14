// lib/teach_word/utils/error_utils.dart

import 'package:flutter/material.dart';

class ErrorUtils {
  static void showError(
    BuildContext context,
    String message, {
    String title = '',
    bool showHomeButton = true,
    VoidCallback? onDismiss,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            if (showHomeButton)
              TextButton(
                child: const Text('回首頁'),
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onDismiss?.call();
                    Navigator.of(context).pushReplacementNamed('/mainPage');
                  }
                },
              ),
            if (onRetry != null)
              TextButton(
                child: const Text('重試'),
                onPressed: () {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    onRetry();
                  }
                },
              ),
            TextButton(
              child: const Text('確定'),
              onPressed: () {
                if (context.mounted) {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
