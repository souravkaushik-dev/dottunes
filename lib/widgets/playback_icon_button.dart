/*dottunes envor studios*/

import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/main.dart';

Widget buildPlaybackIconButton(
    PlaybackState? playerState,
    double iconSize,
    Color iconColor,
    Color backgroundColor, {
      double elevation = 2,
      EdgeInsets padding = const EdgeInsets.all(15),
    }) {
  final processingState = playerState?.processingState;
  final playing = playerState?.playing;

  // Initialize the icon with a default value
  IconData icon = HugeIcons.strokeRoundedPlay;
  VoidCallback? onPressed;

  switch (processingState) {
    case AudioProcessingState.buffering:
    case AudioProcessingState.loading:
      icon = HugeIcons.strokeRoundedHelicopter; // Assign icon for loading/buffering
      onPressed = null; // Disable button while loading
      break;
    case AudioProcessingState.completed:
      icon = HugeIcons.strokeRoundedClock04; // Assign icon for completed state
      onPressed = () => audioHandler.seek(Duration.zero); // Reset to start
      break;
    default:
    // In default case, check playing state and assign appropriate icons
      icon = playing != true
          ? HugeIcons.strokeRoundedPlay
          : HugeIcons.strokeRoundedPause;
      onPressed = playing != true ? audioHandler.play : audioHandler.pause;
  }

  return RawMaterialButton(
    elevation: elevation,
    onPressed: onPressed,
    fillColor: backgroundColor,
    splashColor: Colors.transparent,
    padding: padding,
    shape: const CircleBorder(),
    child: Icon(
      icon,
      color: iconColor,
      size: iconSize,
    ),
  );
}
