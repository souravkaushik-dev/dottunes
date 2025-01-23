//dotstudios

import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/custom_bar.dart';
import 'package:dottunes/widgets/custom_search_bar.dart';
import 'package:dottunes/widgets/playlist_bar.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:dottunes/widgets/song_bar.dart';
import 'package:hugeicons/hugeicons.dart';



class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

List searchHistory = Hive.box('user').get('searchHistory', defaultValue: []);

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();
  final ValueNotifier<bool> _fetchingSongs = ValueNotifier(false);
  int maxSongsInList = 15;
  List _songsSearchResult = [];
  List _albumsSearchResult = [];
  List _playlistsSearchResult = [];
  List _suggestionsList = [];

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  Future<void> search() async {
    final query = _searchBar.text;

    if (query.isEmpty) {
      _songsSearchResult = [];
      _albumsSearchResult = [];
      _playlistsSearchResult = [];
      _suggestionsList = [];
      setState(() {});
      return;
    }

    if (!_fetchingSongs.value) {
      _fetchingSongs.value = true;
    }

    if (!searchHistory.contains(query)) {
      searchHistory.insert(0, query);
      addOrUpdateData('user', 'searchHistory', searchHistory);
    }

    try {
      _songsSearchResult = await fetchSongsList(query);
      _albumsSearchResult = await getPlaylists(
        query: query,
        type: 'album',
      );
      _playlistsSearchResult = await getPlaylists(
        query: query,
        type: 'playlist',
      );
    } catch (e, stackTrace) {
      logger.log('Error while searching online songs', e, stackTrace);
    }

    if (_fetchingSongs.value) {
      _fetchingSongs.value = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
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
                            'browse',
                            style: TextStyle(
                              fontFamily: 'Nothing',
                              fontSize: isCollapsed ? 24.0 : 42.0, // Adjust font size for collapsed state
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Discover, and Explore Your Sound.',
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
          ),
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CustomSearchBar(
                    loadingProgressNotifier: _fetchingSongs,
                    controller: _searchBar,
                    focusNode: _inputNode,
                    labelText: '${context.l10n!.search}...',
                    onChanged: (value) async {
                      if (value.isNotEmpty) {
                        _suggestionsList = await getSearchSuggestions(value);
                      } else {
                        _suggestionsList = [];
                      }
                      setState(() {});
                    },
                    onSubmitted: (String value) {
                      search();
                      _suggestionsList = [];
                      _inputNode.unfocus();
                    },
                  ),
                  if (_songsSearchResult.isEmpty && _albumsSearchResult.isEmpty)
                    ListView.builder(
                      padding: const EdgeInsets.all(7),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _suggestionsList.isEmpty
                          ? searchHistory.length
                          : _suggestionsList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final suggestionsNotAvailable = _suggestionsList.isEmpty;
                        final query = suggestionsNotAvailable
                            ? searchHistory[index]
                            : _suggestionsList[index];

                        final borderRadius = getItemBorderRadius(
                          index,
                          _suggestionsList.isEmpty
                              ? searchHistory.length
                              : _suggestionsList.length,
                        );

                        return CustomBar(
                          query,
                          HugeIcons.strokeRoundedSearching,
                          borderRadius: borderRadius,
                          onTap: () async {
                            _searchBar.text = query;
                            await search();
                            _inputNode.unfocus();
                          },
                          onLongPress: () async {
                            final confirm =
                                await _showConfirmationDialog(context) ?? false;

                            if (confirm) {
                              setState(() {
                                searchHistory.remove(query);
                              });

                              addOrUpdateData(
                                'user',
                                'searchHistory',
                                searchHistory,
                              );
                            }
                          },
                        );
                      },
                    )
                  else
                    Column(
                      children: [
                        SectionTitle(context.l10n!.songs, primaryColor),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(7),
                          itemCount: _songsSearchResult.length > maxSongsInList
                              ? maxSongsInList
                              : _songsSearchResult.length,
                          itemBuilder: (BuildContext context, int index) {
                            final borderRadius = getItemBorderRadius(
                              index,
                              _songsSearchResult.length > maxSongsInList
                                  ? maxSongsInList
                                  : _songsSearchResult.length,
                            );

                            return SongBar(
                              _songsSearchResult[index],
                              true,
                              showMusicDuration: true,
                              borderRadius: borderRadius,
                            );
                          },
                        ),
                        if (_albumsSearchResult.isNotEmpty)
                          SectionTitle(context.l10n!.albums, primaryColor),
                        if (_albumsSearchResult.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _albumsSearchResult.length > maxSongsInList
                                ? maxSongsInList
                                : _albumsSearchResult.length,
                            itemBuilder: (BuildContext context, int index) {
                              final playlist = _albumsSearchResult[index];

                              final borderRadius = getItemBorderRadius(
                                index,
                                _albumsSearchResult.length > maxSongsInList
                                    ? maxSongsInList
                                    : _albumsSearchResult.length,
                              );

                              return PlaylistBar(
                                key: ValueKey(playlist['ytid']),
                                playlist['title'],
                                playlistId: playlist['ytid'],
                                playlistArtwork: playlist['image'],
                                cubeIcon: HugeIcons.strokeRoundedBurningCd,
                                isAlbum: true,
                                borderRadius: borderRadius,
                              );
                            },
                          ),
                        if (_playlistsSearchResult.isNotEmpty)
                          SectionTitle(context.l10n!.playlists, primaryColor),
                        if (_playlistsSearchResult.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: commonListViewBottmomPadding,
                            itemCount: _playlistsSearchResult.length > maxSongsInList
                                ? maxSongsInList
                                : _playlistsSearchResult.length,
                            itemBuilder: (BuildContext context, int index) {
                              final playlist = _playlistsSearchResult[index];
                              return PlaylistBar(
                                key: ValueKey(playlist['ytid']),
                                playlist['title'],
                                playlistId: playlist['ytid'],
                                playlistArtwork: playlist['image'],
                                cubeIcon: HugeIcons.strokeRoundedMenu08,
                              );
                            },
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return ConfirmationDialog(
          confirmationMessage: context.l10n!.removeSearchQueryQuestion,
          submitMessage: context.l10n!.confirm,
          onCancel: () {
            Navigator.of(context).pop(false);
          },
          onSubmit: () {
            Navigator.of(context).pop(true);
          },
        );
      },
    );
  }
}
