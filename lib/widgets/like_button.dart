/*dottunes envor studios*/

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class LikeButton extends StatelessWidget {
  LikeButton({
    super.key,
    required this.onSecondaryColor,
    required this.onPrimaryColor,
    required this.isLiked,
    required this.onPressed,
  });
  final Color onSecondaryColor;
  final Color onPrimaryColor;
  final bool isLiked;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const likeStatusToIconMapper = {
      true: HugeIcons.strokeRoundedFavourite,
      false: HugeIcons.strokeRoundedHeartAdd,
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: onSecondaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          likeStatusToIconMapper[isLiked],
          color: onPrimaryColor,
          size: 25,
        ),
      ),
    );
  }
}
