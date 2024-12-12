/*dottunes envor studios*/

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/formatter.dart';
import 'package:dottunes/widgets/no_artwork_cube.dart';

class SongBar extends StatelessWidget {
  SongBar(
      this.song,
      this.clearPlaylist, {
        this.backgroundColor,
        this.showMusicDuration = false,
        this.onPlay,
        this.onRemove,
        super.key,
      });

  final dynamic song;
  final bool clearPlaylist;
  final Color? backgroundColor;
  final VoidCallback? onRemove;
  final VoidCallback? onPlay;
  final bool showMusicDuration;

  static const likeStatusToIconMapper = {
    true: HugeIcons.strokeRoundedFavourite,
    false  : HugeIcons.strokeRoundedHeartAdd,
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
        child: Container(
          // Replaced Card with Container for a flat UI
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.transparent, // Use transparent or set color
            borderRadius: BorderRadius.zero, // No rounded corners
          ),
          padding: const EdgeInsets.all(8),
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
                      style:
                      commonBarTitleStyle.copyWith(color: primaryColor),
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
    );
  }

  Widget _buildAlbumArt(Color primaryColor) {
    const size = 55.0; // Size of the image

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
        borderRadius: BorderRadius.circular(size * 0.2), // Adjusted border radius for rounded square
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
              borderRadius: BorderRadius.circular(size * 0.2), // Adjusted border radius for rounded square
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        if (!offlineMode.value)
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: songLikeStatus,
                builder: (_, value, __) {
                  return GestureDetector(
                    child: Icon(
                      likeStatusToIconMapper[value],
                      color: primaryColor,
                    ),
                    onTap: () {
                      songLikeStatus.value = !songLikeStatus.value;
                      updateSongLikeStatus(
                        song['ytid'],
                        songLikeStatus.value,
                      );
                      final likedSongsLength = currentLikedSongsLength.value;
                      currentLikedSongsLength.value =
                      value ? likedSongsLength + 1 : likedSongsLength - 1;
                    },
                  );
                },
              ),
              const SizedBox(width: 8),
              if (onRemove != null)
                GestureDetector(
                  child:
                  Icon(HugeIcons.strokeRoundedDelete02, color: primaryColor),
                  onTap: () => onRemove!(),
                )
              else
                GestureDetector(
                  child: Icon(HugeIcons.strokeRoundedAdd02, color: primaryColor),
                  onTap: () => showAddToPlaylistDialog(context, song),
                ),
            ],
          ),
        const SizedBox(width: 8),
        ValueListenableBuilder<bool>(
          valueListenable: songOfflineStatus,
          builder: (_, value, __) {
            return GestureDetector(
              child: Icon(
                value
                    ? HugeIcons.strokeRoundedWifi01
                    : HugeIcons.strokeRoundedWifiError01,
                color: primaryColor,
              ),
              onTap: () {
                if (value) {
                  removeSongFromOffline(song['ytid']);
                } else {
                  makeSongOffline(song);
                }

                songOfflineStatus.value = !songOfflineStatus.value;
              },
            );
          },
        ),
      ],
    );
  }
}
void showAddToPlaylistDialog(BuildContext context, dynamic song) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        icon: const Icon(HugeIcons.strokeRoundedListView),
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
                    addSongInCustomPlaylist(playlist['title'], song);
                    showToast(context, context.l10n!.songAdded);
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
