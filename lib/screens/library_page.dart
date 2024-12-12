/*dottunes envor studios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/custom_search_bar.dart';
import 'package:dottunes/widgets/playlist_bar.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:dottunes/widgets/spinner.dart';

import 'package:flutter/material.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();

  late Future<List> _userPlaylistsFuture = getUserPlaylists();

  final List<bool> _visibleSections = [true, true, false, false];

  Future<void> _refreshUserPlaylists() async {
    setState(() {
      _userPlaylistsFuture = getUserPlaylists();
    });
  }

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final labels = [
      context.l10n!.userPlaylists,
      context.l10n!.likedPlaylists,
      context.l10n!.playlists,
      context.l10n!.albums,
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('Library', style: TextStyle(
                fontFamily: 'Nothing',  // Replace with your custom font family
                fontSize: 34, // Set the desired font size
                fontWeight: FontWeight.bold, // Optional: Add weight if needed
              ),
            ),
              background: ClipRRect(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0),
                ),
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer, // Set the color for the background
                ),
              ),
            ),
            pinned: true,
            floating: false,
            snap: false,
            backgroundColor: Colors.transparent, // Remove the default color to let the rounded corner show
          ),
          SliverToBoxAdapter(
            child: CustomSearchBar(
              onSubmitted: (String value) => setState(() {}),
              controller: _searchBar,
              focusNode: _inputNode,
              labelText: '${context.l10n!.search}...',
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              child: Wrap(
                spacing: 10,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(4, (index) {
                  return _buildFilterChip(index, labels[index]);
                }),
              ),
            ),
          ),
          if (_visibleSections[0]) _buildUserPlaylistsSection(primaryColor),
          if (_visibleSections[1]) _buildUserLikedPlaylistsSection(primaryColor),
          if (_visibleSections[2]) _buildPlaylistsSection(primaryColor, 'playlist'),
          if (_visibleSections[3]) _buildPlaylistsSection(primaryColor, 'album'),
        ],
      ),
    );

  }

  Widget _buildUserPlaylistsSection(Color primaryColor) {
    return SliverList(
      delegate: SliverChildListDelegate([
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
            ListTile(
              title: Text(context.l10n!.recentlyPlayed),
              onTap: () =>
                  NavigationManager.router.go('/library/userSongs/recents'),
              leading: Icon(HugeIcons.strokeRoundedWorkHistory),
            ),
            ListTile(
              title: Text(context.l10n!.likedSongs),
              onTap: () =>
                  NavigationManager.router.go('/library/userSongs/liked'),
              leading: Icon(HugeIcons.strokeRoundedMusicNote01),
            ),
            ListTile(
              title: Text(context.l10n!.offlineSongs),
              onTap: () =>
                  NavigationManager.router.go('/library/userSongs/offline'),
              leading: Icon(HugeIcons.strokeRoundedWifiError01),
            ),
          ],
        ),
        FutureBuilder<List>(
          future: _userPlaylistsFuture,
          builder: _buildPlaylistsList,
        ),
      ]),
    );
  }

  Widget _buildPlaylistsSection(Color primaryColor, String type) {
    return SliverList(
      delegate: SliverChildListDelegate([
        SectionTitle(
          type == 'playlist' ? context.l10n!.playlists : context.l10n!.albums,
          primaryColor,
        ),
        FutureBuilder<List>(
          future: getPlaylists(
            query: _searchBar.text.isEmpty ? null : _searchBar.text,
            type: type,
          ),
          builder: _buildPlaylistsList,
        ),
      ]),
    );
  }

  Widget _buildUserLikedPlaylistsSection(Color primaryColor) {
    return SliverList(
      delegate: SliverChildListDelegate([
        ValueListenableBuilder(
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
        ),
      ]),
    );
  }

  Widget _buildPlaylistsList(
      BuildContext context,
      AsyncSnapshot<List> snapshot,
      ) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Spinner();
    } else if (snapshot.hasError) {
      return _handleSnapshotError(context, snapshot);
    }

    return _buildPlaylistListView(context, snapshot.data!);
  }

  Widget _handleSnapshotError(
      BuildContext context,
      AsyncSnapshot<List> snapshot,
      ) {
    logger.log(
      'Error while fetching playlists',
      snapshot.error,
      snapshot.stackTrace,
    );
    return Center(child: Text(context.l10n!.error));
  }

  Widget _buildPlaylistListView(BuildContext context, List playlists) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: playlists.length,
      itemBuilder: (BuildContext context, index) {
        final playlist = playlists[index];
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
        );
      },
    );
  }

  Widget _buildFilterChip(int index, String label) {
    return FilterChip(
      selected: _visibleSections[index],
      label: Text(label),
      onSelected: (isSelected) {
        setState(() {
          _visibleSections[index] = isSelected;
        });
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
                          HugeIcons.strokeRoundedGlobalSearch,
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
                          HugeIcons.strokeRoundedPlayListFavourite02,
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
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () async {
                      var response = await addCustomPlaylist(
                        isYouTubeMode,
                        customPlaylistName,
                        imageUrl,
                        id,
                      );
                      if (response != null) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(context.l10n!.addToPlaylist),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );

  Future<String?> addCustomPlaylist(
      bool isYouTubeMode,
      String customPlaylistName,
      String? imageUrl,
      String id,
      ) async {
    if (isYouTubeMode && id.isNotEmpty) {
      return await addUserPlaylist(id, context); // Assuming this method is defined elsewhere
    } else if (!isYouTubeMode && customPlaylistName.isNotEmpty) {
      return await createCustomPlaylist(customPlaylistName, imageUrl, context); // Assuming this method is defined elsewhere
    } else {
      return null;
    }
  }

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

          if (playlist['ytid'] == null &&
              playlist['source'] == 'user-created') {
            removeUserCustomPlaylist(playlist);
          } else {
            removeUserPlaylist(playlist['ytid']);
          }

          _refreshUserPlaylists();
        },
      );
    },
  );
}
