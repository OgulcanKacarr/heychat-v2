import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:heychat_2/view_model/watch_together/watch_together_page_viewmodel.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

final viewModel = ChangeNotifierProvider((ref) => WatchTogetherPageViewmodel());

class WatchTogetherPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<WatchTogetherPage> createState() => _WatchTogetherPageState();
}

class _WatchTogetherPageState extends ConsumerState<WatchTogetherPage> {
  late String friendName;
  late YoutubePlayerController _controller;
  TextEditingController _urlController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String sessionId;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    _controller.addListener(_videoStateListener);
  }

  void _videoStateListener() {
    final playerState = _controller.value;

    if (playerState.isReady) {
      _updateVideoState(playerState);

      if (playerState.playerState == PlayerState.ended) {
        _endSession();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)?.settings.arguments as Map?;
    if (arguments != null) {
      friendName = arguments?['friendName'] ?? '';
      sessionId = arguments?['sessionId'] ?? '';
      _listenToSessionChanges();
    }
  }

  void _listenToSessionChanges() {
    _firestore.collection('sessions').doc(sessionId).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final videoId = data['videoId'] as String?;
        final isPlaying = data['isPlaying'] as bool?;
        final currentTime = data['currentTime'] as double?;

        if (videoId != null && videoId != _controller.metadata.videoId) {
          _controller.load(videoId);
        }
        if (isPlaying != null) {
          isPlaying ? _controller.play() : _controller.pause();
        }
        if (currentTime != null) {
          _controller.seekTo(Duration(seconds: currentTime.toInt()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Birlikte İzle: $friendName'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.blueAccent,
              onReady: () {
                // Video hazır olduğunda yapılacak işlemler
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'YouTube Video URL girin',
                suffixIcon: IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () {
                    _playVideoFromUrl(_urlController.text);
                  },
                ),
              ),
              onSubmitted: (value) {
                _playVideoFromUrl(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _playVideoFromUrl(String url) {
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      setState(() {
        _controller.load(videoId);
        _urlController.text = url;
        _firestore.collection('sessions').doc(sessionId).set({
          'videoId': videoId,
          'isPlaying': true,
          'currentTime': 0,
        });
      });
    }
  }

  void _updateVideoState(YoutubePlayerValue value) {
    _firestore.collection('sessions').doc(sessionId).update({
      'isPlaying': value.isPlaying,
      'currentTime': value.position.inSeconds,
    });
  }

  Future<void> _endSession() async {
    await _firestore.collection('sessions').doc(sessionId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Oturum sonlandırıldı.')),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_videoStateListener);
    _controller.dispose();
    _urlController.dispose();
    super.dispose();
  }
}
