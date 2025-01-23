//dotstudios

import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';

class NullArtworkWidget extends StatelessWidget {
  const NullArtworkWidget({
    super.key,
    this.icon = HugeIcons.strokeRoundedMusicNoteSquare01,
    this.size = 220,
    this.iconSize = 64,
    this.title,
  });

  final IconData icon;
  final double iconSize;
  final double size;
  final String? title;

  static const double paddingValue = 10;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.secondary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: iconSize,
              color: colorScheme.onSecondary,
            ),
            if (title != null)
              Padding(
                padding: const EdgeInsets.all(paddingValue),
                child: Text(
                  title!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
