//dotstudios

import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/playlist_cube.dart';
import 'package:dottunes/widgets/playlist_header.dart';
import 'package:dottunes/widgets/song_bar.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:hugeicons/hugeicons.dart';

class UserSongsPage extends StatefulWidget {
  const UserSongsPage({
    super.key,
    required this.page,
  });

  final String page;

  @override
  State<UserSongsPage> createState() => _UserSongsPageState();
}

class _UserSongsPageState extends State<UserSongsPage> {
  bool isEditEnabled = false;

  @override
  Widget build(BuildContext context) {
    final title = getTitle(widget.page, context);
    final icon = getIcon(widget.page);
    final songsList = getSongsList(widget.page);
    final length = getLength(widget.page);

    return Scaffold(
      appBar: AppBar(
        title: offlineMode.value ? Text(title) : null,
        actions: [
          if (title == context.l10n!.likedSongs)
            IconButton(
              onPressed: () {
                setState(() {
                  isEditEnabled = !isEditEnabled;
                });
              },
              icon: Icon(
                HugeIcons.strokeRoundedArrange,
                color: isEditEnabled
                    ? Theme.of(context).colorScheme.inversePrimary
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
      body: _buildCustomScrollView(title, icon, songsList, length),
    );
  }

  Widget _buildCustomScrollView(
    String title,
    IconData icon,
    List songsList,
    ValueNotifier length,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: buildPlaylistHeader(title, icon, songsList.length),
          ),
        ),
        buildSongList(title, songsList, length),
      ],
    );
  }

  String getTitle(String page, BuildContext context) {
    return {
          'liked': context.l10n!.likedSongs,
          'offline': context.l10n!.offlineSongs,
          'recents': context.l10n!.recentlyPlayed,
        }[page] ??
        context.l10n!.playlist;
  }

  IconData getIcon(String page) {
    return {
          'liked': HugeIcons.strokeRoundedHeartAdd,
          'offline': HugeIcons.strokeRoundedWifiDisconnected04,
          'recents': HugeIcons.strokeRoundedWorkHistory,
        }[page] ??
        HugeIcons.strokeRoundedHeartAdd;
  }

  List getSongsList(String page) {
    return {
          'liked': userLikedSongsList,
          'offline': userOfflineSongs,
          'recents': userRecentlyPlayed,
        }[page] ??
        userLikedSongsList;
  }

  ValueNotifier getLength(String page) {
    return {
          'liked': currentLikedSongsLength,
          'offline': currentOfflineSongsLength,
          'recents': currentRecentlyPlayedLength,
        }[page] ??
        currentLikedSongsLength;
  }

  Widget buildPlaylistHeader(String title, IconData icon, int songsLength) {
    return PlaylistHeader(
      _buildPlaylistImage(title, icon),
      title,
      songsLength,
    );
  }

  Widget _buildPlaylistImage(String title, IconData icon) {
    return PlaylistCube(
      {'title': title},
      size: MediaQuery.sizeOf(context).width / 2.5,
      cubeIcon: icon,
    );
  }

  Widget buildSongList(
    String title,
    List songsList,
    ValueNotifier currentSongsLength,
  ) {
    final _playlist = {
      'ytid': '',
      'title': title,
      'source': 'user-created',
      'list': songsList,
    };
    return ValueListenableBuilder(
      valueListenable: currentSongsLength,
      builder: (_, value, __) {
        if (title == context.l10n!.likedSongs) {
          return SliverReorderableList(
            itemCount: songsList.length,
            itemBuilder: (context, index) {
              final song = songsList[index];

              final borderRadius = getItemBorderRadius(index, songsList.length);

              return ReorderableDragStartListener(
                enabled: isEditEnabled,
                key: Key(song['ytid'].toString()),
                index: index,
                child: SongBar(
                  song,
                  true,
                  onPlay: () => {
                    audioHandler.playPlaylistSong(
                      playlist: activePlaylist != _playlist ? _playlist : null,
                      songIndex: index,
                    ),
                  },
                  borderRadius: borderRadius,
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                moveLikedSong(oldIndex, newIndex);
              });
            },
          );
        } else {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final song = songsList[index];
                song['isOffline'] = title == context.l10n!.offlineSongs;
                return SongBar(
                  song,
                  true,
                  onPlay: () => {
                    audioHandler.playPlaylistSong(
                      playlist: activePlaylist != _playlist ? _playlist : null,
                      songIndex: index,
                    ),
                  },
                );
              },
              childCount: songsList.length,
            ),
          );
        }
      },
    );
  }
}
