import 'dart:io';
import 'package:bookify/core/services/AudioRecorderService.dart';
import 'package:flutter/material.dart';
import 'package:bookify/core/services/speech_api_service.dart';

class SpeechToTextPage extends StatefulWidget {
  @override
  State<SpeechToTextPage> createState() => _SpeechToTextPageState();
}

class _SpeechToTextPageState extends State<SpeechToTextPage> {
  final AudioRecorderService recorder = AudioRecorderService();

  bool isRecording = false;
  String recognizedText = '';

  @override
  void initState() {
    super.initState();
    recorder.init();
  }

  @override
  void dispose() {
    recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: Icon(isRecording ? Icons.stop : Icons.mic),
              label: Text(isRecording ? 'Stop Recording' : 'Start Recording'),
              onPressed: () async {
                if (!isRecording) {
                  await recorder.startRecording();
                  setState(() => isRecording = true);
                } else {
                  final path = await recorder.stopRecording();
                  setState(() => isRecording = false);

                  if (path != null) {
                    setState(() {
                      recognizedText = '⏳ Processing...';
                    });

                    try {
                      final text = await SpeechApiService.sendAudio(File(path));

                      setState(() {
                        recognizedText = text.isEmpty
                            ? '❌ No speech detected'
                            : text;
                      });
                    } catch (e) {
                      setState(() {
                        recognizedText = '❌ Error: $e';
                      });
                    }
                  }
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Recognized Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  recognizedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
