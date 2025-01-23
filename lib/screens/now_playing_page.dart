//dotstudios

import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/models/position_data.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/flutter_bottom_sheet.dart';
import 'package:dottunes/utilities/formatter.dart';
import 'package:dottunes/utilities/mediaitem.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/custom_slider.dart';
import 'package:dottunes/widgets/marque.dart';
import 'package:dottunes/widgets/playback_icon_button.dart';
import 'package:dottunes/widgets/song_artwork.dart';
import 'package:dottunes/widgets/song_bar.dart';
import 'package:dottunes/widgets/spinner.dart';
import 'package:hugeicons/hugeicons.dart';



final _lyricsController = FlipCardController();

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(HugeIcons.strokeRoundedArrowDown01),
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<MediaItem?>(
        stream: audioHandler.mediaItem,
        builder: (context, snapshot) {
          if (snapshot.data == null || !snapshot.hasData) {
            return const SizedBox.shrink();
          } else {
            final metadata = snapshot.data!;
            final screenHeight = size.height;

            return Column(
              children: [
                SizedBox(height: screenHeight * 0.02),
                buildArtwork(context, size, metadata),
                SizedBox(height: screenHeight * 0.01),
                if (!(metadata.extras?['isLive'] ?? false))
                  _buildPlayer(
                    context,
                    size,
                    metadata.extras?['ytid'],
                    metadata,
                  ),
              ],
            );
          }
        },
      ),
    );
  }

  Widget buildArtwork(BuildContext context, Size size, MediaItem metadata) {
    const _padding = 70;
    const _radius = 55.0;
    final screen = (size.width + size.height) / 3.0;
    final imageSize = screen - _padding;
    const lyricsTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
    );

    return FlipCard(
      rotateSide: RotateSide.right,
      onTapFlipping: !offlineMode.value,
      controller: _lyricsController,
      frontWidget: Stack(
        children: [
          // Apply the blur effect to the background
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Adjust blur intensity
              child: SongArtworkWidget(
                metadata: metadata,
                size: imageSize,
                errorWidgetIconSize: size.width / 10,
                borderRadius: _radius,
              ),
            ),
          ),
        ],
      ),
      backWidget: Container(
        width: imageSize,
        height: imageSize,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: Stack(
          children: [
            // Add blur effect for the back widget as well (optional)
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0), // Adjust blur intensity
              child: Container(
                color: Colors.transparent,
              ),
            ),
            FutureBuilder<String?>(
              future: getSongLyrics(metadata.artist ?? '', metadata.title),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Spinner();
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      context.l10n!.lyricsNotAvailable,
                      style: lyricsTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (snapshot.hasData && snapshot.data != 'not found') {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        snapshot.data!,
                        style: lyricsTextStyle.copyWith(
                          fontFamily: 'Nothing',
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text(
                      context.l10n!.lyricsNotAvailable,
                      style: lyricsTextStyle.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                        fontFamily: 'Nothing',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildMarqueeText(
    String text,
    Color fontColor,
    double fontSize,
    FontWeight fontWeight,
  ) {
    return MarqueeWidget(
      backDuration: const Duration(seconds: 1),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontFamily: 'Nothing',
          fontWeight: fontWeight,
          color: fontColor,
        ),
      ),
    );
  }

  Widget _buildPlayer(
    BuildContext context,
    Size size,
    dynamic audioId,
    MediaItem mediaItem,
  ) {
    const iconSize = 20.0;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: screenWidth * 0.85,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildMarqueeText(
                  mediaItem.title,
                  Theme.of(context).colorScheme.primary,
                  screenHeight * 0.028,
                  FontWeight.w600,
                ),
                SizedBox(height: screenHeight * 0.005),
                if (mediaItem.artist != null)
                  buildMarqueeText(
                    mediaItem.artist!,
                    Theme.of(context).colorScheme.secondary,
                    screenHeight * 0.017,
                    FontWeight.w500,
                  ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.01),
          buildPositionSlider(),
          buildPlayerControls(context, size, mediaItem, iconSize),
          SizedBox(height: size.height * 0.055),
          buildBottomActions(context, audioId, mediaItem, iconSize),
        ],
      ),
    );
  }

  Widget buildPositionSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: StreamBuilder<PositionData>(
        stream: audioHandler.positionDataStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data == null) {
            return const SizedBox.shrink();
          }
          final positionData = snapshot.data!;
          final primaryColor = Theme.of(context).colorScheme.primary;
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSlider(
                positionData,
              ),
              buildPositionRow(
                primaryColor,
                positionData,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildSlider(
    PositionData positionData,
  ) {
    return CustomSlider(
      isSquiglySliderEnabled: useSquigglySlider.value,
      value: positionData.position.inSeconds.toDouble(),
      onChanged: (value) {
        audioHandler.seek(Duration(seconds: value.toInt()));
      },
      max: positionData.duration.inSeconds.toDouble(),
      squiggleAmplitude: 3,
      squiggleWavelength: 5,
      squiggleSpeed: 0.1,
    );
  }

  Widget buildPositionRow(Color fontColor, PositionData positionData) {
    final positionText = formatDuration(positionData.position.inSeconds);
    final durationText = formatDuration(positionData.duration.inSeconds);
    final textStyle = TextStyle(fontSize: 15, color: fontColor);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(positionText, style: textStyle),
          Text(durationText, style: textStyle),
        ],
      ),
    );
  }

  Widget buildPlayerControls(
    BuildContext context,
    Size size,
    MediaItem mediaItem,
    double iconSize,
  ) {
    final _primaryColor = Theme.of(context).colorScheme.primary;
    final _secondaryColor = Theme.of(context).colorScheme.secondaryContainer;

    final screen = ((size.width + size.height) / 4) - 10;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: shuffleNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton.filled(
                      icon: Icon(
                        HugeIcons.strokeRoundedShuffleSquare,
                        color: _secondaryColor,
                      ),
                      iconSize: iconSize,
                      onPressed: () {
                        audioHandler.setShuffleMode(
                          AudioServiceShuffleMode.none,
                        );
                      },
                    )
                  : IconButton.filledTonal(
                      icon: Icon(
                        HugeIcons.strokeRoundedShuffle,
                        color: _primaryColor,
                      ),
                      iconSize: iconSize,
                      onPressed: () {
                        audioHandler.setShuffleMode(
                          AudioServiceShuffleMode.all,
                        );
                      },
                    );
            },
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedArrowLeftDouble,
                  color: audioHandler.hasPrevious
                      ? _primaryColor
                      : _secondaryColor,
                ),
                iconSize: screen * 0.115,
                onPressed: () => audioHandler.skipToPrevious(),
                splashColor: Colors.transparent,
              ),
              const SizedBox(width: 10),
              StreamBuilder<PlaybackState>(
                stream: audioHandler.playbackState,
                builder: (context, snapshot) {
                  return buildPlaybackIconButton(
                    snapshot.data,
                    screen * 0.125,
                    _primaryColor,
                    _secondaryColor,
                    elevation: 0,
                    padding: EdgeInsets.all(screen * 0.08),
                  );
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: Icon(
                  HugeIcons.strokeRoundedArrowRightDouble,
                  color: audioHandler.hasNext ? _primaryColor : _secondaryColor,
                ),
                iconSize: screen * 0.115,
                onPressed: () => audioHandler.skipToNext(),
                splashColor: Colors.transparent,
              ),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: repeatNotifier,
            builder: (_, value, __) {
              return value
                  ? IconButton.filled(
                      icon: Icon(
                        HugeIcons.strokeRoundedRepeatOne01,
                        color: _secondaryColor,
                      ),
                      iconSize: iconSize,
                      onPressed: () {
                        audioHandler.setRepeatMode(
                          AudioServiceRepeatMode.none,
                        );
                      },
                    )
                  : IconButton.filledTonal(
                      icon: Icon(
                        HugeIcons.strokeRoundedRepeatOff,
                        color: _primaryColor,
                      ),
                      iconSize: iconSize,
                      onPressed: () {
                        audioHandler.setRepeatMode(
                          AudioServiceRepeatMode.all,
                        );
                      },
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomActions(
    BuildContext context,
    dynamic audioId,
    MediaItem mediaItem,
    double iconSize,
  ) {
    final songLikeStatus = ValueNotifier<bool>(isSongAlreadyLiked(audioId));
    late final songOfflineStatus =
        ValueNotifier<bool>(isSongAlreadyOffline(audioId));

    final _primaryColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
        ValueListenableBuilder<bool>(
          valueListenable: songOfflineStatus,
          builder: (_, value, __) {
            return IconButton.filledTonal(
              icon: Icon(
                value
                    ? HugeIcons.strokeRoundedWifiDisconnected04
                    : HugeIcons.strokeRoundedWifiFullSignal,
                color: _primaryColor,
              ),
              iconSize: iconSize,
              onPressed: () {
                if (value) {
                  removeSongFromOffline(audioId);
                } else {
                  makeSongOffline(mediaItemToMap(mediaItem));
                }

                songOfflineStatus.value = !songOfflineStatus.value;
              },
            );
          },
        ),
        if (!offlineMode.value)
          IconButton.filledTonal(
            icon: Icon(
              Icons.add,
              color: _primaryColor,
            ),
            iconSize: iconSize,
            onPressed: () {
              showAddToPlaylistDialog(context, mediaItemToMap(mediaItem));
            },
          ),
        if (activePlaylist['list'].isNotEmpty)
          IconButton.filledTonal(
            icon: Icon(
              HugeIcons.strokeRoundedMenu08,
              color: _primaryColor,
            ),
            iconSize: iconSize,
            onPressed: () {
              showCustomBottomSheet(
                context,
                ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  padding: commonListViewBottmomPadding,
                  itemCount: activePlaylist['list'].length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                  ) {
                    final borderRadius = getItemBorderRadius(
                      index,
                      activePlaylist['list'].length,
                    );
                    return SongBar(
                      activePlaylist['list'][index],
                      false,
                      onPlay: () => {
                        audioHandler.playPlaylistSong(songIndex: index),
                      },
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: borderRadius,
                    );
                  },
                ),
              );
            },
          ),
        if (!offlineMode.value)
          IconButton.filledTonal(
            icon: Icon(
              HugeIcons.strokeRoundedSpeechToText,
              color: _primaryColor,
            ),
            iconSize: iconSize,
            onPressed: _lyricsController.flipcard,
          ),
        if (!offlineMode.value)
          ValueListenableBuilder<bool>(
            valueListenable: songLikeStatus,
            builder: (_, value, __) {
              return IconButton.filledTonal(
                icon: Icon(
                  value
                      ? HugeIcons.strokeRoundedFavourite
                      : HugeIcons.strokeRoundedHeartAdd,
                  color: _primaryColor,
                ),
                iconSize: iconSize,
                onPressed: () {
                  updateSongLikeStatus(audioId, !songLikeStatus.value);
                  songLikeStatus.value = !songLikeStatus.value;
                },
              );
            },
          ),
      ],
    );
  }
}
