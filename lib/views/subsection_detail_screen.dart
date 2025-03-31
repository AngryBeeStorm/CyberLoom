import 'package:flutter/material.dart';
import '../utils/models.dart';


class SubsectionDetailScreen extends StatefulWidget {
 final Subsection subsection;
 final int lessonId;
 final Function(int) onSubsectionCompleted;
 final List<Subsection> subsections;


 const SubsectionDetailScreen({
   super.key,
   required this.subsection,
   required this.lessonId,
   required this.onSubsectionCompleted,
   required this.subsections,
 });
 
 @override
 _SubsectionDetailScreenState createState() => _SubsectionDetailScreenState();
}
class _SubsectionDetailScreenState extends State<SubsectionDetailScreen> {
 late int currentIndex;
 double _textSize = 20.0;
 int? _selectedAnswerIndex;
 bool _isCorrectAnswer = false;
 
 @override
 void initState() {
   super.initState();
   currentIndex = widget.subsections.indexWhere((sub) => sub.id == widget.subsection.id);
   if (widget.subsections[currentIndex].quiz == null) {
     _markSubsectionCompleted();
   }
 }
 void _markSubsectionCompleted() {
   widget.onSubsectionCompleted(widget.subsections[currentIndex].id);
 }


 void _goToNextSubsection() {
   if (currentIndex < widget.subsections.length - 1) {
     setState(() {
       currentIndex++;
       _selectedAnswerIndex = null;
       _isCorrectAnswer = false;
     });
     if (widget.subsections[currentIndex].quiz == null) {
       _markSubsectionCompleted();
     }
   } else {
     _showCompletionDialog();
   }
 }


 void _goToPreviousSubsection() {
   if (currentIndex > 0) {
     setState(() {
       currentIndex--;
       _selectedAnswerIndex = null;
       _isCorrectAnswer = false;
     });
     if (widget.subsections[currentIndex].quiz == null) {
       _markSubsectionCompleted();
     }
   }
 }


 void _adjustTextSize(double newSize) {
   setState(() {
     _textSize = newSize;
   });
 }


 String _getTextSizeDescription() {
   return _textSize.toString();
 }


 void _checkAnswer(int selectedIndex) {
   final quiz = widget.subsections[currentIndex].quiz!;
   setState(() {
     _selectedAnswerIndex = selectedIndex;
     _isCorrectAnswer = selectedIndex == quiz.correctAnswerIndex;
     if (_isCorrectAnswer) {
       _markSubsectionCompleted();
     }
   });
 }


 void _tryAgain() {
   setState(() {
     _selectedAnswerIndex = null;
     _isCorrectAnswer = false;
   });
 }


 void _showCompletionDialog() {
   showDialog(
     context: context,
     builder: (context) => AlertDialog(
       title: Text(
         'Congratulations!',
         textAlign: TextAlign.center,
         style: TextStyle(
           fontSize: 20,
           fontWeight: FontWeight.bold,
           color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
         ),
       ),
       backgroundColor: Theme.of(context).colorScheme.surface,
       content: Text(
           'You now know a little more than you did before!',
           textAlign: TextAlign.left,
           style: TextStyle(
             fontSize: 20,
             fontWeight: FontWeight.bold,
             color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
           ),
         ),
       actions: [
         TextButton(
           onPressed: () {
             Navigator.pop(context);
             Navigator.pop(context); // Go back to the lesson detail screen
           },
           child: Text(
             'Awesome!',
             textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.bold,
               color: Theme.of(context).colorScheme.secondary,
             ),
           ),
         ),
       ],
     ),
   );
 }


 @override
 Widget build(BuildContext context) {
   final currentSubsection = widget.subsections[currentIndex];
   final quiz = currentSubsection.quiz;


   return Scaffold(
     appBar: AppBar(
       title: Text(currentSubsection.title),
       leading: IconButton(
         icon: const Icon(Icons.arrow_back),
         onPressed: () {
           Navigator.pop(context);
         },
       ),
       actions: [
         IconButton(
           icon: const Icon(Icons.text_fields),
           onPressed: () {
             showDialog(
               context: context,
               builder: (context) => StatefulBuilder(
                 builder: (context, setState) {
                   return AlertDialog(
                     title: const Text('Adjust Text Size'),
                     content: Row(
                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.remove_circle),
                           onPressed: () {
                             if (_textSize > 18.0) {
                               setState(() {
                                 _textSize -= 4.0;
                               });
                               _adjustTextSize(_textSize);
                             }
                           },
                         ),
                         Text(
                           _getTextSizeDescription(),
                           style: const TextStyle(fontSize: 18),
                         ),
                         IconButton(
                           icon: const Icon(Icons.add_circle),
                           onPressed: () {
                             if (_textSize < 26.0) {
                               setState(() {
                                 _textSize += 4.0;
                               });
                               _adjustTextSize(_textSize);
                             }
                           },
                         ),
                       ],
                     ),
                     actions: [
                       TextButton(
                         onPressed: () {
                           Navigator.pop(context);
                         },
                         child: const Text('Done'),
                       ),
                     ],
                   );
                 },
               ),
             );
           },
         ),
         if (currentIndex > 0)
           IconButton(
             icon: const Icon(Icons.arrow_back_ios),
             onPressed: _goToPreviousSubsection,
           ),
         if (currentIndex < widget.subsections.length - 1 && (quiz == null || _isCorrectAnswer))
           IconButton(
             icon: const Icon(Icons.arrow_forward_ios),
             onPressed: _goToNextSubsection,
           ),
       ],
     ),
     body: SingleChildScrollView(
       child: Padding(
         padding: const EdgeInsets.all(16.0),
         child: Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Center(
               child: Text(
                 currentSubsection.title,
                 style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
               ),
             ),
             const SizedBox(height: 16),
             if (quiz != null) ...[
               Center(
                 child: Text(
                   quiz.question,
                   style: const TextStyle(fontSize: 20),
                 ),
               ),
               const SizedBox(height: 16),
               ...List.generate(quiz.answers.length, (index) {
                 return GestureDetector(
                   onTap: _selectedAnswerIndex == null ? () => _checkAnswer(index) : null,
                   child: Container(
                     margin: const EdgeInsets.symmetric(vertical: 8.0),
                     padding: const EdgeInsets.all(16.0),
                     decoration: BoxDecoration(
                       color: _selectedAnswerIndex == index
                           ? (_isCorrectAnswer ? Theme.of(context).colorScheme.secondary : Colors.red)
                           : Theme.of(context).cardColor,
                       borderRadius: BorderRadius.circular(8.0),
                       border: Border.all(
                         color: _selectedAnswerIndex == index
                             ? (_isCorrectAnswer ? Theme.of(context).colorScheme.secondary : Colors.red)
                             : Colors.grey,
                         width: 2.0,
                       ),
                     ),
                     child: Center(
                       child: Text(
                         quiz.answers[index],
                         style: const TextStyle(fontSize: 18),
                       ),
                     ),
                   ),
                 );
               }),


               const SizedBox(height: 16),
               Center(
                 child: ElevatedButton(
                   style: ElevatedButton.styleFrom(
                     backgroundColor: Theme.of(context).colorScheme.secondary,
                     foregroundColor: Theme.of(context).colorScheme.onSecondary,
                   ),
                   onPressed: _isCorrectAnswer ? _goToNextSubsection : null,
                   child: Text(currentIndex == widget.subsections.length - 1 ? 'Complete Lesson' : 'Continue'),
                 ),
               ),


               const SizedBox(height: 2),
               if (!_isCorrectAnswer && _selectedAnswerIndex != null)
                 Center(
                   child: ElevatedButton(
                     onPressed: _tryAgain,
                     style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).colorScheme.tertiary,
                       foregroundColor: Theme.of(context).colorScheme.onSecondary,
                     ),
                     child: const Text('Try Again'),
                   ),
                 ),




             ] else ...[
               Text(
                 currentSubsection.content,
                 style: TextStyle(fontSize: _textSize),
               ),
               const SizedBox(height: 16),
               Center(
                 child: ElevatedButton(
                   onPressed: _goToNextSubsection,


                   style: ElevatedButton.styleFrom(
                       backgroundColor: Theme.of(context).colorScheme.secondary,
                       foregroundColor: Theme.of(context).colorScheme.onSecondary,


                   ),
                   child: const Text('Continue')
                 ),
               ),
             ],
           ],
         ),
       ),
     ),
   );
 }
}
