import 'package:flutter/material.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> with SingleTickerProviderStateMixin {
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
                            '.tunes | .studios',
                            style: TextStyle(
                              fontFamily: 'Nothing',
                              fontSize: isCollapsed ? 24.0 : 32.0, // Adjust font size for collapsed state
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'About',
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
          // Rest of the scrollable content
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
                  height: 256,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Heading text
                        Text(
                          'dottunes’ Role in Dot Studios:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, fontFamily: 'Nothing'
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'As one of the flagship projects of Dot Studios, dottunes exemplifies the studios commitment to delivering cutting-edge and user-centric mobile applications. dottunes stands out for its rich feature set, sophisticated design, and smooth performance, making it a top choice for music enthusiasts.',
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


          // sliver items 2
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
                          'Future Features:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold, fontFamily: 'Nothing'
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'dottunes continues to evolve, with plans for even more integrations, features, and enhancements. Whether its expanded music streaming options, social sharing, or further personalization capabilities, dottunes aims to remain at the forefront of the music app industry.',
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

          // sliver items 3
        ],
      ),
    );
  }
}
