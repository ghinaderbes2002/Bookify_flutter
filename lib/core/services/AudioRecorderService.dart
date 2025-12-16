import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioRecorderService {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  Future<void> init() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  Future<void> startRecording() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = '${dir.path}/recorded_audio.wav';

    await _recorder.startRecorder(
      toFile: path,
      codec: Codec.pcm16WAV, // WAV PCM 16-bit
      sampleRate: 16000, // 16 kHz (ممتاز لـ Vosk)
      numChannels: 1, // Mono
    );
  }

  /// 🔑 مهم: نرجّع مسار الملف
  Future<String?> stopRecording() async {
    return await _recorder.stopRecorder();
  }

  Future<void> dispose() async {
    await _recorder.closeRecorder();
  }
}
