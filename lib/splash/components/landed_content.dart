import 'package:flutter/material.dart';

class LandingContent extends StatelessWidget {
  const LandingContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Press , Play and \nEscape",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'Nothing',
              color: Theme.of(context).colorScheme.onSecondaryContainer, // Set the color
            ),
          )
          ,
          const SizedBox(
            height: 16,
          ),
          Text(
            "Dive into the soundscape of your dreams.",
            style: TextStyle(fontSize: 24,fontFamily: 'paytoneOne',color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }
}
