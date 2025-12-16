import 'dart:io';
import 'package:dio/dio.dart';

class SpeechApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://10.100.164.196:5000', // عدّل حسب جهازك
            baseUrl: 'http://192.168.0.8:5000', // عدّل حسب جهازك

      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  static Future<String> sendAudio(File audioFile) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        audioFile.path,
        filename: 'audio.wav',
      ),
    });

    final response = await _dio.post('/speech-to-text', data: formData);

    return response.data['text'] ?? '';
  }
}
