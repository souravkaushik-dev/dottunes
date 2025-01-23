import 'package:audio_service/audio_service.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
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
  final _animationDuration = const Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    // Fetch theme colors
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final onSurfaceColor = theme.colorScheme.onSurface;

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
          // SalomonBottomBar for the tab navigation
          SalomonBottomBar(
            currentIndex: _selectedIndex.value,
            onTap: (index) {
              widget.child.goBranch(
                index,
                initialLocation: index == widget.child.currentIndex,
              );
              setState(() {
                _selectedIndex.value = index;
              });
            },
            items: !offlineMode.value
                ? [
              _buildJumpingBarItem(
                index: 0,
                icon: const Icon(HugeIcons.strokeRoundedMountain),
                title: '.tunes',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
              _buildJumpingBarItem(
                index: 1,
                icon: const Icon(HugeIcons.strokeRoundedSeal),
                title: '.explore',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
              _buildJumpingBarItem(
                index: 2,
                icon: const Icon(HugeIcons.strokeRoundedLibraries),
                title: '.catalog',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
              _buildJumpingBarItem(
                index: 3,
                icon: const Icon(HugeIcons.strokeRoundedGeometricShapes02),
                title: '.settings',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
            ]
                : [
              _buildJumpingBarItem(
                index: 0,
                icon: const Icon(HugeIcons.strokeRoundedHome01),
                title: 'Discover',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
              _buildJumpingBarItem(
                index: 1,
                icon: const Icon(HugeIcons.strokeRoundedSettings05),
                title: 'Preferences',
                primaryColor: primaryColor,
                onSurfaceColor: onSurfaceColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Method to create a SalomonBottomBarItem with jump animation on selection
  SalomonBottomBarItem _buildJumpingBarItem({
    required int index,
    required Icon icon,
    required String title,
    required Color primaryColor,
    required Color onSurfaceColor,
  }) {
    return SalomonBottomBarItem(
      icon: ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, selectedIndex, child) {
          final isSelected = selectedIndex == index;
          return AnimatedAlign(
            duration: _animationDuration,
            curve: Curves.easeOut,
            alignment: Alignment(0, isSelected ? -1 : 0), // Move up on selection
            child: AnimatedScale(
              scale: isSelected ? 1.3 : 1.0, // Scale up the icon when selected
              duration: _animationDuration,
              curve: Curves.easeOut,
              child: icon,
            ),
          );
        },
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nothing', // Replace with your actual font family
        ),
      ),
      selectedColor: primaryColor,
      unselectedColor: onSurfaceColor.withOpacity(0.6),
    );
  }
}
