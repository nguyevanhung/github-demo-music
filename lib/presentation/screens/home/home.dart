import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/theme.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/logic/settings_cubit.dart';
import 'package:music_app/presentation/screens/discovery/discovery.dart';
import 'package:music_app/presentation/screens/home/viewmodel.dart';
import 'package:music_app/presentation/screens/now_playing/audio_player_manager.dart';
import 'package:music_app/presentation/screens/settings/app_localizations.dart';
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
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final loc = AppLocalizations(settings.language);
        return CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            activeColor: AppColors.primary,
            backgroundColor: AppColors.background,
            items: [
              BottomNavigationBarItem(
                  icon: const Icon(Icons.home), label: loc.get('home')),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.album), label: loc.get('discovery')),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.person), label: loc.get('account')),
              BottomNavigationBarItem(
                  icon: const Icon(Icons.settings), label: loc.get('settings')),
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
    final settings = context.watch<SettingsCubit>().state;
    final loc = AppLocalizations(settings.language);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('home')),
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
              decoration: InputDecoration(
                hintText: loc.get('search_hint') ??
                    'Tìm kiếm bài hát hoặc tác giả...',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(child: getBody(loc)),
        ],
      ),
    );
  }

  Widget getBody(AppLocalizations loc) {
    if (filteredSongs.isEmpty) {
      return Center(
          child: Text(loc.get('not_found') ?? 'Không tìm thấy bài hát nào'));
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
        isPlaying: false,
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

class SongItemSection extends StatefulWidget {
  const SongItemSection({
    super.key,
    required this.song,
    required this.onTap,
    required this.isPlaying,
  });

  final Song song;
  final VoidCallback onTap;
  final bool isPlaying;

  @override
  State<SongItemSection> createState() => _SongItemSectionState();
}

class _SongItemSectionState extends State<SongItemSection> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(widget.song.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        color: theme.colorScheme.secondary.withOpacity(0.1),
        child: const Icon(Icons.more_horiz, color: Colors.deepPurple, size: 32),
      ),
      confirmDismiss: (_) async {
        // Hiện bottom sheet hoặc menu tuỳ chọn ở đây
        showModalBottomSheet(
          context: context,
          builder: (_) => ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Chi tiết bài hát'),
            onTap: () => Navigator.pop(context),
          ),
        );
        return false;
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: theme.primaryColor.withOpacity(0.1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: widget.isPlaying
                  ? theme.primaryColor.withOpacity(0.08)
                  : _isHovered
                      ? theme.primaryColor.withOpacity(0.04)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FadeInImage.assetNetwork(
                  placeholder: 'assets/itunes.png',
                  image: widget.song.image,
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
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.song.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (widget.isPlaying)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: AnimatedEqualizerIcon(),
                    ),
                ],
              ),
              subtitle: Text(widget.song.artist),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedEqualizerIcon extends StatefulWidget {
  @override
  State<AnimatedEqualizerIcon> createState() => _AnimatedEqualizerIconState();
}

class _AnimatedEqualizerIconState extends State<AnimatedEqualizerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bar1, _bar2, _bar3;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(reverse: true);
    _bar1 = Tween<double>(begin: 10, end: 22)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bar2 = Tween<double>(begin: 22, end: 10)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _bar3 = Tween<double>(begin: 16, end: 26)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 24,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _bar(_bar1.value),
            const SizedBox(width: 2),
            _bar(_bar2.value),
            const SizedBox(width: 2),
            _bar(_bar3.value),
          ],
        ),
      ),
    );
  }

  Widget _bar(double height) => Container(
        width: 3,
        height: height,
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(2),
        ),
      );
}
