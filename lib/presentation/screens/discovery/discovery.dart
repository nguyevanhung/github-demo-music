import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/presentation/screens/discovery/favorite.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/presentation/screens/now_playing/playing.dart';
import 'package:music_app/core/theme/theme.dart'; // Thêm dòng này

class DiscoveryTab extends StatefulWidget {
  const DiscoveryTab({super.key});

  @override
  State<DiscoveryTab> createState() => _DiscoveryTabState();
}

class _DiscoveryTabState extends State<DiscoveryTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bài hát yêu thích'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: ValueListenableBuilder<List<Song>>(
        valueListenable: FavoriteManager().favoritesNotifier,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return const Center(child: Text('Chưa có bài hát yêu thích nào'));
          }
          return ListView.separated(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final song = favorites[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/itunes.png',
                    image: song.image,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/itunes.png',
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
                title: Text(
                  song.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Sử dụng màu chủ đạo
                  ),
                ),
                subtitle: Text(
                  song.artist,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: AppColors.error),
                  onPressed: () {
                    FavoriteManager().toggleFavorite(song);
                  },
                ),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NowPlaying(
                        playingSong: song,
                        layingSong: song,
                        songs: favorites,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(
              color: AppColors.primary,
              indent: 24,
              endIndent: 24,
              thickness: 0.5,
            ),
          );
        },
      ),
    );
  }
}
