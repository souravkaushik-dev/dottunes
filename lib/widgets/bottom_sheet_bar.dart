import 'package:flutter/material.dart';
import 'package:dottunes/utilities/common_variables.dart';
import 'package:glass_kit/glass_kit.dart'; // Import glass_kit

class BottomSheetBar extends StatelessWidget {
  const BottomSheetBar(
      this.title,
      this.onTap,
      this.backgroundColor, {
        this.borderRadius = BorderRadius.zero,
        super.key,
      });

  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(30),// Border radius for the glass container
      color: Colors.white.withOpacity(0.1), // Slight opacity for glass effect
      blur: 0, // Apply blur effect to create frosted glass look
      height: 70, // Height of the glass container
      margin: const EdgeInsets.only(bottom: 3),
      borderColor: Colors.white.withOpacity(0.2), // Soft border for subtle outline
      borderWidth: 1.5, // Border width to control the visibility
      child: Padding(
        padding: commonBarContentPadding,
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: ListTile(
            minTileHeight: 45,
            title: Text(
              title,
              style: TextStyle(
                fontFamily: 'Nothing', // Custom font
                fontSize: 18, // Font size
                fontWeight: FontWeight.bold, // Font weight
              ),
            ),
          ),
        ),
      ),
    );
  }
}
