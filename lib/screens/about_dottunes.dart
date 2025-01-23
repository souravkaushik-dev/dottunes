import 'package:flutter/material.dart';

class Aboutdottunes extends StatefulWidget {
  const Aboutdottunes({super.key});

  @override
  State<Aboutdottunes> createState() => _AboutdottunesState();
}

class _AboutdottunesState extends State<Aboutdottunes> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Bouncy animation for AppBar
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticInOut,
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
                            '.tunes | 1.10.0 | Elara ✨',
                            style: TextStyle(
                              fontFamily: 'Nothing',
                              fontSize: isCollapsed ? 24.0 : 32.0, // Adjust font size for collapsed state
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
                  height: 268,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'dottunes Overview:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'dottunes is a dynamic and feature-rich music player developed by dot studios. The app seamlessly combines online and offline music streaming, customizable playlists, and high-quality audio to create an immersive listening experience. It supports a variety of genres, provides personalized recommendations, and integrates with external audio devices for enhanced music playback.',
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
                  height: 328,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Key Features:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'dottunes offers an exceptional set of features, including:\n\n'
                              '• Customizable playlists to curate your music collection.\n'
                              '• High-quality audio streaming with support for various file formats.\n'
                              '• Cross-device syncing to maintain your preferences.\n'
                              '• Personalized music recommendations based on listening habits.\n'
                              '• Integration with external devices like Bluetooth speakers and headsets.',
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
                  height: 228,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Future Enhancements:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'dottunes is continuously evolving, with plans to expand its music catalog, improve social sharing features, and enhance user personalization options. Upcoming features include seamless integration with music streaming services, enhanced audio controls, and more in-depth artist discovery functionalities.',
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
        ],
      ),
    );
  }
}
