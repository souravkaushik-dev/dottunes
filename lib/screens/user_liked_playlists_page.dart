/*dottunes envor studios*/

import 'package:flutter/material.dart';
import 'package:dottunes/API/dottunes.dart';
import 'package:dottunes/extensions/l10n.dart';
import 'package:dottunes/widgets/playlist_cube.dart';

class UserLikedPlaylistsPage extends StatelessWidget {
  const UserLikedPlaylistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n!.likedPlaylists),
      ),
      body: ValueListenableBuilder(
        valueListenable: currentLikedPlaylistsLength,
        builder: (_, value, __) {
          return userLikedPlaylists.isEmpty
              ? Center(
                  child: Text(
                    context.l10n!.noLikedPlaylists,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                    ),
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: userLikedPlaylists.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (BuildContext context, index) {
                      return PlaylistCube(userLikedPlaylists[index]);
                    },
                  ),
                );
        },
      ),
    );
  }
}
