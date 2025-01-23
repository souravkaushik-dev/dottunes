//dotstudios

import 'package:audio_service/audio_service.dart';
import 'package:hugeicons/hugeicons.dart';


import 'package:flutter/material.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/screens/now_playing_page.dart';
import 'package:dottunes/widgets/marque.dart';
import 'package:dottunes/widgets/playback_icon_button.dart';
import 'package:dottunes/widgets/song_artwork.dart';
import 'package:hugeicons/hugeicons.dart';



class MiniPlayer extends StatelessWidget {
  MiniPlayer({super.key, required this.metadata});
  final MediaItem metadata;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < 0) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return const NowPlayingPage();
              },
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(0, 1);
                const end = Offset.zero;

                final tween = Tween(begin: begin, end: end);
                final curve =
                    CurvedAnimation(parent: animation, curve: Curves.easeInOut);

                final offsetAnimation = tween.animate(curve);

                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        }
      },
      onTap: () => Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const NowPlayingPage();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(0, 1);
            const end = Offset.zero;

            final tween = Tween(begin: begin, end: end);
            final curve =
                CurvedAnimation(parent: animation, curve: Curves.easeInOut);

            final offsetAnimation = tween.animate(curve);

            return SlideTransition(position: offsetAnimation, child: child);
          },
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        height: 75,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(20), // Add rounded corners here
          boxShadow: [
            BoxShadow(
              color: Colors.transparent,
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            _buildArtwork(),
            _buildMetadata(colorScheme.primary, colorScheme.secondary),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final processingState = snapshot.data?.processingState;
                    final isPlaying = snapshot.data?.playing ?? false;
                    final iconDataAndAction = getIconFromState(processingState, isPlaying);
                    return GestureDetector(
                      onTap: iconDataAndAction.onPressed,
                      child: Icon(
                        iconDataAndAction.iconData,
                        color: colorScheme.primary,
                        size: 35,
                      ),
                    );
                  },
                ),
                if (audioHandler.hasNext) const SizedBox(width: 10),
                if (audioHandler.hasNext)
                  GestureDetector(
                    onTap: () => audioHandler.skipToNext(),
                    child: Icon(
                      HugeIcons.strokeRoundedArrowRightDouble,
                      color: colorScheme.primary,
                      size: 25,
                    ),
                  ),
              ],
            ),
          ],
        ),
      )
    );
  }

  Widget _buildArtwork() {
    return Padding(
      padding: const EdgeInsets.only(top: 7, bottom: 4, right: 50),
      child: SongArtworkWidget(
        metadata: metadata,
        size: 55,
        errorWidgetIconSize: 30,
      ),
    );
  }

  Widget _buildMetadata(Color titleColor, Color artistColor) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MarqueeWidget(
            manualScrollEnabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  metadata.title,
                  style: TextStyle(
                    color: titleColor,
                    fontFamily: 'Nothing',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (metadata.artist != null)
                  Text(
                    metadata.artist!,
                    style: TextStyle(
                      color: artistColor,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
