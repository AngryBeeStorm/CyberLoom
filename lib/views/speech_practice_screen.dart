import 'package:flutter/material.dart';
import 'topic_recording_screen.dart';
import '../utils/speech_topic_service.dart';


class SpeechPracticeScreen extends StatelessWidget {
 const SpeechPracticeScreen({super.key});


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Speech Practice'),
     ),
     body: FutureBuilder<List<SpeechTopic>>(
       future: SpeechTopicService().loadTopics(),
       builder: (context, snapshot) {
         if (snapshot.connectionState == ConnectionState.waiting) {
           return const Center(child: CircularProgressIndicator());
         } else if (snapshot.hasError) {
           return Center(child: Text('Error: ${snapshot.error}'));
         } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
           return const Center(child: Text('No topics available'));
         }


         final topics = snapshot.data!;
         return Padding(
           padding: const EdgeInsets.all(16.0),
           child: Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             children: [
               Text(
                 'What would you like to chat about today? Pick a topic and practice your speaking skills!',
                 style: Theme.of(context).textTheme.headlineSmall,
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 20),
               Expanded(
                 child: GridView.builder(
                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                     crossAxisCount: 2,
                     crossAxisSpacing: 8.0,
                     mainAxisSpacing: 8.0,
                   ),
                   itemCount: topics.length,
                   itemBuilder: (context, index) {
                     final topic = topics[index];
                     return _buildTopicCard(
                       context,
                       topic.title,
                       topic.description,
                       topic.prompt,
                     );
                   },
                 ),
               ),
             ],
           ),
         );
       },
     ),
   );
 }


 Widget _buildTopicCard(BuildContext context, String title, String description, String prompt) {
   return Card(
     child: InkWell(
       onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(
             builder: (context) => TopicRecordingScreen(
               title: title,
               description: description,
               prompt: prompt,
             ),
           ),
         );
       },
       child: Container(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: Theme.of(context).textTheme.titleLarge,
             ),
             const SizedBox(height: 8),
             Text(description, style: Theme.of(context).textTheme.bodyMedium),
           ],
         ),
       ),
     ),
   );
 }
}
