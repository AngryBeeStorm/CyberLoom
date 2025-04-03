import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/recording_service.dart';
import '../utils/chatbot_service.dart';


class TopicRecordingScreen extends StatefulWidget {
 final String title;
 final String description;
 final String prompt;


 const TopicRecordingScreen({
   super.key,
   required this.title,
   required this.description,
   required this.prompt,
 });


 @override
 _TopicRecordingScreenState createState() => _TopicRecordingScreenState();
}


class _TopicRecordingScreenState extends State<TopicRecordingScreen> {
 final RecordingService _recordingService = RecordingService(
   recorder: AudioRecorder(),
   assemblyApiKey: '447f85ca6e6847948679ed6b48268802', // Replace with your AssemblyAI API key
 );


 bool _isRecording = false;
 String _transcription = '';
 String _recordingPath = '';
 bool _isProcessing = false;
 bool _isAnalyzing = false;
 Map<String, double>? _analysisResults;
 String _openAiResponse = '';


 Future<void> _startRecording() async {
   try {
     final recordingPath = await _recordingService.startRecording();
     setState(() {
       _isRecording = true;
       _isProcessing = false;
       _isAnalyzing = false;
       _recordingPath = recordingPath;
     });
   } catch (e) {
     print('Error starting recording: $e');
   }
 }


 Future<void> _stopRecording() async {
   await _recordingService.stopRecording();
   setState(() {
     _isRecording = false;
     _isProcessing = true;
   });
   if (_recordingPath.isNotEmpty) {
     await _transcribeRecording();
   } else {
     print('Failed to stop recording and get the file path');
   }
 }


 Future<void> _transcribeRecording() async {
   try {
     final transcription = await _recordingService.transcribeRecording(_recordingPath);
     setState(() {
       _transcription = transcription;
       _isProcessing = false;
     });
     await _analyzeTranscription(transcription);
   } catch (e) {
     print('Error during transcription: $e');
     setState(() {
       _isProcessing = false;
     });
   }
 }


 Future<void> _analyzeTranscription(String transcription) async {
   setState(() {
     _isAnalyzing = true;
   });


   try {
     final analysisResults = await ChatbotService.analyzeSpeech(transcription, widget.prompt);
     setState(() {
       _analysisResults = analysisResults;
       _openAiResponse = analysisResults.toString();
       _isAnalyzing = false;
     });
   } catch (e) {
     print('Error analyzing transcription: $e');
     setState(() {
       _isAnalyzing = false;
       _openAiResponse = 'Error: $e';
     });
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(widget.title),
     ),
     body: Padding(
       padding: const EdgeInsets.all(16.0),
       child: SingleChildScrollView(
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               widget.description,
               style: Theme.of(context).textTheme.headlineSmall,
             ),
             const SizedBox(height: 20),
             Text(
               widget.prompt,
               style: Theme.of(context).textTheme.bodyLarge,
             ),
             const SizedBox(height: 20),
             Center(
               child: GestureDetector(
                 onTap: _isRecording ? _stopRecording : _startRecording,
                 child: CircleAvatar(
                   radius: 40,
                   backgroundColor: _isRecording ? Colors.red : Colors.green,
                   child: Icon(
                     _isRecording ? Icons.stop : Icons.mic,
                     size: 40,
                     color: Colors.white,
                   ),
                 ),
               ),
             ),
             if (_isProcessing) const CircularProgressIndicator(),
             const SizedBox(height: 20),
             Text(
               'Transcription:',
               style: Theme.of(context).textTheme.headlineSmall,
             ),
             const SizedBox(height: 10),
             Text(_transcription),
             if (_isAnalyzing) const CircularProgressIndicator(),
             if (_analysisResults != null) ...[
               const SizedBox(height: 20),
               Center(
                 child: SizedBox(
                   width: 300,
                   height: 300,
                   child: RadarChart(
                     RadarChartData(
                       dataSets: [
                         RadarDataSet(
                           dataEntries: [
                             RadarEntry(value: _analysisResults!['conciseness'] ?? 5.0),
                             RadarEntry(value: _analysisResults!['logic_use'] ?? 5.0),
                             RadarEntry(value: _analysisResults!['clarity'] ?? 5.0),
                             RadarEntry(value: _analysisResults!['appeal'] ?? 5.0),
                             RadarEntry(value: _analysisResults!['focus'] ?? 5.0),
                           ],
                           borderColor: Theme.of(context).colorScheme.secondary,
                           fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                           borderWidth: 2,
                         ),
                         RadarDataSet(
                           dataEntries: [
                             const RadarEntry(value: 10),
                             const RadarEntry(value: 10),
                             const RadarEntry(value: 10),
                             const RadarEntry(value: 5),
                             const RadarEntry(value: 5),
                           ],
                           borderColor: Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                           fillColor: Theme.of(context).colorScheme.secondary.withOpacity(0.0),
                           borderWidth: 2,
                         ),
                       ],
                       radarBackgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.8),
                       borderData: FlBorderData(show: false),
                       radarShape: RadarShape.circle,
                       titleTextStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
                       getTitle: (index, angle) {
                         switch (index) {
                           case 0:
                             return const RadarChartTitle(text: 'Conciseness');
                           case 1:
                             return const RadarChartTitle(text: 'Logic Use');
                           case 2:
                             return const RadarChartTitle(text: 'Clarity');
                           case 3:
                             return const RadarChartTitle(text: 'Appeal');
                           case 4:
                             return const RadarChartTitle(text: 'Focus');
                           default:
                             return const RadarChartTitle(text: '');
                         }
                       },
                       tickCount: 1,
                       ticksTextStyle: const TextStyle(
                         color: Colors.black,
                         fontSize: 10,
                       ),
                       tickBorderData: const BorderSide(
                         color: Colors.black,
                         width: 1,
                       ),
                       gridBorderData: const BorderSide(
                         color: Colors.black,
                         width: 1,
                       ),
                     ),
                   ),
                 ),
               ),
             ],
             const SizedBox(height: 20),
             if (_openAiResponse.isNotEmpty) Text(_openAiResponse),
           ],
         ),
       ),
     ),
   );
 }
}
