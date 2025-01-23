import 'package:flutter/material.dart';

class updatedottunes extends StatefulWidget {
  const updatedottunes({super.key});

  @override
  State<updatedottunes> createState() => _AboutdottunesState();
}

class _AboutdottunesState extends State<updatedottunes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Bouncy animation for AppBar
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200), // Increased duration for more bounce
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut, // More intense bounce effect
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Scrollable SliverAppBar with bouncy animation
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
                            'Update | History',
                            style: TextStyle(
                              fontFamily: 'Nothing',
                              fontSize: isCollapsed ? 24.0 : 42.0, // Adjust font size for collapsed state
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Changelogs',
                            style: TextStyle(
                              fontFamily: 'Nothing',
                              fontSize: isCollapsed ? 12.0 : 18.0,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
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
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 268,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.10.0 - Elara ✨',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'Home Screen Icon Update in Song Bar 🎵🏠: The app icon in the song bar has been updated with a fresh new design for a more modern look.\n'
                              'Shuffle Icon Refresh 🔀: The shuffle button now has a sleek new icon for improved clarity.\n'

                              'What is Coming in Version 2.0.0 🚀: Major features are on the way! Stay tuned for exciting updates.\n'
                          ,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Gatte', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 227,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.9.0 - Clyra ✨',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'Icon Change on Song Bar & Nav Bar 🎶: Updated icons for a more modern and cohesive look across the song bar and navigation bar.\n'
                              'Enhancements ⚡: Various performance improvements and UI tweaks for a smoother and faster experience.\n',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 329,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.8.0 -  Emberlyn 🔥',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'Offline Music Fixed 🎧: The offline music issue from v1.5.0 is resolved. Enjoy your saved tracks anytime, anywhere!\n'
                              'API Revamp 🚀: A major API overhaul for faster performance, smoother streaming, and better app responsiveness.\n'
                              'Bug Fixes & Optimizations 🐞: Various bugs have been addressed to enhance stability and improve user experience.\n'
                            'Accent Color Shapes Updated 🎨: A fresh update to accent color shapes for a more polished and modern look.\n',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 208,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.7.0 -  Monterosa 🏔️',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '🎵 Playback Stability: Fixed freezing during extended playback sessions.\n'
                              '🖼️ UI Fixes: Resolved minor layout issues and improved alignment.\n'
                              '🔄 Playlist Sync: Enhanced syncing reliability across devices.\n',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 185,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.6.0 - Cadence 🎼',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• Fixed: Playlist loading loop issue.\n'
                              '• Improved: Playlist performance and rendering.\n'
                              '• Bug Fixes: Minor bug fixes and overall stability improvements.\n',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 189,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.5.0 - Celestia 🌟',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• New Nav Bar UI 🚀 for smoother navigation\n'
                              '• Fresh Onboarding Screen 🎉 for a smoother start\n'
                              '• Updated Material Accent Colors 🎨\n'
                              '• Minimal bug fixes 🐞 for enhanced performance',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        )
                        ,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 287,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.4.0 - Aurora Canyon 🌄',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• Navbar Updates: Home ➡️ Tunes, Search ➡️ Explore, Catalog ➡️ Library, Preferences ➡️ Settings.\n'
                              '• Icon Redesign: New icons for .tunes, Explore, Library, and Settings for a modern look.\n'
                              '• Performance Improvements: Better navbar spacing and enhanced color contrast for readability.\n'
                              '• Bug Fixes: Resolved issues with icon misalignment and flickering labels.',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Replace with your custom font family
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sliver item 1: dottunes Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 285,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.3.0 - Serene Waves 🌊',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• Added About page in the Settings: Users can now access app information and version details from the settings page.\n'
                              '• UI enhancements in the song playing screen: Small changes made for a more polished and seamless experience.\n'
                              '• Mini player improvements: Refined design for better accessibility and interaction during music playback.\n'
                              '• Miscellaneous bug fixes and stability improvements for smoother performance.'
                          ,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Add custom font family here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sliver item 2: Key Features
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 288,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.2.0 - Smooth Sail',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• Added support for offline playlists: Users can now enjoy their music without an internet connection.\n'
                              '• UI improvements: Updated the player interface for a more intuitive and visually appealing experience.\n'
                              '• Bug fixes: Resolved issues causing occasional crashes during album navigation.\n'
                              '• Optimized app startup time: Reduced load time for quicker access to your music library.',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Add custom font family here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 268,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.1.0 - Minimal Melody',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• Enhanced playlist functionality: Now users can edit and delete playlists seamlessly.\n'
                              '• Improved album loading speed: Optimized performance to reduce loading time.\n'
                              '• Bug fix for playlist restart issue: No longer required to restart the app after creating a new playlist.\n'
                              '• Minor UI improvements: Refinements made to enhance user experience and interface responsiveness.'
                          ,

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Add custom font family here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(45),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 288,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Version 1.0.0 - Initial Launch',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          '• First release of DotTunes, introducing the core functionality of the app.\n'
                              '• Playlist Creation: Users can create and manage playlists. Restart required after making a new playlist for changes to take effect.\n'
                              '• Albums Loading: Known issue with album loading speed, which may be slow at times.\n'
                              '• Future updates will focus on performance optimizations and improving album load times.',

                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Nothing', // Add custom font family here
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Sliver item 3: Future Enhancements
        ],
      ),
    );
  }
}
