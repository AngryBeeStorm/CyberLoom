import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DebateSetupScreen extends StatefulWidget {
  const DebateSetupScreen({Key? key}) : super(key: key);

  @override
  _DebateSetupScreenState createState() => _DebateSetupScreenState();
}

class _DebateSetupScreenState extends State<DebateSetupScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String _transcription = '';
  String _recordingPath = '';
  final String _assemblyApiKey = '447f85ca6e6847948679ed6b48268802'; // Replace with your AssemblyAI API key

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    bool hasPermission = await _recorder.hasPermission();
    if (hasPermission) {
      print('Microphone permission granted');
    } else {
      // Handle the case when the microphone permission is not granted
      print('Microphone permission not granted');
    }
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/recordings';
      _recordingPath = '$path/temp.wav';

      // Ensure the directory exists
      await Directory(path).create(recursive: true);

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.wav),
        path: _recordingPath,
      );
      setState(() {
        _isRecording = true;
      });
      print('Recording started: $_recordingPath');
    } else {
      // Handle the case when microphone permission is not granted
      print('Microphone permission not granted');
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    setState(() {
      _isRecording = false;
    });
    print('Recording stopped: $_recordingPath');
    if (_recordingPath.isNotEmpty) {
      await _uploadAndTranscribeAudio(File(_recordingPath));
    } else {
      print('Failed to stop recording and get the file path');
    }
  }

  Future<void> _uploadAndTranscribeAudio(File audioFile) async {
    try {
      // Step 1: Upload the audio file
      final uploadResponse = await http.post(
        Uri.parse('https://api.assemblyai.com/v2/upload'),
        headers: {
          'authorization': _assemblyApiKey,
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
            'authorization': _assemblyApiKey,
            'Content-Type': 'application/json',
          },
          body: json.encode({'audio_url': audioUrl}),
        );

        if (transcriptResponse.statusCode == 200) {
          final transcriptResult = json.decode(transcriptResponse.body);
          final transcriptId = transcriptResult['id'];

          // Step 3: Poll for the transcription result
          await _pollTranscriptionResult(transcriptId);
        } else {
          print('Transcription request failed: ${transcriptResponse.body}');
        }
      } else {
        print('Audio upload failed: ${uploadResponse.body}');
      }
    } catch (e) {
      print('Error during transcription: $e');
    }
  }

  Future<void> _pollTranscriptionResult(String transcriptId) async {
    final uri = Uri.parse('https://api.assemblyai.com/v2/transcript/$transcriptId');
    while (true) {
      final response = await http.get(uri, headers: {'authorization': _assemblyApiKey});
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['status'] == 'completed') {
          setState(() {
            _transcription = result['text'];
          });
          break;
        } else if (result['status'] == 'failed') {
          print('Transcription failed: ${result['error']}');
          break;
        }
      } else {
        print('Error polling transcription result: ${response.body}');
        break;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debate Setup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isRecording ? _stopRecording : _startRecording,
              child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Transcription:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(_transcription),
          ],
        ),
      ),
    );
  }
}
