import 'package:flutter/material.dart';
import '../utils/models.dart';
import 'lesson_detail_screen.dart';


class ModuleDetailScreen extends StatelessWidget {
 final Module module;


 const ModuleDetailScreen({super.key, required this.module});


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text(module.title),
     ),
     body: ListView.builder(
       itemCount: module.lessons.length,
       itemBuilder: (context, index) {
         final lesson = module.lessons[index];
         return GestureDetector(
           onTap: () {
             Navigator.push(
               context,
               MaterialPageRoute(builder: (context) => LessonDetailScreen(lesson: lesson)),
             );
           },
           child: Container(
             margin: const EdgeInsets.all(5),
             padding: const EdgeInsets.all(5),
             decoration: BoxDecoration(
               color: Theme.of(context).colorScheme.surface,
               borderRadius: BorderRadius.circular(15),
               boxShadow: [
                 BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3), offset: const Offset(2.0, 4.0)),
               ],
             ),
             child: Row(
               children: [
                 ClipRRect(
                   borderRadius: BorderRadius.circular(15.0),
                   child: Image.asset(
                     lesson.image,
                     height: 140,
                     width: 140,
                     fit: BoxFit.cover,
                   ),
                 ),
                 const SizedBox(width: 10),
                 Expanded(
                   child: Text(
                     lesson.title,
                     style: Theme.of(context).textTheme.titleLarge,
                   ),
                 ),
               ],
             ),
           ),
         );
       },
     ),
   );
 }
}
