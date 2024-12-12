/*dottunes envor studios*/

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/screens/playlist_page.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';
import 'package:hugeicons/hugeicons.dart';

class PlaylistCube extends StatelessWidget {
  PlaylistCube(
    this.playlist, {
    super.key,
    this.playlistData,
    this.onClickOpen = true,
    this.cubeIcon = HugeIcons.strokeRoundedMusicNote01,
    this.size = 220,
    this.borderRadius = 13, required isAlbum,
  }) : playlistLikeStatus = ValueNotifier<bool>(
          isPlaylistAlreadyLiked(playlist['ytid']),
        );

  final Map? playlistData;
  final Map playlist;
  final bool onClickOpen;
  final IconData cubeIcon;
  final double size;
  final double borderRadius;

  static const double paddingValue = 4;
  static const double likeButtonOffset = 5;
  static const double iconSize = 30;
  static const double albumTextFontSize = 12;

  final ValueNotifier<bool> playlistLikeStatus;

  static const likeStatusToIconMapper = {
    true: HugeIcons.strokeRoundedFavourite,
    false: HugeIcons.strokeRoundedHeartAdd,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final secondaryColor = colorScheme.secondary;
    final onSecondaryColor = colorScheme.onSecondary;

    return Stack(
      children: <Widget>[
        GestureDetector(
          onTap:
              onClickOpen && (playlist['ytid'] != null || playlistData != null)
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaylistPage(
                            playlistId: playlist['ytid'],
                            playlistData: playlistData,
                          ),
                        ),
                      );
                    }
                  : null,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(borderRadius),
            child: playlist['image'] != null
                ? CachedNetworkImage(
                    key: Key(playlist['image'].toString()),
                    height: size,
                    width: size,
                    imageUrl: playlist['image'].toString(),
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => NullArtworkWidget(
                      icon: cubeIcon,
                      iconSize: iconSize,
                      size: size,
                      title: playlist['title'],
                    ),
                  )
                : NullArtworkWidget(
                    icon: cubeIcon,
                    iconSize: iconSize,
                    size: size,
                    title: playlist['title'],
                  ),
          ),
        ),
        if (borderRadius == 13 && playlist['image'] != null)
          Positioned(
            top: likeButtonOffset,
            right: likeButtonOffset,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(paddingValue),
              ),
              padding: const EdgeInsets.all(paddingValue),
              child: Text(
                playlist['isAlbum'] != null && playlist['isAlbum'] == true
                    ? context.l10n!.album
                    : context.l10n!.playlist,
                style: TextStyle(
                  color: onSecondaryColor,
                  fontSize: albumTextFontSize,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
