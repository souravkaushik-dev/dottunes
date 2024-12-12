import 'package:flutter/material.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Accessing the theme context colors
    final themeTextColor = Theme.of(context).textTheme.bodyLarge?.color;
    final themePrimaryColor = Theme.of(context).primaryColor;
    final themeHintColor = Theme.of(context).hintColor;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main text with larger font size using theme color
            Text(
              "Welcome to dottunes\n– Your music, your vibe.",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                fontFamily: 'Nothing',
                color: themePrimaryColor, // Use theme color or default to black
              ),
            ),
            const SizedBox(height: 150), // Reduced spacing

            // Smaller text with theme color
            Text(
              "Discover and enjoy your favorite tracks anytime, anywhere.",
              style: TextStyle(
                fontSize: 16,
                fontFamily: 'paytoneOne',
                color: Theme.of(context).colorScheme.secondary, // Use secondary color from the theme
              ),
            ),

            // Reduced bottom text spacing
            const SizedBox(height: 60), // Reduced spacing
            Center(
              child: Text(
                "Designed and coded by Envor Studios.",
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Nothing', // Shorter font size
                  color: Theme.of(context).colorScheme.secondary, // Use primary theme color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
