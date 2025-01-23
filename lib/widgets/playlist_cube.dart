//dotstudios

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';

class PlaylistCube extends StatelessWidget {
  PlaylistCube(
    this.playlist, {
    super.key,
    this.playlistData,
    this.cubeIcon = HugeIcons.strokeRoundedMusicNoteSquare01,
    this.size = 220,
    this.borderRadius = 13,
  }) : playlistLikeStatus = ValueNotifier<bool>(
          isPlaylistAlreadyLiked(playlist['ytid']),
        );

  final Map? playlistData;
  final Map playlist;
  final IconData cubeIcon;
  final double size;
  final double borderRadius;

  static const double paddingValue = 4;
  static const double typeLabelOffset = 10;
  static const double iconSize = 30;

  final ValueNotifier<bool> playlistLikeStatus;

  static const likeStatusToIconMapper = {
    true: HugeIcons.strokeRoundedFavourite,
    false: HugeIcons.strokeRoundedHeartAdd,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          _buildImage(context),
          if (borderRadius == 13 && playlist['image'] != null)
            Positioned(
              top: typeLabelOffset,
              right: typeLabelOffset,
              child: _buildLabel(context),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return playlist['image'] != null
        ? CachedNetworkImage(
            key: Key(playlist['image'].toString()),
            imageUrl: playlist['image'].toString(),
            height: size,
            width: size,
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
          );
  }

  Widget _buildLabel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(paddingValue),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Text(
        playlist['isAlbum'] != null && playlist['isAlbum'] == true
            ? context.l10n!.album
            : context.l10n!.playlist,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSecondaryContainer,
            ),
      ),
    );
  }
}
