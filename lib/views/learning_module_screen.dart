import 'package:flutter/material.dart';
import '../utils/models.dart';
import '../utils/json_data_helper.dart';
import 'lesson_detail_screen.dart';
import 'module_detail_screen.dart';


class LearningModuleScreen extends StatefulWidget {
 final Function toggleTheme;


 const LearningModuleScreen({super.key, required this.toggleTheme});


 @override
 _LearningModuleScreenState createState() => _LearningModuleScreenState();
}


class _LearningModuleScreenState extends State<LearningModuleScreen> {
 List<Module> modules = [];


 @override
 void initState() {
   super.initState();
   _loadData();
 }


 Future<void> _loadData() async {
   final jsonModules = await JsonDataHelper.loadModules();
   setState(() {
     modules = jsonModules;
   });
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Row(
         mainAxisAlignment: MainAxisAlignment.spaceBetween,
         children: [
           Text("Learning Modules"),


         ],
       ),
     ),
     body: modules.isEmpty
         ? const Center(child: CircularProgressIndicator())
         : ListView.builder(
       itemCount: modules.length + 1, // Add 1 for the header
       itemBuilder: (context, index) {
         if (index == 0) {
           return const LearningHeader();
         } else {
           final module = modules[index - 1];
           return ModuleSection(module: module);
         }
       },
     ),
   );
 }
}


class LearningHeader extends StatelessWidget {
 const LearningHeader({super.key});


 @override
 Widget build(BuildContext context) {
   return Container(
     decoration: BoxDecoration(
       color: Theme.of(context).brightness == Brightness.light ? const Color(0xFF2B054E).withOpacity(1.0) : const Color(0xFFF0EAF8).withOpacity(0.8),
       borderRadius: const BorderRadius.only(
         bottomLeft: Radius.circular(10),
         bottomRight: Radius.circular(10),
       ),
     ),
     padding: const EdgeInsets.all(16.0),
     child: Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'Welcome to the learning area!',
           style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 26),
         ),
         const SizedBox(height: 13.0),
         Text(
           'Look through the lessons on display and tap whichever catches your eye. Obtain useful skills that you can then train in our practice section!',
           style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 14),
         ),
       ],
     ),
   );
 }
}


class ModuleSection extends StatelessWidget {
 final Module module;


 const ModuleSection({super.key, required this.module});


 @override
 Widget build(BuildContext context) {
   return Column(
     crossAxisAlignment: CrossAxisAlignment.start,
     children: [
       Padding(
         padding: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 1.0),
         child: Row(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           children: [
             Text(
               module.title,
               style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
             ),
             IconButton(
               icon: const Icon(Icons.arrow_forward),
               onPressed: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => ModuleDetailScreen(module: module)),
                 );
               },
             ),
           ],
         ),
       ),
       SizedBox(
         height: 190,
         child: ListView.builder(
           scrollDirection: Axis.horizontal,
           itemCount: module.lessons.length,
           itemBuilder: (context, index) => LessonCard(lesson: module.lessons[index]),
         ),
       ),
     ],
   );
 }
}


class LessonCard extends StatelessWidget {
 final Lesson lesson;


 const LessonCard({super.key, required this.lesson});


 @override
 Widget build(BuildContext context) {
   return GestureDetector(
     onTap: () {
       Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => LessonDetailScreen(lesson: lesson)),
       );
     },
     child: Container(
       width: 230,
       height: 200,
       margin: const EdgeInsets.all(10),
       decoration: BoxDecoration(
         border: Border.all(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), width: 4.0),
         borderRadius: BorderRadius.circular(15),
         boxShadow: [
           BoxShadow(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.40), offset: const Offset(6.0, 10.0)),
         ],
         image: DecorationImage(
           image: AssetImage(lesson.image),
           fit: BoxFit.cover,
         ),
       ),
       child: Stack(
         children: [
           Positioned(
             bottom: 0,
             left: 0,
             right: 0,
             child: Container(
               decoration: BoxDecoration(
                 color: Theme.of(context).colorScheme.primary.withOpacity(0.83),
                 borderRadius: const BorderRadius.only(
                   bottomLeft: Radius.circular(8),
                   bottomRight: Radius.circular(8),
                 ),
               ),
               padding: const EdgeInsets.all(8.0),
               child: Text(
                 lesson.title,
                 style: const TextStyle(fontSize: 16, color: Colors.white),
                 softWrap: true,
                 //overflow: TextOverflow.ellipsis,
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }
}
