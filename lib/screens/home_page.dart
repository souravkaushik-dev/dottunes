//dotstudios

import 'dart:ui';

import 'package:dottunes/screens/library_page.dart';
import 'package:dottunes/services/router_service.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/playlist_page.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:dottunes/utilities/utils.dart';
import 'package:dottunes/widgets/announcement_box.dart';
import 'package:dottunes/widgets/playlist_cube.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:dottunes/widgets/song_bar.dart';
import 'package:dottunes/widgets/spinner.dart';
import 'package:hugeicons/hugeicons.dart';



class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Step 1: Add a Drawer to the Scaffold
     /*   drawer: Drawer(
        // Step 2: Add a Material 3 Drawer
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,

              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 30.0,
                    backgroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: Icon(
                      HugeIcons.strokeRoundedMusicNote01,
                      size: 30.0,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'dottunes',
                    style: TextStyle(
                      fontFamily: 'Nothing',
                      fontSize: 24.0,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    'Tunes that Connect.',
                    style: TextStyle(
                      fontFamily: 'Nothing',
                      fontSize: 14.0,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            // Step 3: Add navigation options using ListTiles
            ListTile(
              leading: Icon(HugeIcons.strokeRoundedWifiDisconnected04),
              title: Text('Offline'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                // Navigate to Playlist Page
                NavigationManager.router.go('/library/userSongs/offline');
              },
            ),
            ListTile(
              leading: Icon(HugeIcons.strokeRoundedMusicNote01),
              title: Text('Songs'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Songs Page
                // Add navigation logic here
              },
            ),
            ListTile(
              leading: Icon(HugeIcons.strokeRoundedUser),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Profile Page
                // Add navigation logic here
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(HugeIcons.strokeRoundedSetting06),
              title: Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to Settings Page
                // Add navigation logic here
              },
            ),
          ],
        ),
      ), */
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
                top: isCollapsed ? 0.0 : 80.0,
                left: 16.0,
              ),
              title: Align(
                alignment: isCollapsed ? Alignment.centerLeft : Alignment.center,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: isCollapsed ? CrossAxisAlignment.start : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'dottunes',
                        style: TextStyle(
                          fontFamily: 'Nothing',
                          fontSize: isCollapsed ? 24.0 : 42.0,
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
              background: Stack(
                children: [
                  // Only show the glassmorphism effect when the SliverAppBar is collapsed
                  if (isCollapsed)
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0), // Frosted glass effect
                        child: Container(
                          color: Colors.white.withOpacity(0.1), // Semi-transparent overlay
                        ),
                      ),
                    ),
                  // Transparent background when not collapsed
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(roundedCorner),
                      ),
                      color: Colors.transparent, // Ensures the background remains transparent
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
      )
      ,
          SliverList(
            delegate: SliverChildListDelegate(
              [
                ValueListenableBuilder<String?>(
                  valueListenable: announcementURL,
                  builder: (_, _url, __) {
                    if (_url == null) return const SizedBox.shrink();
                    return AnnouncementBox(
                      message: context.l10n!.newAnnouncement,
                      backgroundColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                      textColor:
                      Theme.of(context).colorScheme.onSecondaryContainer,
                      url: _url,
                    );
                  },
                ),
                _buildSuggestedPlaylists(),
                _buildRecommendedSongsAndArtists(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPlaylists() {
    return FutureBuilder<List<dynamic>>(
      future: getPlaylists(playlistsNum: recommendedCubesNumber),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget();
        } else if (snapshot.hasError) {
          logger.log(
            'Error in _buildSuggestedPlaylists',
            snapshot.error,
            snapshot.stackTrace,
          );
          return _buildErrorWidget(context);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        return _buildPlaylistSection(context, snapshot.data!);
      },
    );
  }


  Widget _buildPlaylistSection(BuildContext context, List<dynamic> playlists) {
    final playlistHeight = MediaQuery.sizeOf(context).height * 0.25 / 1.1;

    final itemsNumber = playlists.length > recommendedCubesNumber
        ? recommendedCubesNumber
        : playlists.length;

    return Column(
      children: [
        _buildSectionHeader(
          title: Text(
            context.l10n!.suggestedPlaylists,  // Pass the localized string wrapped in a Text widget
            style: TextStyle(
              fontFamily: 'Nothing',  // Replace with your custom font family
              fontSize: 24, // Adjust the font size as needed
              fontWeight: FontWeight.bold, // Optional: Customize font weight
            ),
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: playlistHeight),
          child: CarouselView.weighted(
            flexWeights: const <int>[3, 2, 1],
            onTap: (index) => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaylistPage(
                  playlistId: playlists[index]['ytid'],
                ),
              ),
            ),
            children: List.generate(itemsNumber, (index) {
              final playlist = playlists[index];
              return PlaylistCube(
                playlist,
                size: playlistHeight,
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedSongsAndArtists() {
    return ValueListenableBuilder<bool>(
      valueListenable: defaultRecommendations,
      builder: (_, recommendations, __) {
        return FutureBuilder<dynamic>(
          future: getRecommendedSongs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingWidget();
            } else if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                logger.log(
                  'Error in _buildRecommendedSongsAndArtists',
                  snapshot.error,
                  snapshot.stackTrace,
                );
                return _buildErrorWidget(context);
              } else if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              return _buildRecommendedContent(
                context: context,
                data: snapshot.data,
                showArtists: !recommendations,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Spinner(),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        '${context.l10n!.error}!',
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }

  Widget _buildRecommendedContent({
    required BuildContext context,
    required List<dynamic> data,
    bool showArtists = true,
  }) {
    final contentHeight = MediaQuery.sizeOf(context).height * 0.25;

    final itemsNumber = data.length > recommendedCubesNumber
        ? recommendedCubesNumber
        : data.length;

    return Column(
      children: [
        if (showArtists)
          _buildSectionHeader(
            title: Text(
              'dottunes fav', // Renamed Suggested Artists to dOTUNES Fav
              style: TextStyle(
                fontFamily: 'Nothing', // Replace with your custom font family
                fontSize: 24, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Optional: Customize font weight
              ),
            ),
          ),
        if (showArtists)
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: contentHeight),
            child: CarouselView.weighted(
              flexWeights: const <int>[3, 2, 1],
              onTap: (index) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistPage(
                    cubeIcon: HugeIcons.strokeRoundedAudioBook04,
                    playlistId: data[index]['artist'].split('~')[0],
                    isArtist: true,
                  ),
                ),
              ),
              children: List.generate(itemsNumber, (index) {
                final artist = data[index]['artist'].split('~')[0];
                return PlaylistCube(
                  {'title': artist},
                  cubeIcon: HugeIcons.strokeRoundedAudioBook04,
                );
              }),
            ),
          ),
        _buildSectionHeader(
          title: Text(
            'Discover More', // Renamed Suggested Playlists to DISCOVER MORE
            style: TextStyle(
              fontFamily: 'Nothing', // Replace with your custom font family
              fontSize: 24, // Font size for the title
              fontWeight: FontWeight.bold, // Optional: Customize font weight
            ),
          ),
          actionButton: IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: () {
              setActivePlaylist({
                'title': 'DISCOVER MORE', // Updated title
                'list': data,
              });
            },
            icon: Icon(
              HugeIcons.strokeRoundedUnfoldMore,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          padding: commonListViewBottmomPadding,
          itemBuilder: (context, index) {
            final borderRadius = getItemBorderRadius(index, data.length);
            return SongBar(
              data[index],
              true,
              borderRadius: borderRadius,
            );
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required Text title, // Change this to Text widget
    Widget? actionButton,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          title, // Use the Text widget here
          if (actionButton != null) actionButton,
        ],
      ),
    );
  }
}
