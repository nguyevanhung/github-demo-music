import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:music_app/presentation/screens/discovery/favorite.dart';
import 'package:music_app/data/model/song.dart';
import 'package:music_app/presentation/screens/now_playing/audio_player_manager.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:music_app/core/theme/theme.dart'; // Thêm dòng này

class NowPlaying extends StatelessWidget {
  const NowPlaying({
    super.key,
    required this.playingSong,
    required this.layingSong,
    required this.songs,
  });

  final Song playingSong;
  final Song layingSong;
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    return NowPlayingPage(
      songs: songs,
      playingSong: playingSong,
    );
  }
}

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({
    super.key,
    required this.playingSong,
    required this.songs,
  });

  final Song playingSong;
  final List<Song> songs;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _imageAnimController;
  late AudioPlayerManager _audioPlayerManager;
  late int _selectedItemIndex;
  late Song _song;
  double _currenAnimationPosition = 0.0;
  bool _isShuffle = false;
  late LoopMode _loopMode;

  @override
  void initState() {
    super.initState();
    _song = widget.playingSong;
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _imageAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    _audioPlayerManager = AudioPlayerManager();
    if(_audioPlayerManager.songUrl.compareTo(_song.source) != 0){
      _audioPlayerManager.updateSongUrl(_song.source);
      _audioPlayerManager.prepare(isNewSong: true);
    }else{
      _audioPlayerManager.prepare(isNewSong: false);
    }
    _selectedItemIndex = widget.songs.indexOf(widget.playingSong);
    _loopMode = LoopMode.off;
  }

  @override
  void dispose() {
    _imageAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const delta = 64.0;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Now Playing'),
        backgroundColor: AppColors.primary,
        
        trailing: IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () {},
        ),
      ),
      child: Scaffold(
        backgroundColor: AppColors.white, // Container background
        body: SafeArea(
          top: false, // Để không bị trùng với CupertinoNavigationBar
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32), // Đẩy toàn bộ nội dung xuống thấp hơn
                  // Album
                  Text(
                    _song.album,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.primary, // Thay vì Colors.deepPurple
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Divider
                  Container(
                    width: 80,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Album Art with shadow
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(radius),
                    ),
                    child: RotationTransition(
                      turns: Tween(begin: 0.0, end: 1.0).animate(_imageAnimController),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(radius),
                        child: FadeInImage.assetNetwork(
                          placeholder: 'assets/images/itunes.png',
                          image: _song.image,
                          width: screenWidth - delta,
                          height: screenWidth - delta,
                          fit: BoxFit.cover,
                          imageErrorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/images/itunes.png',
                              width: screenWidth - delta,
                              height: screenWidth - delta,
                              fit: BoxFit.cover,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Song title, artist, favorite
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Text(
                          _song.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text, // Thay vì Colors.black87
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _song.artist,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[700], // Có thể thêm vào AppColors nếu muốn
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  FavoriteManager().toggleFavorite(_song);
                                });
                              },
                              icon: Icon(
                                FavoriteManager().isFavorite(_song)
                                    ? Icons.favorite
                                    : Icons.favorite_outline,
                              ),
                              color: FavoriteManager().isFavorite(_song)
                                  ? AppColors.error
                                  : AppColors.primary,
                              iconSize: 32,
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.share_outlined),
                              color: AppColors.primary,
                              iconSize: 28,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: _progressBar(),
                  ),
                  // Media buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: _mediaButtons(),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        MediaButtonControl(
          function: _setShuffle,
          icon: Icons.shuffle,
          color: _getShuffleColor!,
          size: 24,
        ),
        MediaButtonControl(
          function: _setPrevSong,
          icon: Icons.skip_previous,
          color: Colors.deepPurple,
          size: 36,
        ),
        _playButton(),
        MediaButtonControl(
          function: _setNextSong,
          icon: Icons.skip_next,
          color: Colors.deepPurple,
          size: 36,
        ),
        MediaButtonControl(
          function: _setupRepeatOption,
          icon: _repeatingIcon(),
          color: _getRepeatingIconColor(),
          size: 24,
        ),
      ],
    );
  }

  StreamBuilder<DurationState> _progressBar() {
    return StreamBuilder<DurationState>(
      stream: _audioPlayerManager.durationState,
      builder: (context, snapshot) {
        final durationState = snapshot.data;
        final progress = durationState?.progress ?? Duration.zero;
        final buffered = durationState?.buffered ?? Duration.zero;
        final total = durationState?.total ?? Duration.zero;

        return ProgressBar(
          progress: progress,
          buffered: buffered,
          total: total,
          onSeek: (duration) {
            _audioPlayerManager.player.seek(duration);
          },
          barHeight: 5.0,
          baseBarColor: Colors.grey.withOpacity(0.3),
          bufferedBarColor: Colors.grey.withOpacity(0.3),
          thumbColor: AppColors.primary,
          thumbGlowColor: Colors.green.withOpacity(0.3),
          thumbRadius: 10.0,
          barCapShape: BarCapShape.round,
        );
      },
    );
  }

  StreamBuilder<PlayerState> _playButton() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayerManager.player.playerStateStream,
      builder: (context, snapshot) {
        final playState = snapshot.data;
        final processingState = playState?.processingState;
        final playing = playState?.playing;

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: const EdgeInsets.all(8),
            width: 48,
            height: 48,
            child: const CircularProgressIndicator(),
          );
        } else if (playing != true) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.play();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _playRotationAnim();
              });
            },
            icon: Icons.play_arrow,
            color: null,
            size: 48,
          );
        } else if (processingState != ProcessingState.completed) {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.pause();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _pauseRotationAnim();
              });
            },
            icon: Icons.pause,
            color: null,
            size: 48,
          );
        } else {
          return MediaButtonControl(
            function: () {
              _audioPlayerManager.player.seek(Duration.zero);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _resetRotationAnim();
                _playRotationAnim();
              });
            },
            icon: Icons.replay,
            color: null,
            size: 48,
          );
        }
      },
    );
  }

  void _setShuffle() {
      setState(() {
        _isShuffle = !_isShuffle;
      });
  }
  Color? get _getShuffleColor => _isShuffle ? AppColors.primary : Colors.grey;

  void _setNextSong() {
    if (_selectedItemIndex < widget.songs.length - 1) {
      _selectedItemIndex++;
      final nextSong = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(nextSong.source);
      setState(() {
        _song = nextSong;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetRotationAnim();
        _playRotationAnim();
      });
    }
  }

  void _setPrevSong() {
    if (_selectedItemIndex > 0) {
      _selectedItemIndex--;
      final prevSong = widget.songs[_selectedItemIndex];
      _audioPlayerManager.updateSongUrl(prevSong.source);
      setState(() {
        _song = prevSong;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _resetRotationAnim();
        _playRotationAnim();
      });
    }
  }
  IconData _repeatingIcon (){
    return switch(_loopMode){
      LoopMode.one => Icons.repeat_one,
      LoopMode.all => Icons.repeat,
      _ => Icons.repeat,
    };
  }

  void _setupRepeatOption() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.one;
    } else if (_loopMode == LoopMode.one) {
      _loopMode = LoopMode.all;
    } else {
      _loopMode = LoopMode.off;
    }
    setState(() {
      _audioPlayerManager.player.setLoopMode(_loopMode);
    });
  }

  Color? _getRepeatingIconColor(){
    return _loopMode == LoopMode.off ? Colors.grey : AppColors.primary;
  }

  void _playRotationAnim() {
    _imageAnimController.forward(from: _currenAnimationPosition);
    _imageAnimController.repeat();
  }

  void _pauseRotationAnim() {
    _stopRotationAnim();
    _currenAnimationPosition = _imageAnimController.value;
  }

  void _stopRotationAnim() {
    _imageAnimController.stop();
  }

  void _resetRotationAnim() {
    _currenAnimationPosition = 0.0;
    _imageAnimController.value = _currenAnimationPosition;
  }
}

class MediaButtonControl extends StatefulWidget {
  const MediaButtonControl({
    super.key,
    required this.function,
    required this.icon,
    required this.color,
    required this.size,
  });

  final void Function() function;
  final IconData icon;
  final double? size;
  final Color? color;

  @override
  State<MediaButtonControl> createState() => _MediaButtonControlState();
}

class _MediaButtonControlState extends State<MediaButtonControl> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: widget.function,
      icon: Icon(widget.icon, size: widget.size, color: widget.color),
    );
  }
}