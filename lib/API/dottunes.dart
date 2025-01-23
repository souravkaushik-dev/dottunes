//dotstudios

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:dottunes/DB/albums.db.dart';
import 'package:dottunes/DB/playlists.db.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/data_manager.dart';
import 'package:dottunes/services/lyrics_manager.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/flutter_toast.dart';
import 'package:dottunes/utilities/formatter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

final _yt = YoutubeExplode();

List globalSongs = [];

List playlists = [...playlistsDB, ...albumsDB];
List userPlaylists = Hive.box('user').get('playlists', defaultValue: []);
List userCustomPlaylists =
Hive.box('user').get('customPlaylists', defaultValue: []);
List userLikedSongsList = Hive.box('user').get('likedSongs', defaultValue: []);
List userLikedPlaylists =
Hive.box('user').get('likedPlaylists', defaultValue: []);
List userRecentlyPlayed =
Hive.box('user').get('recentlyPlayedSongs', defaultValue: []);
List userOfflineSongs =
Hive.box('userNoBackup').get('offlineSongs', defaultValue: []);
List suggestedPlaylists = [];
List onlinePlaylists = [];
Map activePlaylist = {
  'ytid': '',
  'title': 'No Playlist',
  'image': '',
  'source': 'user-created',
  'list': [],
};

List<YoutubeApiClient> userChosenClients = [
  YoutubeApiClient.tv,
  YoutubeApiClient.androidVr,
  YoutubeApiClient.safari,
];

dynamic nextRecommendedSong;

final currentLikedSongsLength = ValueNotifier<int>(userLikedSongsList.length);
final currentLikedPlaylistsLength =
ValueNotifier<int>(userLikedPlaylists.length);
final currentOfflineSongsLength = ValueNotifier<int>(userOfflineSongs.length);
final currentRecentlyPlayedLength =
ValueNotifier<int>(userRecentlyPlayed.length);

final lyrics = ValueNotifier<String?>(null);
String? lastFetchedLyrics;

int activeSongId = 0;

Future<List> fetchSongsList(String searchQuery) async {
  try {
    final List<Video> searchResults = await _yt.search.search(searchQuery);

    return searchResults.map((video) => returnSongLayout(0, video)).toList();
  } catch (e, stackTrace) {
    logger.log('Error in fetchSongsList', e, stackTrace);
    return [];
  }
}

Future<List> getRecommendedSongs() async {
  try {
    if (defaultRecommendations.value && userRecentlyPlayed.isNotEmpty) {
      final playlistSongs = [];
      for (var i = 0; i < 3; i++) {
        final song = await _yt.videos.get(userRecentlyPlayed[i]['ytid']);
        final relatedSongs = await _yt.videos.getRelatedVideos(song) ?? [];
        playlistSongs
            .addAll(relatedSongs.take(3).map((s) => returnSongLayout(0, s)));
      }
      playlistSongs.shuffle();
      return playlistSongs;
    } else {
      final playlistSongs = [...userLikedSongsList, ...userRecentlyPlayed];

      if (globalSongs.isEmpty) {
        const playlistId = 'PLgzTt0k8mXzEk586ze4BjvDXR7c-TUSnx';
        globalSongs = await getSongsFromPlaylist(playlistId);
      }

      playlistSongs.addAll(globalSongs.take(10));

      if (userCustomPlaylists.isNotEmpty) {
        for (final userPlaylist in userCustomPlaylists) {
          final _list = (userPlaylist['list'] as List)..shuffle();
          playlistSongs.addAll(_list.take(5));
        }
      }

      playlistSongs.shuffle();

      final seenYtIds = <String>{};
      playlistSongs.removeWhere((song) => !seenYtIds.add(song['ytid']));

      return playlistSongs.take(15).toList();
    }
  } catch (e, stackTrace) {
    logger.log('Error in getRecommendedSongs', e, stackTrace);
    return [];
  }
}

Future<List<dynamic>> getUserPlaylists() async {
  final playlistsByUser = [...userCustomPlaylists];
  for (final playlistID in userPlaylists) {
    try {
      final plist = await _yt.playlists.get(playlistID);
      playlistsByUser.add({
        'ytid': plist.id.toString(),
        'title': plist.title,
        'image': null,
        'source': 'user-youtube',
        'list': [],
      });
    } catch (e, stackTrace) {
      playlistsByUser.add({
        'ytid': playlistID.toString(),
        'title': 'Failed playlist',
        'image': null,
        'source': 'user-youtube',
        'list': [],
      });
      logger.log(
        'Error occurred while fetching the playlist:',
        e,
        stackTrace,
      );
    }
  }
  return playlistsByUser;
}

bool youtubeValidate(String url) {
  final regExp = RegExp(
    r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/.*(list=([a-zA-Z0-9_-]+)).*$',
  );
  return regExp.hasMatch(url);
}

String? youtubePlaylistParser(String url) {
  if (!youtubeValidate(url)) {
    return null;
  }

  final regExp = RegExp('[&?]list=([a-zA-Z0-9_-]+)');
  final match = regExp.firstMatch(url);

  return match?.group(1);
}

Future<String> addUserPlaylist(String input, BuildContext context) async {
  String? playlistId = input;

  if (input.startsWith('http://') || input.startsWith('https://')) {
    playlistId = youtubePlaylistParser(input);

    if (playlistId == null) {
      return '${context.l10n!.notYTlist}!';
    }
  }

  try {
    final _playlist = await _yt.playlists.get(playlistId);

    if (userPlaylists.contains(playlistId)) {
      return '${context.l10n!.playlistAlreadyExists}!';
    }

    if (_playlist.title.isEmpty &&
        _playlist.author.isEmpty &&
        _playlist.videoCount == null) {
      return '${context.l10n!.invalidYouTubePlaylist}!';
    }

    userPlaylists.add(playlistId);
    addOrUpdateData('user', 'playlists', userPlaylists);
    return '${context.l10n!.addedSuccess}!';
  } catch (e) {
    return '${context.l10n!.error}: $e';
  }
}

String createCustomPlaylist(
    String playlistName,
    String? image,
    BuildContext context,
    ) {
  final customPlaylist = {
    'title': playlistName,
    'source': 'user-created',
    if (image != null) 'image': image,
    'list': [],
  };
  userCustomPlaylists.add(customPlaylist);
  addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
  return '${context.l10n!.addedSuccess}!';
}

String addSongInCustomPlaylist(
    BuildContext context,
    String playlistName,
    Map song, {
      int? indexToInsert,
    }) {
  final customPlaylist = userCustomPlaylists.firstWhere(
        (playlist) => playlist['title'] == playlistName,
    orElse: () => null,
  );

  if (customPlaylist != null) {
    final List<dynamic> playlistSongs = customPlaylist['list'];
    if (playlistSongs
        .any((playlistElement) => playlistElement['ytid'] == song['ytid'])) {
      return context.l10n!.songAlreadyInPlaylist;
    }
    indexToInsert != null
        ? playlistSongs.insert(indexToInsert, song)
        : playlistSongs.add(song);
    addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
    return context.l10n!.songAdded;
  } else {
    logger.log('Custom playlist not found: $playlistName', null, null);
    return context.l10n!.error;
  }
}

bool removeSongFromPlaylist(
    Map playlist,
    Map songToRemove, {
      int? removeOneAtIndex,
    }) {
  try {
    if (playlist['list'] == null) return false;

    final playlistSongs = List<dynamic>.from(playlist['list']);
    if (removeOneAtIndex != null) {
      if (removeOneAtIndex < 0 || removeOneAtIndex >= playlistSongs.length) {
        return false;
      }
      playlistSongs.removeAt(removeOneAtIndex);
    } else {
      final initialLength = playlistSongs.length;
      playlistSongs.removeWhere((song) => song['ytid'] == songToRemove['ytid']);
      if (playlistSongs.length == initialLength) return false;
    }

    playlist['list'] = playlistSongs;

    if (playlist['source'] == 'user-created') {
      addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
    } else {
      addOrUpdateData('user', 'playlists', userPlaylists);
    }

    return true;
  } catch (e, stackTrace) {
    logger.log('Error while removing song from playlist: ', e, stackTrace);
    return false;
  }
}

void removeUserPlaylist(String playlistId) {
  userPlaylists.remove(playlistId);
  addOrUpdateData('user', 'playlists', userPlaylists);
}

void removeUserCustomPlaylist(dynamic playlist) {
  userCustomPlaylists.remove(playlist);
  addOrUpdateData('user', 'customPlaylists', userCustomPlaylists);
}

Future<void> updateSongLikeStatus(dynamic songId, bool add) async {
  if (add) {
    userLikedSongsList
        .add(await getSongDetails(userLikedSongsList.length, songId));
  } else {
    userLikedSongsList.removeWhere((song) => song['ytid'] == songId);
  }
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

void moveLikedSong(int oldIndex, int newIndex) {
  final _song = userLikedSongsList[oldIndex];
  userLikedSongsList
    ..removeAt(oldIndex)
    ..insert(newIndex, _song);
  currentLikedSongsLength.value = userLikedSongsList.length;
  addOrUpdateData('user', 'likedSongs', userLikedSongsList);
}

Future<void> updatePlaylistLikeStatus(
    String playlistId,
    bool add,
    ) async {
  try {
    if (add) {
      final playlist = playlists.firstWhere(
            (playlist) => playlist['ytid'] == playlistId,
        orElse: () => {},
      );

      if (playlist.isNotEmpty) {
        userLikedPlaylists.add(playlist);
      } else {
        userLikedPlaylists.add(await getPlaylistInfoForWidget(playlistId));
      }
    } else {
      userLikedPlaylists
          .removeWhere((playlist) => playlist['ytid'] == playlistId);
    }

    addOrUpdateData('user', 'likedPlaylists', userLikedPlaylists);
  } catch (e, stackTrace) {
    logger.log('Error updating playlist like status: ', e, stackTrace);
  }
}

bool isSongAlreadyLiked(songIdToCheck) =>
    userLikedSongsList.any((song) => song['ytid'] == songIdToCheck);

bool isPlaylistAlreadyLiked(playlistIdToCheck) =>
    userLikedPlaylists.any((playlist) => playlist['ytid'] == playlistIdToCheck);

bool isSongAlreadyOffline(songIdToCheck) =>
    userOfflineSongs.any((song) => song['ytid'] == songIdToCheck);

Future<List> getPlaylists({
  String? query,
  int? playlistsNum,
  bool onlyLiked = false,
  String type = 'all',
}) async {
  // Early exit if playlists or suggestedPlaylists is empty
  if (playlists.isEmpty ||
      (playlistsNum == null && query == null && suggestedPlaylists.isEmpty)) {
    return [];
  }

  // Filter playlists based on query and type if only query is specified
  if (query != null && playlistsNum == null) {
    final lowercaseQuery = query.toLowerCase();
    final filteredPlaylists = playlists.where((playlist) {
      final lowercaseTitle = playlist['title'].toLowerCase();
      return lowercaseTitle.contains(lowercaseQuery) &&
          ((type == 'all') ||
              (type == 'album' && playlist['isAlbum'] == true) ||
              (type == 'playlist' && playlist['isAlbum'] != true));
    }).toList();

    final searchResults = await _yt.search.searchContent(
      type == 'album' ? '$query album' : query,
      filter: TypeFilters.playlist,
    );

    final existingYtid =
    onlinePlaylists.map((playlist) => playlist['ytid'] as String).toSet();

    final newPlaylists = searchResults
        .whereType<SearchPlaylist>()
        .map((playlist) {
      final playlistMap = {
        'ytid': playlist.id.toString(),
        'title': playlist.title,
        'source': 'youtube',
        'list': [],
      };

      if (!existingYtid.contains(playlistMap['ytid'])) {
        existingYtid.add(playlistMap['ytid'].toString());
        return playlistMap;
      }
      return null;
    })
        .whereType<Map<String, dynamic>>()
        .toList();

    onlinePlaylists.addAll(newPlaylists);
    filteredPlaylists.addAll(
      onlinePlaylists.where(
            (playlist) => playlist['title'].toLowerCase().contains(lowercaseQuery),
      ),
    );

    return filteredPlaylists;
  }

  // Return a subset of suggested playlists if playlistsNum is specified without a query
  if (playlistsNum != null && query == null) {
    if (suggestedPlaylists.isEmpty) {
      suggestedPlaylists = playlists.toList()..shuffle();
    }
    return suggestedPlaylists.take(playlistsNum).toList();
  }

  // Return userLikedPlaylists if onlyLiked flag is set and no query or playlistsNum is specified
  if (onlyLiked && playlistsNum == null && query == null) {
    return userLikedPlaylists;
  }

  // Filter playlists by type
  if (type != 'all') {
    return playlists
        .where(
          (playlist) =>
      (type == 'album' && playlist['isAlbum'] == true) ||
          (type == 'playlist' && playlist['isAlbum'] != true),
    )
        .toList();
  }

  // Return playlists directly if type is 'all'
  return playlists;
}

Future<List<String>> getSearchSuggestions(String query) async {
  // Custom implementation:

  // const baseUrl = 'https://suggestqueries.google.com/complete/search';
  // final parameters = {
  //   'client': 'firefox',
  //   'ds': 'yt',
  //   'q': query,
  // };

  // final uri = Uri.parse(baseUrl).replace(queryParameters: parameters);

  // try {
  //   final response = await http.get(
  //     uri,
  //     headers: {
  //       'User-Agent':
  //           'Mozilla/5.0 (Windows NT 10.0; rv:96.0) Gecko/20100101 Firefox/96.0',
  //     },
  //   );

  //   if (response.statusCode == 200) {
  //     final suggestions = jsonDecode(response.body)[1] as List<dynamic>;
  //     final suggestionStrings = suggestions.cast<String>().toList();
  //     return suggestionStrings;
  //   }
  // } catch (e, stackTrace) {
  //   logger.log('Error in getSearchSuggestions:$e\n$stackTrace');
  // }

  // Built-in implementation:

  final suggestions = await _yt.search.getQuerySuggestions(query);

  return suggestions;
}

Future<List<Map<String, int>>> getSkipSegments(String id) async {
  try {
    final res = await http.get(
      Uri(
        scheme: 'https',
        host: 'sponsor.ajay.app',
        path: '/api/skipSegments',
        queryParameters: {
          'videoID': id,
          'category': [
            'sponsor',
            'selfpromo',
            'interaction',
            'intro',
            'outro',
            'music_offtopic',
          ],
          'actionType': 'skip',
        },
      ),
    );
    if (res.body != 'Not Found') {
      final data = jsonDecode(res.body);
      final segments = data.map((obj) {
        return Map.castFrom<String, dynamic, String, int>({
          'start': obj['segment'].first.toInt(),
          'end': obj['segment'].last.toInt(),
        });
      }).toList();
      return List.castFrom<dynamic, Map<String, int>>(segments);
    } else {
      return [];
    }
  } catch (e, stack) {
    logger.log('Error in getSkipSegments', e, stack);
    return [];
  }
}

void getSimilarSong(String songYtId) async {
  try {
    final song = await _yt.videos.get(songYtId);
    final relatedSongs = await _yt.videos.getRelatedVideos(song) ?? [];

    if (relatedSongs.isNotEmpty) {
      nextRecommendedSong = returnSongLayout(0, relatedSongs[0]);
    }
  } catch (e, stackTrace) {
    logger.log('Error while fetching next similar song:', e, stackTrace);
  }
}

Future<List> getSongsFromPlaylist(dynamic playlistId) async {
  final songList = await getData('cache', 'playlistSongs$playlistId') ?? [];

  if (songList.isEmpty) {
    await for (final song in _yt.playlists.getVideos(playlistId)) {
      songList.add(returnSongLayout(songList.length, song));
    }

    addOrUpdateData('cache', 'playlistSongs$playlistId', songList);
  }

  return songList;
}

Future updatePlaylistList(
    BuildContext context,
    String playlistId,
    ) async {
  final index = findPlaylistIndexByYtId(playlistId);
  if (index != -1) {
    final songList = [];
    await for (final song in _yt.playlists.getVideos(playlistId)) {
      songList.add(returnSongLayout(songList.length, song));
    }

    playlists[index]['list'] = songList;
    addOrUpdateData('cache', 'playlistSongs$playlistId', songList);
    showToast(context, context.l10n!.playlistUpdated);
  }
  return playlists[index];
}

int findPlaylistIndexByYtId(String ytid) {
  return playlists.indexWhere((playlist) => playlist['ytid'] == ytid);
}

Future<void> setActivePlaylist(Map info) async {
  activePlaylist = info;
  activeSongId = 0;

  await audioHandler.playSong(activePlaylist['list'][activeSongId]);
}

Future<Map?> getPlaylistInfoForWidget(
    dynamic id, {
      bool isArtist = false,
    }) async {
  if (!isArtist) {
    Map? playlist =
    playlists.firstWhere((list) => list['ytid'] == id, orElse: () => null);

    if (playlist == null) {
      final usPlaylists = await getUserPlaylists();
      playlist = usPlaylists.firstWhere(
            (list) => list['ytid'] == id,
        orElse: () => null,
      );
    }

    playlist ??= onlinePlaylists.firstWhere(
          (list) => list['ytid'] == id,
      orElse: () => null,
    );

    if (playlist != null && playlist['list'].isEmpty) {
      playlist['list'] = await getSongsFromPlaylist(playlist['ytid']);
      if (!playlists.contains(playlist)) {
        playlists.add(playlist);
      }
    }

    return playlist;
  } else {
    final playlist = <String, dynamic>{
      'title': id,
    };

    playlist['list'] = await fetchSongsList(id);

    return playlist;
  }
}

final clients = {
 // 'tv': YoutubeApiClient.tv,
 // 'androidVr': YoutubeApiClient.androidVr,
 // 'safari': YoutubeApiClient.safari,
 // 'ios': YoutubeApiClient.ios,
  'android': YoutubeApiClient.android,
  'androidMusic': YoutubeApiClient.androidMusic,
  'mediaConnect': YoutubeApiClient.mediaConnect,
 // 'web': YoutubeApiClient.mweb,
};

Future<AudioOnlyStreamInfo> getSongManifest(String songId) async {
  try {
    final manifest = await _yt.videos.streams.getManifest(
      songId,
      ytClients: userChosenClients,
    );
    final audioStream = manifest.audioOnly.withHighestBitrate();
    return audioStream;
  } catch (e, stackTrace) {
    logger.log('Error while getting song streaming manifest', e, stackTrace);
    rethrow; // Rethrow the exception to allow the caller to handle it
  }
}

const Duration _cacheDuration = Duration(hours: 3);

Future<String> getSong(String songId, bool isLive) async {
  try {
    final qualitySetting = audioQualitySetting.value;
    final cacheKey = 'song_${songId}_${qualitySetting}_url';

    final cachedUrl = await getData(
      'cache',
      cacheKey,
      cachingDuration: _cacheDuration,
    );

    unawaited(updateRecentlyPlayed(songId));

    if (playNextSongAutomatically.value) {
      getSimilarSong(songId);
    }

    if (cachedUrl != null) {
      return cachedUrl;
    }

    if (isLive) {
      return await getLiveStreamUrl(songId);
    }

    return await getAudioUrl(songId, cacheKey);
  } catch (e, stackTrace) {
    logger.log('Error while getting song streaming URL', e, stackTrace);
    rethrow;
  }
}

Future<String> getLiveStreamUrl(String songId) async {
  final streamInfo =
  await _yt.videos.streamsClient.getHttpLiveStreamUrl(VideoId(songId));
  return streamInfo;
}

Future<String> getAudioUrl(
    String songId,
    String cacheKey,
    ) async {
  final manifest = await _yt.videos.streamsClient.getManifest(songId);
  final audioQuality = selectAudioQuality(manifest.audioOnly.sortByBitrate());
  final audioUrl = audioQuality.url.toString();

  addOrUpdateData('cache', cacheKey, audioUrl);
  return audioUrl;
}

AudioStreamInfo selectAudioQuality(List<AudioStreamInfo> availableSources) {
  final qualitySetting = audioQualitySetting.value;

  if (qualitySetting == 'low') {
    return availableSources.last;
  } else if (qualitySetting == 'medium') {
    return availableSources[availableSources.length ~/ 2];
  } else if (qualitySetting == 'high') {
    return availableSources.first;
  } else {
    return availableSources.withHighestBitrate();
  }
}

Future<Map<String, dynamic>> getSongDetails(
    int songIndex,
    String songId,
    ) async {
  try {
    final song = await _yt.videos.get(songId);
    return returnSongLayout(songIndex, song);
  } catch (e, stackTrace) {
    logger.log('Error while getting song details', e, stackTrace);
    rethrow;
  }
}

Future<String?> getSongLyrics(String artist, String title) async {
  if (lastFetchedLyrics != '$artist - $title') {
    lyrics.value = null;
    final _lyrics = await LyricsManager().fetchLyrics(artist, title);
    if (_lyrics != null) {
      lyrics.value = _lyrics;
    } else {
      lyrics.value = 'not found';
    }

    lastFetchedLyrics = '$artist - $title';
    return _lyrics;
  }

  return lyrics.value;
}

void makeSongOffline(dynamic song) async {
  final _dir = await getApplicationSupportDirectory();
  final _audioDirPath = '${_dir.path}/tracks';
  final _artworkDirPath = '${_dir.path}/artworks';
  final String ytid = song['ytid'];
  final _audioFile = File('$_audioDirPath/$ytid.m4a');
  final _artworkFile = File('$_artworkDirPath/$ytid.jpg');

  await Directory(_audioDirPath).create(recursive: true);
  await Directory(_artworkDirPath).create(recursive: true);

  final audioManifest = await getSongManifest(ytid);
  final stream = _yt.videos.streamsClient.get(audioManifest);
  final fileStream = _audioFile.openWrite();
  await stream.pipe(fileStream);
  await fileStream.flush();
  await fileStream.close();

  final artworkFile = await _downloadAndSaveArtworkFile(
    song['highResImage'],
    _artworkFile.path,
  );

  if (artworkFile != null) {
    song['artworkPath'] = artworkFile.path;
    song['highResImage'] = artworkFile.path;
    song['lowResImage'] = artworkFile.path;
  }
  song['audioPath'] = _audioFile.path;
  userOfflineSongs.add(song);
  addOrUpdateData('userNoBackup', 'offlineSongs', userOfflineSongs);
}

void removeSongFromOffline(dynamic songId) async {
  final _dir = await getApplicationSupportDirectory();
  final _audioDirPath = '${_dir.path}/tracks';
  final _artworkDirPath = '${_dir.path}/artworks';
  final _audioFile = File('$_audioDirPath/$songId.m4a');
  final _artworkFile = File('$_artworkDirPath/$songId.jpg');

  if (await _audioFile.exists()) await _audioFile.delete();
  if (await _artworkFile.exists()) await _artworkFile.delete();

  userOfflineSongs.removeWhere((song) => song['ytid'] == songId);
  addOrUpdateData('userNoBackup', 'offlineSongs', userOfflineSongs);
  currentOfflineSongsLength.value = userOfflineSongs.length;
}

Future<File?> _downloadAndSaveArtworkFile(String url, String filePath) async {
  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } else {
      logger.log(
        'Failed to download file. Status code: ${response.statusCode}',
        null,
        null,
      );
    }
  } catch (e, stackTrace) {
    logger.log('Error downloading and saving file', e, stackTrace);
  }

  return null;
}

const recentlyPlayedSongsLimit = 50;

Future<void> updateRecentlyPlayed(dynamic songId) async {
  if (userRecentlyPlayed.length == 1 && userRecentlyPlayed[0]['ytid'] == songId)
    return;
  if (userRecentlyPlayed.length >= recentlyPlayedSongsLimit) {
    userRecentlyPlayed.removeLast();
  }

  userRecentlyPlayed.removeWhere((song) => song['ytid'] == songId);
  currentRecentlyPlayedLength.value = userRecentlyPlayed.length;

  final newSongDetails =
  await getSongDetails(userRecentlyPlayed.length, songId);

  userRecentlyPlayed.insert(0, newSongDetails);
  currentRecentlyPlayedLength.value = userRecentlyPlayed.length;
  addOrUpdateData('user', 'recentlyPlayedSongs', userRecentlyPlayed);
}