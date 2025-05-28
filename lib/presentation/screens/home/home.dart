import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/theme.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/presentation/screens/discovery/discovery.dart';
import 'package:music_app/presentation/screens/home/viewmodel.dart';
import 'package:music_app/presentation/screens/now_playing/audio_player_manager.dart';
import 'package:music_app/presentation/screens/settings/settings.dart';
import 'package:music_app/presentation/screens/user/user.dart';
import 'package:music_app/presentation/screens/now_playing/playing.dart';

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MusicHomePage();
  }
}

class MusicHomePage extends StatelessWidget {
  const MusicHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        activeColor: AppColors.primary,
        backgroundColor: AppColors.background,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        switch (index) {
          case 0:
            return const HomeTab();
          case 1:
            return const DiscoveryTab();
          case 2:
            return const AccountTab();
          case 3:
            return const SettingsTab();
          default:
            return const HomeTab();
        }
      },
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeTabPage();
  }
}

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  List<Song> songs = [];
  List<Song> filteredSongs = [];
  late MusicAppViewModel _viewModel;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _viewModel = MusicAppViewModel();
    observeData();
    _viewModel.loadSongs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _viewModel.songsStream.close();
    AudioPlayerManager().dispose();
    _searchController.dispose();
    super.dispose();
  }

  void observeData() {
    _viewModel.songsStream.stream.listen((songList) {
      setState(() {
        songs = songList;
        filteredSongs = songList;
      });
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredSongs = songs.where((song) {
        return song.title.toLowerCase().contains(query) ||
               song.artist.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm bài hát hoặc tác giả...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: getBody()),
        ],
      ),
    );
  }

  Widget getBody() {
    if (filteredSongs.isEmpty) {
      return const Center(child: Text('Không tìm thấy bài hát nào'));
    } else {
      return getListView();
    }
  }

  ListView getListView() {
    return ListView.separated(
      itemCount: filteredSongs.length,
      shrinkWrap: true,
      itemBuilder: (context, index) => SongItemSection(
        song: filteredSongs[index],
        onTap: () => navigate(filteredSongs[index]),
      ),
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
        thickness: 1,
        indent: 24,
        endIndent: 24,
      ),
    );
  }

  void navigate(Song song) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => NowPlaying(
          songs: filteredSongs,
          layingSong: song,
          playingSong: song,
        ),
      ),
    );
  }
}

class SongItemSection extends StatelessWidget {
  const SongItemSection({
    super.key,
    required this.song,
    required this.onTap,
  });

  final Song song;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/itunes.png',
          image: song.image,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/itunes.png',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          // Optionally implement bottom sheet or options
        },
      ),
    );
  }
}
