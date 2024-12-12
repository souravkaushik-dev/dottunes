import 'package:flutter/material.dart';

class AboutDottunes extends StatefulWidget {
  const AboutDottunes({super.key});

  @override
  State<AboutDottunes> createState() => _AboutDottunesState();
}

class _AboutDottunesState extends State<AboutDottunes> with SingleTickerProviderStateMixin {
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
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Dottunes | Early Access',
                style: TextStyle(
                  fontFamily: 'Nothing', // Replace with your custom font family
                  fontSize: 20, // Set the desired font size
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
            floating: true,
            snap: false,
            backgroundColor: Colors.transparent, // Remove the default color to let the rounded corner show
          ),
          // Sliver item 1: Dottunes Overview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
                left: 20,
                right: 20,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 300,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'Dottunes Overview:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing',
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'Dottunes is a dynamic and feature-rich music player developed by Envor Studios. The app seamlessly combines online and offline music streaming, customizable playlists, and high-quality audio to create an immersive listening experience. It supports a variety of genres, provides personalized recommendations, and integrates with external audio devices for enhanced music playback.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'paytoneOne', // Add custom font family here
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 350,
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
                          'Dottunes offers an exceptional set of features, including:\n\n'
                              '• Customizable playlists to curate your music collection.\n'
                              '• High-quality audio streaming with support for various file formats.\n'
                              '• Cross-device syncing to maintain your preferences.\n'
                              '• Personalized music recommendations based on listening habits.\n'
                              '• Integration with external devices like Bluetooth speakers and headsets.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'paytoneOne', // Add custom font family here
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  height: 300,
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
                          'Dottunes is continuously evolving, with plans to expand its music catalog, improve social sharing features, and enhance user personalization options. Upcoming features include seamless integration with music streaming services, enhanced audio controls, and more in-depth artist discovery functionalities.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'paytoneOne', // Add custom font family here
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
