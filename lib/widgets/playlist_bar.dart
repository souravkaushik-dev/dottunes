import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/screens/playlist_page.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';

class PlaylistBar extends StatelessWidget {
  PlaylistBar(
      this.playlistTitle, {
        super.key,
        this.playlistId,
        this.playlistArtwork,
        this.playlistData,
        this.onPressed,
        this.onLongPress,
        this.cubeIcon = HugeIcons.strokeRoundedMusicNoteSquare02,
        this.isAlbum = false,
        this.borderRadius = BorderRadius.zero,
      }) : playlistLikeStatus = ValueNotifier<bool>(
    isPlaylistAlreadyLiked(playlistId),
  );

  final Map? playlistData;
  final String? playlistId;
  final String playlistTitle;
  final String? playlistArtwork;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final IconData cubeIcon;
  final bool? isAlbum;
  final BorderRadius borderRadius;

  static const double paddingValue = 4;
  static const double likeButtonOffset = 5;
  static const double artworkSize = 60;
  static const double iconSize = 27;
  static const double albumTextFontSize = 12;

  final ValueNotifier<bool> playlistLikeStatus;

  static const likeStatusToIconMapper = {
    true: HugeIcons.strokeRoundedFavourite,
    false: HugeIcons.strokeRoundedHeartAdd,
  };

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: commonBarPadding,
      child: GestureDetector(
        onTap: onPressed ??
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(
                    playlistId: playlistId,
                    playlistData: playlistData,
                  ),
                ),
              );
            },
        onLongPress: onLongPress,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          margin: const EdgeInsets.only(bottom: 3),
          child: Padding(
            padding: commonBarContentPadding,
            child: Row(
              children: [
                _buildAlbumArt(),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        playlistTitle,
                        overflow: TextOverflow.ellipsis,
                        style:
                        commonBarTitleStyle.copyWith(color: primaryColor),
                      ),
                    ],
                  ),
                ),
                _buildActionButtons(context, primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return playlistArtwork != null
        ? CachedNetworkImage(
      key: Key(playlistArtwork.toString()),
      height: artworkSize,
      width: artworkSize,
      imageUrl: playlistArtwork.toString(),
      fit: BoxFit.cover,
      imageBuilder: (context, imageProvider) => SizedBox(
        width: artworkSize,
        height: artworkSize,
        child: ClipRRect(
          borderRadius: commonBarRadius,
          child: Image(
            image: imageProvider,
          ),
        ),
      ),
      errorWidget: (context, url, error) => NullArtworkWidget(
        icon: cubeIcon,
        iconSize: iconSize,
        size: artworkSize,
      ),
    )
        : NullArtworkWidget(
      icon: cubeIcon,
      iconSize: iconSize,
      size: artworkSize,
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!offlineMode.value)
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: playlistLikeStatus,
                builder: (_, value, __) {
                  return IconButton(
                    color: primaryColor,
                    icon: Icon(likeStatusToIconMapper[value]),
                    onPressed: () {
                      if (playlistId != null) {
                        final newValue = !playlistLikeStatus.value;
                        playlistLikeStatus.value = newValue;
                        updatePlaylistLikeStatus(playlistId!, newValue);
                        currentLikedPlaylistsLength.value += newValue ? 1 : -1;
                      }
                    },
                  );
                },
              ),
            ],
          ),
      ],
    );
  }
}
