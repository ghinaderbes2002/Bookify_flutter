import 'package:bookify/controller/users/audio_player_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AudioPlayerScreen extends StatelessWidget {
  final String audioUrl;
  final String title;
  final String? coverUrl;

  const AudioPlayerScreen({
    super.key,
    required this.audioUrl,
    required this.title,
    this.coverUrl,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AudioPlayerControllerImp());
    controller.setAudioUrl(audioUrl);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade700,
              Colors.teal.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: GetBuilder<AudioPlayerControllerImp>(
              builder: (controller) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: coverUrl != null
                            ? Image.network(
                                coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.teal.shade600,
                                    child: const Icon(
                                      Icons.music_note,
                                      size: 100,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.teal.shade600,
                                child: const Icon(
                                  Icons.music_note,
                                  size: 100,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 40),
                    Column(
                      children: [
                        Slider(
                          value: controller.position.inSeconds.toDouble(),
                          max: controller.duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            controller.seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.formatDuration(controller.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                controller.formatDuration(controller.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: controller.seekBackward,
                          icon: const Icon(Icons.replay_10),
                          iconSize: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 20),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: controller.playPause,
                            icon: Icon(
                              controller.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            iconSize: 48,
                            color: Colors.teal.shade700,
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          onPressed: controller.seekForward,
                          icon: const Icon(Icons.forward_10),
                          iconSize: 48,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    IconButton(
                      onPressed: controller.stop,
                      icon: const Icon(Icons.stop),
                      iconSize: 36,
                      color: Colors.white,
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
