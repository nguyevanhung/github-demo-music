import 'package:flutter/foundation.dart';
import 'package:music_app/data/model/song.dart';

class FavoriteManager {
  static final FavoriteManager _instance = FavoriteManager._internal();
  factory FavoriteManager() => _instance;
  FavoriteManager._internal();

  final ValueNotifier<List<Song>> favoritesNotifier = ValueNotifier([]);

  List<Song> get favorites => List.unmodifiable(favoritesNotifier.value);

  bool isFavorite(Song song) {
    return favoritesNotifier.value.any((s) => s.source == song.source);
  }

  void addFavorite(Song song) {
    if (!isFavorite(song)) {
      favoritesNotifier.value = [...favoritesNotifier.value, song];
    }
  }

  void removeFavorite(Song song) {
    favoritesNotifier.value =
        favoritesNotifier.value.where((s) => s.source != song.source).toList();
  }

  void toggleFavorite(Song song) {
    if (isFavorite(song)) {
      removeFavorite(song);
    } else {
      addFavorite(song);
    }
  }
}
