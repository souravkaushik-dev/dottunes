import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/widgets/confirmation_dialog.dart';
import 'package:dottunes/widgets/custom_bar.dart';
import 'package:dottunes/widgets/custom_search_bar.dart';
import 'package:dottunes/widgets/song_bar.dart';

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
  List _searchResult = [];
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
      _searchResult = [];
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
      _searchResult = await fetchSongsList(query);
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
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
        SliverAppBar(
        expandedHeight: 200,
        flexibleSpace: FlexibleSpaceBar(
          title: Text('Search', style: TextStyle(
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
          SliverList(
            delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                return SingleChildScrollView(
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
                      if (_searchResult.isEmpty)
                        ListView.builder(
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

                            return CustomBar(
                              query,
                              HugeIcons.strokeRoundedAdobeIllustrator,
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _searchResult.length,
                          itemBuilder: (BuildContext context, int index) {
                            return SongBar(
                              _searchResult[index],
                              true,
                              showMusicDuration: true,
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
              childCount: 1,
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
