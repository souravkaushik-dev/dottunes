import 'package:audio_service/audio_service.dart';
import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
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
      body: Stack(
        children: [
          // Main body content
          widget.child,
          // Overlay the navigation bar on top of the screen
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Column(
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
                // CrystalNavigationBar with transparent background
                CrystalNavigationBar(
                  currentIndex: _selectedIndex.value, // Set the current selected index
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
                    _buildCrystalNavItem(
                      index: 0,
                      icon: HugeIcons.strokeRoundedMountain, // IconData directly
                      text: '.discover', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                    _buildCrystalNavItem(
                      index: 1,
                      icon: HugeIcons.strokeRoundedSeal,
                      text: '.explore', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                    _buildCrystalNavItem(
                      index: 2,
                      icon: HugeIcons.strokeRoundedLibraries,
                      text: '.catalog', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                    _buildCrystalNavItem(
                      index: 3,
                      icon: HugeIcons.strokeRoundedGeometricShapes02,
                      text: '.prefs', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                  ]
                      : [
                    _buildCrystalNavItem(
                      index: 0,
                      icon: HugeIcons.strokeRoundedHome01,
                      text: '.discover', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                    _buildCrystalNavItem(
                      index: 1,
                      icon: HugeIcons.strokeRoundedGeometricShapes02,
                      text: '.prefs', // Updated parameter to `text`
                      primaryColor: primaryColor,
                      onSurfaceColor: onSurfaceColor,
                    ),
                  ],
                  backgroundColor: Colors.transparent, // Set background to transparent
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to create a CrystalNavItem with jump animation on selection
  CrystalNavigationBarItem _buildCrystalNavItem({
    required int index,
    required IconData icon, // Directly use IconData
    required String text, // Updated to `text` instead of `label`
    required Color primaryColor,
    required Color onSurfaceColor,
  }) {
    return CrystalNavigationBarItem(
      icon: icon, // Directly use IconData
      selectedColor: primaryColor,
      unselectedColor: onSurfaceColor.withOpacity(0.6),
    );
  }
}
