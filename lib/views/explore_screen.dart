import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:convert';
import 'history_screen.dart';
import '../utils/database_helper.dart';
import '../utils/chatbot_service.dart';
import '../utils/ui_components.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _urlController = TextEditingController();
  bool _isLoading = false;
  String? _videoTitle;
  String? _videoThumbnailUrl;
  String? _audioFilePath;
  String? _transcription;
  Map<String, dynamic>? _analysisResult;

  Future<void> analyzeVideo(String url) async {
    setState(() {
      _isLoading = true;
      _audioFilePath = null;
      _transcription = null;
      _analysisResult = null;
    });

    try {
      var yt = YoutubeExplode();
      var videoId = VideoId.parseVideoId(url);
      if (videoId == null) {
        throw Exception('Invalid video URL');
      }

      var video = await yt.videos.get(videoId);

      // Check if the video duration is under 25 minutes
      if (video.duration != null && video.duration! > const Duration(minutes: 20)) {
        throw Exception('Video is longer than 20 minutes.');
      }

      setState(() {
        _videoTitle = video.title;
        _videoThumbnailUrl = video.thumbnails.highResUrl;
      });

      // Download the audio
      await _downloadAudio(yt, videoId);

      // Transcribe the audio
      if (_audioFilePath != null) {
        String audioUrl = await ChatbotService.uploadAudio(File(_audioFilePath!));
        _transcription = await ChatbotService.transcribeAudio(audioUrl);
      }

      // Analyze the transcription
      if (_transcription != null) {
        _analysisResult = await ChatbotService.analyzeTranscription(_transcription!);
      }

      // Save analysis data to database
      if (_videoTitle != null && _videoThumbnailUrl != null && _analysisResult != null) {
        await DatabaseHelper.instance.saveAnalysis(
          _videoTitle!,
          _videoThumbnailUrl!,
          jsonEncode(_analysisResult),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _downloadAudio(YoutubeExplode yt, String videoId) async {
    var manifest = await yt.videos.streamsClient.getManifest(videoId);
    var streamInfo = manifest.audioOnly.withHighestBitrate();
    if (streamInfo != null) {
      var stream = yt.videos.streamsClient.get(streamInfo);
      var tempDir = await getTemporaryDirectory();
      var filePath = '${tempDir.path}/audio.mp4';
      var file = File(filePath);
      var fileStream = file.openWrite();

      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();

      setState(() {
        _audioFilePath = filePath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Analysis'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.light
                      ? const Color(0xFF2B054E).withOpacity(1.0)
                      : const Color(0xFFF0EAF8).withOpacity(0.8),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to the Video Analysis Area!',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 24),
                    ),
                    const SizedBox(height: 13.0),
                    Text(
                      'Enter a YouTube URL to analyze the video for logical fallacies and manipulative tactics. Be patient and don\'t exit the page while it is loading. You may only analyze videos shorter than 20 minutes.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'YouTube URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  final url = _urlController.text;
                  if (url.isNotEmpty) {
                    analyzeVideo(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a YouTube URL')),
                    );
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Analyze Video'),
              ),
              if (_isLoading) const CircularProgressIndicator(),
              if (_videoTitle != null && _videoThumbnailUrl != null) ...[
                const SizedBox(height: 20),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    height: 150,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _videoThumbnailUrl!,
                            width: 150,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _videoTitle!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
              if (_analysisResult != null) ...[
                const SizedBox(height: 20),
                CircularProgressBar(riskProbability: _analysisResult!['risk_probability']),
                const SizedBox(height: 10),
                Text(
                  _analysisResult!['summary'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _analysisResult!['tactics'].length,
                  itemBuilder: (context, index) {
                    final tactic = _analysisResult!['tactics'][index];
                    return TacticCard(
                      name: tactic['name'],
                      severity: tactic['severity'],
                      description: tactic['description'],
                    );
                  },
                ),
              ],
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HistoryScreen()),
                  );
                },
                child: const Text('History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
