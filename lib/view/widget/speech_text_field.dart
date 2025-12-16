import 'dart:io';

import 'package:bookify/core/services/AudioRecorderService.dart';
import 'package:bookify/core/services/speech_api_service.dart';
import 'package:flutter/material.dart';


class SpeechTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final bool requiredField;

  const SpeechTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.requiredField = false,
  });

  @override
  State<SpeechTextField> createState() => _SpeechTextFieldState();
}

class _SpeechTextFieldState extends State<SpeechTextField> {
  final recorder = AudioRecorderService();

  bool isRecording = false;
  bool isLoading = false;

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

 Future<void> _toggleRecording() async {
    if (!isRecording) {
      await recorder.startRecording();
      setState(() => isRecording = true);
    } else {
    final path = await recorder.stopRecording();

      if (path == null) {
        setState(() {
          isRecording = false;
          isLoading = false;
        });
        return;
      }

      setState(() {
        isRecording = false;
        isLoading = true;
      });

      final text = await SpeechApiService.sendAudio(File(path));

      widget.controller.text = (widget.controller.text + " " + text).trim();

      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        labelText: widget.requiredField ? '${widget.label} *' : widget.label,
        hintText: widget.hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.teal, width: 2),
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.red : Colors.teal,
                ),
                onPressed: _toggleRecording,
              ),
      ),
    );
  }
}
