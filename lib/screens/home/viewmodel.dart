import 'dart:async';
import 'package:music_app/screens/home/home.dart';
import '../../data/repository/repository.dart';
import '../../data/model/song.dart';

class MusicAppViewModel{
  StreamController<List<Song>> songsStream = StreamController();

  void loadSongs() async {
    final repository = DefaultRepository();
    repository.loadData().then((value) => songsStream.add(value!));
  }
}