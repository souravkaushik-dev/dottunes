//dotstudios

import 'package:flutter/material.dart';
import 'package:dottunes/utilities/common_variables.dart';

class CustomBar extends StatelessWidget {
  CustomBar(
    this.tileName,
    this.tileIcon, {
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.borderRadius = BorderRadius.zero,
    super.key,
  });

  final String tileName;
  final IconData tileIcon;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: commonBarPadding,
      child: Card(
        margin: const EdgeInsets.only(bottom: 3),
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Fixed here
        ),
        child: Padding(
          padding: commonBarContentPadding,
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: onTap,
            onLongPress: onLongPress,
            child: ListTile(
              minVerticalPadding: 10, // Optional for vertical spacing between content
              minTileHeight: 45,
              leading: Icon(
                tileIcon,
                color: iconColor,
              ),
              title: Text(
                tileName,
                style: TextStyle(fontWeight: FontWeight.w600, color: textColor, fontFamily: 'Nothing'),
              ),
              trailing: trailing,
            ),
          ),
        ),
      ),
    );
  }
}
