// recording_service.dart

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'dart:convert';

class RecordingService {
  final AudioRecorder recorder;
  final String assemblyApiKey;

  RecordingService({required this.recorder, required this.assemblyApiKey});

  Future<String> startRecording() async {
    if (await recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recordings';
      final recordingPath = '$path/temp.wav';

      // Ensure the directory exists
      await Directory(path).create(recursive: true);

      await recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: recordingPath,
      );

      print('Recording started: $recordingPath');
      return recordingPath;
    } else {
      throw Exception('Microphone permission not granted');
    }
  }

  Future<void> stopRecording() async {
    await recorder.stop();
  }

  Future<String> transcribeRecording(String recordingPath) async {
    final audioFile = File(recordingPath);

    // Step 1: Upload the audio file
    final uploadResponse = await http.post(
      Uri.parse('https://api.assemblyai.com/v2/upload'),
      headers: {
        'authorization': assemblyApiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: audioFile.readAsBytesSync(),
    );

    if (uploadResponse.statusCode == 200) {
      final uploadResult = json.decode(uploadResponse.body);
      final audioUrl = uploadResult['upload_url'];

      // Step 2: Request transcription
      final transcriptResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/transcript'),
        headers: {
          'authorization': assemblyApiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({'audio_url': audioUrl}),
      );

      if (transcriptResponse.statusCode == 200) {
        final transcriptResult = json.decode(transcriptResponse.body);
        final transcriptId = transcriptResult['id'];

        // Step 3: Poll for the transcription result
        return await _pollTranscriptionResult(transcriptId);
      } else {
        throw Exception('Transcription request failed: ${transcriptResponse.body}');
      }
    } else {
      throw Exception('Audio upload failed: ${uploadResponse.body}');
    }
  }

  Future<String> _pollTranscriptionResult(String transcriptId) async {
    final uri = Uri.parse('https://api.assemblyai.com/v2/transcript/$transcriptId');
    while (true) {
      final response = await http.get(uri, headers: {'authorization': assemblyApiKey});
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'completed') {
          return result['text'];
        } else if (result['status'] == 'failed') {
          throw Exception('Transcription failed: ${result['error']}');
        }
      } else {
        throw Exception('Error polling transcription result: ${response.body}');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }
}
