//dotstudios

import 'package:flutter/material.dart';

const _toastDuration = Duration(seconds: 3);

void showToast(BuildContext context, String text) {
  print('showToast called with context: $context');
  final scaffoldMessenger = ScaffoldMessenger.of(context);

  if (scaffoldMessenger.mounted) {
    scaffoldMessenger.showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        behavior: SnackBarBehavior.floating,
        content: Text(
          text,
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
          ),
        ),
        duration: _toastDuration,
      ),
    );
  }
}


void showToastWithButton(
    BuildContext context,
    String text,
    String buttonName,
    VoidCallback onPressedToast,
    ) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      content: Text(
        text,
        style: TextStyle(
          color: Theme.of(context).colorScheme.inverseSurface,
        ),
      ),
      action: SnackBarAction(
        label: buttonName,
        textColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => onPressedToast(),
      ),
      duration: _toastDuration,
    ),
  );
}
