import 'package:audioplayers/audioplayers.dart';
import 'package:bookify/core/constant/App_link.dart';
import 'package:get/get.dart';

abstract class AudioPlayerController extends GetxController {
  playPause();
  stop();
  seek(Duration position);
}

class AudioPlayerControllerImp extends AudioPlayerController {
  final AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  String audioUrl = '';

  @override
  void onInit() {
    super.onInit();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    audioPlayer.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      update();
    });

    audioPlayer.onDurationChanged.listen((newDuration) {
      duration = newDuration;
      update();
    });

    audioPlayer.onPositionChanged.listen((newPosition) {
      position = newPosition;
      update();
    });

    audioPlayer.onPlayerComplete.listen((event) {
      position = Duration.zero;
      isPlaying = false;
      update();
    });
  }

  void setAudioUrl(String url) {
    // Build full URL if it's a relative path
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final serverConfig = ServerConfig();
      audioUrl = '${serverConfig.serverLink}$url';
    } else {
      audioUrl = url;
    }
    print('Audio URL set to: $audioUrl');
  }

  @override
  Future<void> playPause() async {
    if (isPlaying) {
      await audioPlayer.pause();
    } else {
      await audioPlayer.play(UrlSource(audioUrl));
    }
  }

  @override
  Future<void> stop() async {
    await audioPlayer.stop();
    position = Duration.zero;
    update();
  }

  @override
  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  void seekForward() {
    final newPosition = position + const Duration(seconds: 10);
    seek(newPosition > duration ? duration : newPosition);
  }

  void seekBackward() {
    final newPosition = position - const Duration(seconds: 10);
    seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
