import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/playlist_bar.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:dottunes/widgets/spinner.dart';
import 'package:hugeicons/hugeicons.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  // Use ValueNotifier to hold the playlist data
  ValueNotifier<List> _userPlaylistsNotifier = ValueNotifier<List>([]);

  @override
  void initState() {
    super.initState();
    // Load the user playlists initially
    _loadUserPlaylists();
  }

  // Load user playlists from the API or data source
  Future<void> _loadUserPlaylists() async {
    try {
      List playlists = await getUserPlaylists();
      _userPlaylistsNotifier.value = playlists;
    } catch (e) {
      showToast(context, 'Failed to load playlists: $e');
    }
  }

  @override
  void dispose() {
    // Dispose the notifier when the widget is disposed
    _userPlaylistsNotifier.dispose();
    super.dispose();
  }

  Future<void> _refreshUserPlaylists() async {
    await _loadUserPlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(primaryColor),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildUserPlaylistsSection(primaryColor),
                _buildUserLikedPlaylistsSection(primaryColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 160.0,
      floating: false,
      pinned: true,
      flexibleSpace: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          var top = constraints.biggest.height;
          bool isCollapsed = top <= kToolbarHeight + MediaQuery.of(context).padding.top;
          double roundedCorner = isCollapsed ? 20.0 : 30.0;

          return FlexibleSpaceBar(
            centerTitle: true,
            titlePadding: EdgeInsets.only(
              top: isCollapsed ? 0.0 : 80.0, // Adjust padding when collapsed
              left: 16.0,
            ),
            title: Align(
              alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
              child: FittedBox(
                fit: BoxFit.scaleDown, // Ensures the text scales down to fit
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Catalog',
                      style: TextStyle(
                        fontFamily: 'Nothing',
                        fontSize: isCollapsed ? 24.0 : 42.0, // Adjust font size for collapsed state
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      'Tunes that Connect.',
                      style: TextStyle(
                        fontFamily: 'Nothing',
                        fontSize: isCollapsed ? 12.0 : 18.0,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                // Silver color
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(roundedCorner),
                ),
              ),
            ),
          );
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
    );
  }

  Widget _buildUserPlaylistsSection(Color primaryColor) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SectionTitle(context.l10n!.userPlaylists, primaryColor),
            IconButton(
              padding: const EdgeInsets.only(right: 10),
              onPressed: _showAddPlaylistDialog,
              icon: Icon(
                HugeIcons.strokeRoundedAdd02,
                color: primaryColor,
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            PlaylistBar(
              context.l10n!.recentlyPlayed,
              onPressed: () =>
                  NavigationManager.router.go('/library/userSongs/recents'),
              cubeIcon: HugeIcons.strokeRoundedWorkHistory,
              borderRadius: commonCustomBarRadiusFirst,
            ),
            PlaylistBar(
              context.l10n!.likedSongs,
              onPressed: () =>
                  NavigationManager.router.go('/library/userSongs/liked'),
              cubeIcon: HugeIcons.strokeRoundedMusicNoteSquare02,
            ),
            PlaylistBar(
              context.l10n!.offlineSongs,
              onPressed: () =>
                  NavigationManager.router.go('/library/userSongs/offline'),
              cubeIcon: HugeIcons.strokeRoundedWifiDisconnected04,
              borderRadius: commonCustomBarRadiusLast,
            ),
          ],
        ),
        ValueListenableBuilder<List>(
          valueListenable: _userPlaylistsNotifier,
          builder: (context, playlists, child) {
            return _buildPlaylistListView(context, playlists);
          },
        ),
      ],
    );
  }

  Widget _buildUserLikedPlaylistsSection(Color primaryColor) {
    return ValueListenableBuilder(
      valueListenable: currentLikedPlaylistsLength,
      builder: (_, value, __) {
        return userLikedPlaylists.isNotEmpty
            ? Column(
          children: [
            SectionTitle(
              context.l10n!.likedPlaylists,
              primaryColor,
            ),
            _buildPlaylistListView(context, userLikedPlaylists),
          ],
        )
            : const SizedBox();
      },
    );
  }

  Widget _buildPlaylistListView(BuildContext context, List playlists) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      padding: commonListViewBottmomPadding,
      itemBuilder: (BuildContext context, index) {
        final playlist = playlists[index];
        final borderRadius = getItemBorderRadius(index, playlists.length);
        return PlaylistBar(
          key: ValueKey(playlist['ytid']),
          playlist['title'],
          playlistId: playlist['ytid'],
          playlistArtwork: playlist['image'],
          isAlbum: playlist['isAlbum'],
          playlistData: playlist['source'] == 'user-created' ? playlist : null,
          onLongPress: playlist['source'] == 'user-created' ||
              playlist['source'] == 'user-youtube'
              ? () => _showRemovePlaylistDialog(playlist)
              : null,
          borderRadius: borderRadius,
        );
      },
    );
  }

  void _showAddPlaylistDialog() => showDialog(
    context: context,
    builder: (BuildContext context) {
      var id = '';
      var customPlaylistName = '';
      var isYouTubeMode = true;
      String? imageUrl;

      return StatefulBuilder(
        builder: (context, setState) {
          final activeButtonBackground =
              Theme.of(context).colorScheme.surfaceContainer;
          final inactiveButtonBackground =
              Theme.of(context).colorScheme.secondaryContainer;
          return AlertDialog(
            backgroundColor: Theme.of(context).dialogBackgroundColor,
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYouTubeMode = true;
                            id = '';
                            customPlaylistName = '';
                            imageUrl = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isYouTubeMode
                              ? inactiveButtonBackground
                              : activeButtonBackground,
                        ),
                        child: const Icon(
                          FluentIcons.globe_add_24_filled,
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isYouTubeMode = false;
                            id = '';
                            customPlaylistName = '';
                            imageUrl = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isYouTubeMode
                              ? activeButtonBackground
                              : inactiveButtonBackground,
                        ),
                        child: const Icon(
                          FluentIcons.person_add_24_filled,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (isYouTubeMode)
                    TextField(
                      decoration: InputDecoration(
                        labelText: context.l10n!.youtubePlaylistLinkOrId,
                      ),
                      onChanged: (value) {
                        id = value;
                      },
                    )
                  else ...[
                    TextField(
                      decoration: InputDecoration(
                        labelText: context.l10n!.customPlaylistName,
                      ),
                      onChanged: (value) {
                        customPlaylistName = value;
                      },
                    ),
                    const SizedBox(height: 7),
                    TextField(
                      decoration: InputDecoration(
                        labelText: context.l10n!.customPlaylistImgUrl,
                      ),
                      onChanged: (value) {
                        imageUrl = value;
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  context.l10n!.add.toUpperCase(),
                ),
                onPressed: () async {
                  try {
                    if (isYouTubeMode && id.isNotEmpty) {
                      var result = await addUserPlaylist(id, context);
                      showToast(context, result);
                    } else if (!isYouTubeMode &&
                        customPlaylistName.isNotEmpty) {
                      var result = await createCustomPlaylist(
                          customPlaylistName, imageUrl, context);
                      showToast(context, result);
                    } else {
                      showToast(context,
                          '${context.l10n!.provideIdOrNameError}.');
                    }
                  } catch (e) {
                    showToast(context, 'An error occurred: $e');
                  } finally {
                    Navigator.pop(context);
                    await _refreshUserPlaylists();
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );

  void _showRemovePlaylistDialog(Map playlist) => showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        confirmationMessage: context.l10n!.removePlaylistQuestion,
        submitMessage: context.l10n!.remove,
        onCancel: () {
          Navigator.of(context).pop();
        },
        onSubmit: () {
          Navigator.of(context).pop();

          try {
            if (playlist['ytid'] == null &&
                playlist['source'] == 'user-created') {
              removeUserCustomPlaylist(playlist);
            } else {
              removeUserPlaylist(playlist['ytid']);
            }
            _refreshUserPlaylists();
          } catch (e) {
            showToast(context, 'An error occurred while removing the playlist: $e');
          }
        },
      );
    },
  );
}
