import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../utils/models.dart';
import '../utils/database_helper.dart';
import 'subsection_detail_screen.dart';


class LessonDetailScreen extends StatefulWidget {
 final Lesson lesson;


 const LessonDetailScreen({super.key, required this.lesson});


 @override
 _LessonDetailScreenState createState() => _LessonDetailScreenState();
}


class _LessonDetailScreenState extends State<LessonDetailScreen> {
 late DatabaseHelper _dbHelper;
 List<int> _completedSubsections = [];
 int _lastReadSection = 0;
 bool _isCompleted = false;
  
 @override
 void initState() {
   super.initState();
   _dbHelper = DatabaseHelper.instance;
   _loadUserData();
 }
 Future<void> _loadUserData() async {
   final userData = await _dbHelper.fetchUserData(widget.lesson.id);
   final completedSubsections = await _dbHelper.fetchCompletedSubsections(widget.lesson.id);
   setState(() {
     _lastReadSection = (userData['lastReadSection'] ?? 0).clamp(0, widget.lesson.subsections.length - 1);
     _completedSubsections = completedSubsections;
     _isCompleted = _completedSubsections.length == widget.lesson.subsections.length;
   });
 }
 void _startLesson() {
   if (_isCompleted) {
     _showResetProgressDialog();
   } else {
     _navigateToSubsection(_lastReadSection);
   }
 }
 void _onSubsectionCompleted(int subsectionId) async {
   if (!_completedSubsections.contains(subsectionId)) {
     await _dbHelper.markSubsectionCompleted(widget.lesson.id, subsectionId);
     final completedSubsections = await _dbHelper.fetchCompletedSubsections(widget.lesson.id);
     setState(() {
       _completedSubsections = completedSubsections;
       _lastReadSection = _completedSubsections.isNotEmpty ? widget.lesson.subsections.indexWhere((s) => s.id == _completedSubsections.last) : 0;
       _isCompleted = _completedSubsections.length == widget.lesson.subsections.length;
     });
     await _dbHelper.updateUserData(widget.lesson.id, _lastReadSection, _isCompleted);
   }
 }
 double _getCompletionPercentage() {
   final totalSubsections = widget.lesson.subsections.length;
   if (totalSubsections == 0) return 0.0;
   final completionPercentage = _completedSubsections.length / totalSubsections;
   return completionPercentage.clamp(0.0, 1.0);  // Ensure the value is between 0.0 and 1.0
 }
 void _showResetProgressDialog() {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Reset Progress'),
       content: const Text('You have completed this lesson. Do you want to reset your progress and start again?'),
       actions: [
         TextButton(
           onPressed: () {
             Navigator.pop(context);
           },
           child: const Text('Cancel'),
         ),
         TextButton(
           onPressed: () {
             _resetProgress();
             Navigator.pop(context);
           },
           child: const Text('Reset'),
         ),
       ],
     ),
   );
 }
 void _resetProgress() async {
   await _dbHelper.resetLessonProgress(widget.lesson.id);
   setState(() {
     _completedSubsections = [];
     _lastReadSection = 0;
     _isCompleted = false;
   });
 }
 void _navigateToSubsection(int index) {
   if (index >= 0 && index < widget.lesson.subsections.length) {
     Navigator.push(
       context,
       MaterialPageRoute(
         builder: (context) => SubsectionDetailScreen(
           subsection: widget.lesson.subsections[index],
           lessonId: widget.lesson.id,
           onSubsectionCompleted: _onSubsectionCompleted,
           subsections: widget.lesson.subsections,
         ),
       ),
     );
   }
 }


 void _showCompletionDialog() {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: const Text('Congratulations!'),
       alignment: Alignment.center,
       surfaceTintColor: Theme.of(context).colorScheme.tertiary,
       content: Text(
         'You now know a little more than you did before!',
         textAlign: TextAlign.center,
         style: TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
           color: Theme.of(context).colorScheme.primary,
         ),
       ),
       actions: [
         Center(
           child: TextButton(
             onPressed: () {
               Navigator.pop(context);
               Navigator.pop(context);
             },
             child: const Text('Awesome!'),
           ),
         ),
       ],
       backgroundColor: Theme.of(context).colorScheme.surface,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
     ),
   );
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Lesson Details - ${widget.lesson.title}'),
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () {
           Navigator.pop(context);
         },
       ),
     ),
     body: SingleChildScrollView(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           Stack(
             children: [
               Image.asset(
                 widget.lesson.image,
                 width: double.infinity,
                 height: 320,
                 fit: BoxFit.cover,
               ),
               Positioned(
                 bottom: 0,
                 left: 0,
                 right: 0,
                 child: Container(
                   color: Colors.black.withOpacity(0.7),
                   padding: const EdgeInsets.all(19.0),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         widget.lesson.title,
                         style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white),
                       ),
                       const SizedBox(height: 8.0),
                       Text(
                         widget.lesson.description,
                         style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                       ),
                     ],
                   ),
                 ),
               ),
             ],
           ),
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Row(
               children: [
                 Expanded(
                   flex: 3,
                   child: LinearPercentIndicator(
                     lineHeight: 24.0,
                     animation: true,
                     animationDuration: 1500,
                     percent: _getCompletionPercentage(),
                     center: Text(
                       "${(_getCompletionPercentage() * 100).toStringAsFixed(1)}%",
                       style: const TextStyle(fontSize: 12, color: Colors.white),
                     ),
                     backgroundColor: Theme.of(context).colorScheme.onSecondary.withOpacity(0.5),
                     progressColor: Theme.of(context).colorScheme.secondary,
                     barRadius: const Radius.circular(16.0),
                   ),
                 ),
                 const SizedBox(width: 8.0),
                 Expanded(
                   flex: 1,
                   child: FloatingActionButton(
                     splashColor: Theme.of(context).colorScheme.secondaryContainer,
                     onPressed: _startLesson,
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                     child: const Icon(Icons.play_arrow, size: 40),
                   ),
                 ),
               ],
             ),
           ),
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               children: widget.lesson.subsections.map((subsection) => _buildSubsectionCard(context, subsection)).toList(),
             ),
           ),
         ],
       ),
     ),
   );
 }


 Widget _buildSubsectionCard(BuildContext context, Subsection subsection) {
   int subsectionIndex = widget.lesson.subsections.indexOf(subsection);
   bool isCompleted = _completedSubsections.contains(subsection.id);
   bool isLocked = (subsectionIndex > _lastReadSection) && !_completedSubsections.contains(widget.lesson.subsections[subsectionIndex - 1].id);
   return Card(
     child: ListTile(
       leading: Icon(
         subsection.quiz == null ? Icons.book : Icons.question_mark,
         color: isLocked ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38) : Theme.of(context).colorScheme.onSurface,
       ),
       title: Text(
         subsection.title,
         style: TextStyle(
           fontSize: 18,
           fontWeight: FontWeight.bold,
           color: isLocked ? Theme.of(context).colorScheme.onSurface.withOpacity(0.38) : Theme.of(context).colorScheme.onSurface,
         ),
       ),
       trailing: isCompleted ? Icon(Icons.check, color: Theme.of(context).colorScheme.secondary) : null,
       subtitle: Text(
         isLocked ? 'Locked' : 'Tap to read more',
         style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
       ),
       onTap: isLocked
           ? null
           : () {
         _navigateToSubsection(subsectionIndex);
       },
     ),
   );
 }
}
