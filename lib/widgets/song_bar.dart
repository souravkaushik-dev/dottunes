//dotstudios

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/formatter.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';
import 'package:hugeicons/hugeicons.dart';



class SongBar extends StatelessWidget {
  SongBar(
    this.song,
    this.clearPlaylist, {
    this.backgroundColor,
    this.showMusicDuration = false,
    this.onPlay,
    this.onRemove,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final dynamic song;
  final bool clearPlaylist;
  final Color? backgroundColor;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final bool showMusicDuration;
  final BorderRadius borderRadius;

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
        onTap: onPlay ??
            () {
              audioHandler.playSong(song);
              if (activePlaylist.isNotEmpty && clearPlaylist) {
                activePlaylist = {
                  'ytid': '',
                  'title': 'No Playlist',
                  'image': '',
                  'source': 'user-created',
                  'list': [],
                };
                activeSongId = 0;
              }
            },
        child: Card(
          color: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Fixed here
          ),
          margin: const EdgeInsets.only(bottom: 3),
          child: Padding(
            padding: commonBarContentPadding,
            child: Row(
              children: [
                _buildAlbumArt(primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        song['title'],
                        overflow: TextOverflow.ellipsis,
                        style: commonBarTitleStyle.copyWith(
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        song['artist'].toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
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

  Widget _buildAlbumArt(Color primaryColor) {
    const size = 55.0;

    final bool isOffline = song['isOffline'] ?? false;
    final String? artworkPath = song['artworkPath'];
    final lowResImageUrl = song['lowResImage'].toString();
    final isDurationAvailable = showMusicDuration && song['duration'] != null;

    if (isOffline && artworkPath != null) {
      return _buildOfflineArtwork(artworkPath, size);
    }

    return _buildOnlineArtwork(
      lowResImageUrl,
      size,
      isDurationAvailable,
      primaryColor,
    );
  }

  Widget _buildOfflineArtwork(String artworkPath, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: commonBarRadius,
        child: Image.file(
          File(artworkPath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildOnlineArtwork(
    String lowResImageUrl,
    double size,
    bool isDurationAvailable,
    Color primaryColor,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        CachedNetworkImage(
          key: Key(song['ytid'].toString()),
          width: size,
          height: size,
          imageUrl: lowResImageUrl,
          imageBuilder: (context, imageProvider) => SizedBox(
            width: size,
            height: size,
            child: ClipRRect(
              borderRadius: commonBarRadius,
              child: Image(
                color: isDurationAvailable
                    ? Theme.of(context).colorScheme.primaryContainer
                    : null,
                colorBlendMode: isDurationAvailable ? BlendMode.multiply : null,
                opacity: isDurationAvailable
                    ? const AlwaysStoppedAnimation(0.45)
                    : null,
                image: imageProvider,
                centerSlice: const Rect.fromLTRB(1, 1, 1, 1),
              ),
            ),
          ),
          errorWidget: (context, url, error) =>
              const NullArtworkWidget(iconSize: 30),
        ),
        if (isDurationAvailable)
          SizedBox(
            width: size - 10,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '(${formatDuration(song['duration'])})',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, Color primaryColor) {
    final songLikeStatus =
        ValueNotifier<bool>(isSongAlreadyLiked(song['ytid']));
    final songOfflineStatus =
        ValueNotifier<bool>(isSongAlreadyOffline(song['ytid']));

    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Theme.of(context).colorScheme.surface,
      icon: Icon(
        HugeIcons.strokeRoundedMoreVerticalCircle02,
        color: primaryColor,
      ),
      onSelected: (String value) {
        switch (value) {
          case 'like':
            songLikeStatus.value = !songLikeStatus.value;
            updateSongLikeStatus(
              song['ytid'],
              songLikeStatus.value,
            );
            final likedSongsLength = currentLikedSongsLength.value;
            currentLikedSongsLength.value = songLikeStatus.value
                ? likedSongsLength + 1
                : likedSongsLength - 1;
            break;
          case 'remove':
            if (onRemove != null) onRemove!();
            break;
          case 'add_to_playlist':
            showAddToPlaylistDialog(context, song);
            break;
          case 'offline':
            if (songOfflineStatus.value) {
              removeSongFromOffline(song['ytid']);
            } else {
              makeSongOffline(song);
            }
            songOfflineStatus.value = !songOfflineStatus.value;
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: 'like',
            child: ValueListenableBuilder<bool>(
              valueListenable: songLikeStatus,
              builder: (_, value, __) {
                return Row(
                  children: [
                    Icon(
                      likeStatusToIconMapper[value],
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value
                          ? context.l10n!.removeFromLikedSongs
                          : context.l10n!.addToLikedSongs,
                    ),
                  ],
                );
              },
            ),
          ),
          if (onRemove != null)
            PopupMenuItem<String>(
              value: 'remove',
              child: Row(
                children: [
                  Icon(HugeIcons.strokeRoundedDelete03, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(context.l10n!.removeFromPlaylist),
                ],
              ),
            ),
          PopupMenuItem<String>(
            value: 'add_to_playlist',
            child: Row(
              children: [
                Icon(HugeIcons.strokeRoundedAdd02, color: primaryColor),
                const SizedBox(width: 8),
                Text(context.l10n!.addToPlaylist),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'offline',
            child: ValueListenableBuilder<bool>(
              valueListenable: songOfflineStatus,
              builder: (_, value, __) {
                return Row(
                  children: [
                    Icon(
                      value
                          ? HugeIcons.strokeRoundedWifiDisconnected04
                          : HugeIcons.strokeRoundedWifiFullSignal,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      value
                          ? context.l10n!.removeOffline
                          : context.l10n!.makeOffline,
                    ),
                  ],
                );
              },
            ),
          ),
        ];
      },
    );
  }
}

void showAddToPlaylistDialog(BuildContext context, dynamic song) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(HugeIcons.strokeRoundedMenu03),
        title: Text(context.l10n!.addToPlaylist),
        content: Container(
          width: double.maxFinite,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.6,
          ),
          child: userCustomPlaylists.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: userCustomPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = userCustomPlaylists[index];
                    return Card(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      elevation: 0,
                      child: ListTile(
                        title: Text(playlist['title']),
                        onTap: () {
                          showToast(
                            context,
                            addSongInCustomPlaylist(
                              context,
                              playlist['title'],
                              song,
                            ),
                          );
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                )
              : Text(
                  context.l10n!.noCustomPlaylists,
                  textAlign: TextAlign.center,
                ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(context.l10n!.cancel),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
