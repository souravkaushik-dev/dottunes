//dotstudios

import 'package:audio_service/audio_service.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/main.dart';
import 'package:hugeicons/hugeicons.dart';



Widget buildPlaybackIconButton(
  PlaybackState? playerState,
  double iconSize,
  Color iconColor,
  Color backgroundColor, {
  double elevation = 2,
  EdgeInsets padding = const EdgeInsets.all(15),
}) {
  final processingState = playerState?.processingState;
  final isPlaying = playerState?.playing ?? false;

  final iconDataAndAction = getIconFromState(processingState, isPlaying);

  return RawMaterialButton(
    elevation: elevation,
    onPressed: iconDataAndAction.onPressed,
    fillColor: backgroundColor,
    splashColor: Colors.transparent,
    padding: padding,
    shape: const CircleBorder(),
    child: Icon(
      iconDataAndAction.iconData,
      color: iconColor,
      size: iconSize,
    ),
  );
}

_IconDataAndAction getIconFromState(
  AudioProcessingState? processingState,
  bool isPlaying,
) {
  switch (processingState) {
    case AudioProcessingState.buffering:
    case AudioProcessingState.loading:
      return _IconDataAndAction(
        iconData: HugeIcons.strokeRoundedLoading04,
      );
    case AudioProcessingState.completed:
      return _IconDataAndAction(
        iconData: HugeIcons.strokeRoundedRotateClockwise,
        onPressed: () => audioHandler.seek(Duration.zero),
      );
    default:
      return _IconDataAndAction(
        iconData: isPlaying
            ? HugeIcons.strokeRoundedStop
            : HugeIcons.strokeRoundedPlay,
        onPressed: isPlaying ? audioHandler.pause : audioHandler.play,
      );
  }
}

class _IconDataAndAction {
  _IconDataAndAction({
    required this.iconData,
    this.onPressed,
  });
  final IconData iconData;
  final VoidCallback? onPressed;
}
