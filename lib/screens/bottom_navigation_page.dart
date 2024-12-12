/*dottunes envor studios*/

import 'package:audio_service/audio_service.dart';
import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/main.dart';
import 'package:dottunes/services/settings_manager.dart';
import 'package:dottunes/widgets/mini_player.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    super.key,
    required this.child,
  });

  final StatefulNavigationShell child;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  final _selectedIndex = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {
    // Fetch theme colors
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;
    final backgroundColor = theme.colorScheme.background;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder<MediaItem?>(
            stream: audioHandler.mediaItem,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                logger.log(
                  'Error in mini player bar',
                  snapshot.error,
                  snapshot.stackTrace,
                );
              }
              final metadata = snapshot.data;
              if (metadata == null) {
                return const SizedBox.shrink();
              } else {
                return MiniPlayer(metadata: metadata);
              }
            },
          ),
          // Container to make the FlashyTabBar appear floating
          Container(
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0), // Adjust margins for better alignment
            decoration: BoxDecoration(
              color: backgroundColor, // Background color of the container
              borderRadius: BorderRadius.circular(10), // Rounded top corners
              boxShadow: [
                BoxShadow(
                  color: Colors.transparent,  // Dark shadow to make it look floating
                  blurRadius: 15,
                  spreadRadius: 5,
                  offset: Offset(0, 8),  // Slight downward shadow
                ),
              ],
            ),
            child: FlashyTabBar(
              selectedIndex: _selectedIndex.value,
              animationCurve: Curves.easeInOut,
              backgroundColor: backgroundColor,
              items: !offlineMode.value
                  ? [
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedHome01),
                  title: Text(context.l10n?.home ?? 'Home'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedSearch02),
                  title: Text(context.l10n?.search ?? 'Search'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedPlaylist01),
                  title: Text(context.l10n?.library ?? 'Library'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedAccountSetting03),
                  title: Text(context.l10n?.settings ?? 'Settings'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
              ]
                  : [
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedHome01),
                  title: Text(context.l10n?.home ?? 'Home'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
                FlashyTabBarItem(
                  icon: const Icon(HugeIcons.strokeRoundedAccountSetting03),
                  title: Text(context.l10n?.settings ?? 'Settings'),
                  activeColor: primaryColor,
                  inactiveColor: onSurfaceColor.withOpacity(0.6),
                ),
              ],
              onItemSelected: (index) {
                widget.child.goBranch(
                  index,
                  initialLocation: index == widget.child.currentIndex,
                );
                setState(() {
                  _selectedIndex.value = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
