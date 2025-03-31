import 'package:flutter/material.dart';
import 'speech_practice_screen.dart';
import 'debate_selection_screen.dart';


class PracticeScreen extends StatefulWidget {
 const PracticeScreen({super.key});


 @override
 _PracticeScreenState createState() => _PracticeScreenState();
}


class _PracticeScreenState extends State<PracticeScreen> {
 @override
 Widget build(BuildContext context) {
   return DefaultTabController(
     length: 2,
     child: Scaffold(
       appBar: AppBar(


         title: const Text('Practice'),
         bottom: TabBar(
           labelColor: Theme.of(context).colorScheme.secondary,
           unselectedLabelColor: Theme.of(context).colorScheme.onPrimary,
           tabs: const [
             Tab(text: 'Negotiation'),
             Tab(text: 'Speech Practice'),
           ],
         ),
       ),
       body: const TabBarView(
         children: [
           DebateSelectionScreen(),
           SpeechPracticeScreen(),
         ],
       ),
     ),
   );
 }
}
