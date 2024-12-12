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
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('dottunes | Envor Studios', style: TextStyle(
                fontFamily: 'Nothing',  // Replace with your custom font family
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
          // Rest of the scrollable content
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
                          'Dottunes’ Role in Envor Studios:',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, fontFamily: 'Nothing'
                          ),
                        ),
                        const SizedBox(height: 8), // Space between heading and content
                        // Non-heading text
                        Text(
                          'As one of the flagship projects of Envor Studios, Dottunes exemplifies the studios commitment to delivering cutting-edge and user-centric mobile applications. Dottunes stands out for its rich feature set, sophisticated design, and smooth performance, making it a top choice for music enthusiasts.',
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


          // sliver items 2
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
                  height: 260,
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
                          'Dottunes continues to evolve, with plans for even more integrations, features, and enhancements. Whether its expanded music streaming options, social sharing, or further personalization capabilities, Dottunes aims to remain at the forefront of the music app industry.',
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

          // sliver items 3
        ],
      ),
    );
  }
}
