import 'dart:developer';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:m3_carousel/m3_carousel.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/playlist_page.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/widgets/playlist_cube.dart';
import 'package:dottunes/widgets/section_title.dart';
import 'package:dottunes/widgets/song_bar.dart';
import 'package:dottunes/widgets/spinner.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,  // Remove back button
            title: null, // Remove default title
            expandedHeight: 150.0,  // Set the height for the app bar
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: ClipPath(
                clipper: AppBarClipper(), // Apply the custom clip here
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, top: 50),  // Adjust padding to provide space
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'dottunes',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontFamily: 'Nothing',  // Apply custom font here
                          ),
                        ),
                        SizedBox(height: 8),  // Add space between the texts
                        Text(
                          'listen to your fav',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                            fontFamily: 'Nothing',  // Apply custom font here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildSuggestedPlaylists(),
                _buildRecommendedSongsAndArtists(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Suggested Playlists section
  Widget _buildSuggestedPlaylists() {
    return FutureBuilder<List<dynamic>>(
      future: getPlaylists(playlistsNum: 30),
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
    final double playlistHeight = 200.0;

    return Column(
      children: [
        _buildSectionHeader(
          title: context.l10n!.suggestedPlaylists,
          fontFamily: 'Nothing', // Replace with your desired font family
        ),
        SizedBox(
          height: playlistHeight,
          child: M3Carousel(
            type: "hero",
            heroAlignment: "center",
            // Remove onTap from M3Carousel
            children: List.generate(playlists.length, (index) {
              final playlist = playlists[index];

              return GestureDetector( // Wrap PlaylistCube with GestureDetector
                onTap: () {
                  // Navigate to PlaylistPage when a playlist is tapped
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(
                        cubeIcon: HugeIcons.strokeRoundedMusicNote01,
                        playlistId: playlist['id'],
                        isArtist: false,
                      ),
                    ),
                  );
                },
                child: ColoredBox(
                  color: Colors.primaries[index % Colors.primaries.length]
                      .withOpacity(0.8),  // Set the background color
                  child: PlaylistCube(
                    playlist,  // Pass playlist data
                    size: playlistHeight,  // Set the size of the playlist cube
                    isAlbum: null,  // Adjust based on your data (if needed)
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }


  // Recommended Songs and Artists section
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

  // Recommended content for songs and artists
  Widget _buildRecommendedContent({
    required BuildContext context,
    required List<dynamic> data,
    bool showArtists = true,
  }) {
    final contentHeight = MediaQuery.sizeOf(context).height * 0.25;

    return Column(
      children: [
        if (showArtists)
          _buildSectionHeader(title: context.l10n!.suggestedArtists, fontFamily: 'Nothing'), // Suggested artists header
        if (showArtists)
          SizedBox(
            height: contentHeight, // Set the height for the carousel display
            child: M3Carousel(
              type: "hero",  // Carousel type
              heroAlignment: "center",  // Align the carousel items in the center
              onTap: (int tapIndex) {
                log(tapIndex.toString());
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistPage(
                      cubeIcon: HugeIcons.strokeRoundedMic01,
                      playlistId: data[tapIndex]['artist'].split('~')[0],  // Adjust according to your data structure
                      isArtist: true,
                    ),
                  ),
                );
              },
              children: List.generate(data.length, (index) {
                final artist = data[index]['artist'].split('~')[0]; // Extract artist name

                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaylistPage(
                        cubeIcon: HugeIcons.strokeRoundedMic01,
                        playlistId: artist,
                        isArtist: true,
                      ),
                    ),
                  ),
                  child: ColoredBox(
                    color: Colors.primaries[index % Colors.primaries.length]
                        .withOpacity(0.8),
                    child: PlaylistCube(
                      {'title': artist},
                      size: contentHeight,
                      cubeIcon: HugeIcons.strokeRoundedMic01,
                      isAlbum: null,
                    ),
                  ),
                );
              }),
            ),
          ),
        // Suggested songs section remains
        _buildSectionHeader(
          title: context.l10n!.recommendedForYou,
          actionButton: IconButton(
            padding: const EdgeInsets.only(right: 10),
            onPressed: () {
              setActivePlaylist({
                'title': context.l10n!.recommendedForYou,
                'list': data,
              });
            },
            icon: Icon(
              HugeIcons.strokeRoundedPlayCircle,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ), fontFamily: 'Nothing',
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return SongBar(data[index], true); // Display recommended songs
          },
        ),
      ],
    );
  }

  // Loading widget while data is being fetched
  Widget _buildLoadingWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(35),
        child: Spinner(), // Custom spinner widget for loading state
      ),
    );
  }

  // Error widget in case of issues with data fetching
  Widget _buildErrorWidget(BuildContext context) {
    return Center(
      child: Text(
        '${context.l10n!.error}!', // Show error message from localization
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 18,
        ),
      ),
    );
  }

  // Section header widget
  Widget _buildSectionHeader({required String title, Widget? actionButton, required String fontFamily}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionTitle(
          title,
          Theme.of(context).colorScheme.primary,
        ),
        if (actionButton != null) actionButton,
      ],
    );
  }
}

// Custom Clipper for the AppBar
class AppBarClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();

    final p0 = size.height * 0.75;
    path.lineTo(0.0, p0);

    final controlPoint = Offset(size.width * 0.4, size.height);
    final endPoint = Offset(size.width, size.height / 2);
    path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false; // You can set this to true if the clip changes based on certain conditions.
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback? onPressed;  // Nullable onPressed for flexibility

  const SectionTitle(this.title, this.color, {Key? key, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: color)),
        if (onPressed != null)  // Only display the button if onPressed is not null
          IconButton(
            onPressed: onPressed,
            icon: Icon(Icons.more_horiz, color: color),
          ),
      ],
    );
  }
}
