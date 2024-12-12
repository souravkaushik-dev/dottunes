/*dottunes envor studios*/

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/widgets/marque.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';
import 'package:hugeicons/hugeicons.dart';

class SongCube extends StatelessWidget {
  SongCube(
    this.song, {
    this.onRemove,
    this.onPlay,
    this.clearPlaylist = false,
    this.showFavoriteButton = true,
    this.size = 220,
    super.key,
  });

  final dynamic song;
  final bool clearPlaylist;
  final bool showFavoriteButton;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final double size;

  static const likeStatusToIconMapper = {
    true: HugeIcons.strokeRoundedStars,
    false: HugeIcons.strokeRoundedStar,
  };

  late final songLikeStatus =
      ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));

  @override
  Widget build(BuildContext context) {
    final _secondaryColor = Theme.of(context).colorScheme.secondary;
    final _onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    final bool isOffline = song['isOffline'] ?? false;
    final String? artworkPath = song['artworkPath'];

    return Column(
      children: [
        Stack(
          children: <Widget>[
            GestureDetector(
              onTap: onPlay ??
                  () {
                    audioHandler.playSong(song);
                    if (activePlaylist.isNotEmpty && clearPlaylist) {
                      activePlaylist = {
                        'ytid': '',
                        'title': 'No Playlist',
                        'image': '',
                        'list': [],
                      };
                      id = 0;
                    }
                  },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: isOffline && artworkPath != null
                    ? SizedBox(
                        width: size,
                        height: size,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            File(artworkPath),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : CachedNetworkImage(
                        key: Key(song['ytid'].toString()),
                        height: size,
                        width: size,
                        imageUrl: song['highResImage'].toString(),
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => NullArtworkWidget(
                          iconSize: 30,
                          size: size,
                        ),
                      ),
              ),
            ),
            if (showFavoriteButton)
              ValueListenableBuilder<bool>(
                valueListenable: songLikeStatus,
                builder: (_, value, __) {
                  return Positioned(
                    bottom: 5,
                    right: 5,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _secondaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          songLikeStatus.value = !songLikeStatus.value;
                          updateSongLikeStatus(
                            song['ytid'],
                            songLikeStatus.value,
                          );
                          final likedSongsLength =
                              currentLikedSongsLength.value;
                          currentLikedSongsLength.value = value
                              ? likedSongsLength + 1
                              : likedSongsLength - 1;
                        },
                        icon: Icon(
                          likeStatusToIconMapper[value],
                          color: _onPrimaryColor,
                          size: 25,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: size - 15,
          child: Column(
            children: <Widget>[
              MarqueeWidget(
                child: Text(
                  song['title'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              MarqueeWidget(
                child: Text(
                  song['artist'].toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
