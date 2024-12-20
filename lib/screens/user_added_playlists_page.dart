import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/playlist_page.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/playlist_cube.dart';
import 'package:dottunes/widgets/spinner.dart';

class UserPlaylistsPage extends StatefulWidget {
  const UserPlaylistsPage({super.key});

  @override
  State<UserPlaylistsPage> createState() => _UserPlaylistsPageState();
}

class _UserPlaylistsPageState extends State<UserPlaylistsPage> {
  late Future<List> _playlistsFuture;

  @override
  void initState() {
    super.initState();
    _playlistsFuture = getUserPlaylists();
  }

  Future<void> _refreshPlaylists() async {
    setState(() {
      _playlistsFuture = getUserPlaylists();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              var id = '';
              var customPlaylistName = '';
              String? imageUrl;
              bool? isYouTubeMode;

              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    content: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          if (isYouTubeMode == true || isYouTubeMode == null)
                            TextField(
                              decoration: InputDecoration(
                                labelText: context.l10n!.youtubePlaylistID,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  id = value;
                                  if (id.isNotEmpty) {
                                    customPlaylistName = '';
                                    imageUrl = null;
                                    isYouTubeMode = true;
                                  } else {
                                    isYouTubeMode = null;
                                  }
                                });
                              },
                            ),
                          const SizedBox(height: 7),
                          if (isYouTubeMode == false || isYouTubeMode == null) ...[
                            TextField(
                              decoration: InputDecoration(
                                labelText: context.l10n!.customPlaylistName,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  customPlaylistName = value;
                                  if (customPlaylistName.isNotEmpty) {
                                    id = '';
                                    isYouTubeMode = false;
                                  } else {
                                    isYouTubeMode = null;
                                  }
                                });
                              },
                            ),
                            const SizedBox(height: 7),
                            TextField(
                              decoration: InputDecoration(
                                labelText: context.l10n!.customPlaylistImgUrl,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  imageUrl = value;
                                  if (imageUrl!.isNotEmpty) {
                                    id = '';
                                    isYouTubeMode = false;
                                  } else {
                                    isYouTubeMode = null;
                                  }
                                });
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
                          if (id.isNotEmpty) {
                            showToast(
                              context,
                              await addUserPlaylist(id, context),
                            );
                          } else if (customPlaylistName.isNotEmpty) {
                            showToast(
                              context,
                              createCustomPlaylist(
                                customPlaylistName,
                                imageUrl,
                                context,
                              ),
                            );
                          } else {
                            showToast(
                              context,
                              '${context.l10n!.provideIdOrNameError}.',
                            );
                          }

                          Navigator.pop(context);
                          await _refreshPlaylists();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
        child: const Icon(HugeIcons.strokeRoundedAdd02),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar(
            pinned: true,
            expandedHeight: 150.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                context.l10n!.userPlaylists,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'paytoneOne',
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<List>(
              future: _playlistsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Spinner();
                } else if (snapshot.hasError) {
                  logger.log(
                    'Error on user playlists page',
                    snapshot.error,
                    snapshot.stackTrace,
                  );
                  return Center(
                    child: Text(context.l10n!.error),
                  );
                }

                final _playlists = snapshot.data!;

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _playlists.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (BuildContext context, index) {
                    final playlist = _playlists[index];
                    final ytid = playlist['ytid'];

                    return GestureDetector(
                      onTap: playlist['isCustom'] ?? false
                          ? () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaylistPage(playlistData: playlist),
                          ),
                        );
                        if (result == false) {
                          setState(() {});
                        }
                      }
                          : null,
                      onLongPress: () {
                        showDialog(
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

                                if (ytid == null && playlist['isCustom']) {
                                  removeUserCustomPlaylist(playlist);
                                } else {
                                  removeUserPlaylist(ytid);
                                }

                                _refreshPlaylists();
                              },
                            );
                          },
                        );
                      },
                      child: PlaylistCube(
                        playlist,
                        playlistData: playlist['isCustom'] ?? false ? playlist : null,
                        onClickOpen: playlist['isCustom'] == null,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

extension on AppLocalizations {
  get youtubePlaylistID => null;
}
