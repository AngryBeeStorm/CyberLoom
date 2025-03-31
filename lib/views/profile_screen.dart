import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../utils/json_data_helper.dart';
import '../utils/models.dart';
import 'lesson_detail_screen.dart';
import 'learning_module_screen.dart';
import 'explore_screen.dart'; // Import ExploreScreen


class ProfileScreen extends StatefulWidget {
 final Function toggleTheme;


 const ProfileScreen({super.key, required this.toggleTheme});


 @override
 _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
 String? _userName;
 List<Lesson> _featuredLessons = [];


 @override
 void initState() {
   super.initState();
   _loadUserProfile();
   _loadFeaturedLessons();
 }


 Future<void> _loadUserProfile() async {
   DatabaseHelper dbHelper = DatabaseHelper.instance;
   Map<String, dynamic>? userProfile = await dbHelper.fetchUserProfile();
   setState(() {
     _userName = userProfile?['name'] ?? 'User';
   });
 }


 Future<void> _loadFeaturedLessons() async {
   final allLessons = await JsonDataHelper.loadAllLessons();
   setState(() {
     _featuredLessons = (allLessons.toList()..shuffle()).take(5).toList();  // Taking 5 random lessons for example
   });
 }




 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: const Text('Profile'),
       actions: [
         IconButton(
           padding: const EdgeInsets.fromLTRB(0, 0, 25, 0),
           icon: const Icon(Icons.brightness_6),
           onPressed: () {
             widget.toggleTheme();
           },
         ),
       ],
     ),
     body: SingleChildScrollView(
       child: Column(
         crossAxisAlignment: CrossAxisAlignment.start,
         children: [
           ProfileHeader(userName: _userName),
           Padding(
             padding: const EdgeInsets.all(16.0),
             child: Row(
               mainAxisAlignment: MainAxisAlignment.spaceBetween,
               children: [
                 const Text(
                   'Featured Lessons',
                   style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                 ),
                 IconButton(
                   icon: const Icon(Icons.arrow_forward),
                   onPressed: () {
                     Navigator.push(
                       context,
                       MaterialPageRoute(builder: (context) => LearningModuleScreen(toggleTheme: widget.toggleTheme)),
                     );
                   },
                 ),
               ],
             ),
           ),
           _buildFeaturedLessons(),
           const Padding(
             padding: EdgeInsets.all(16.0),
             child: Text(
               'Is there a video you would like to analyze?',
               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
             ),
           ),
           _buildVideoAnalysisCard(context),
         ],
       ),
     ),
   );
 }


 Widget _buildFeaturedLessons() {
   return SizedBox(
     height: 210,
     child: ListView.builder(
       scrollDirection: Axis.horizontal,
       itemCount: _featuredLessons.length,
       itemBuilder: (context, index) {
         final lesson = _featuredLessons[index];
         return LessonCard(lesson: lesson);
       },
     ),
   );
 }


}
Widget _buildVideoAnalysisCard(BuildContext context) {
 return Padding(
   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
   child: Card(
     shape: RoundedRectangleBorder(
       borderRadius: BorderRadius.circular(15),
     ),
     elevation: 4,
     child: ListTile(
       contentPadding: const EdgeInsets.all(16.0),
       title: const Text(
         'Video Analysis',
         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
       ),
       trailing: const Icon(Icons.arrow_forward),
       onTap: () {
         Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const ExploreScreen()),
         );
       },
     ),
   ),
 );
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
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }
}






class ProfileHeader extends StatelessWidget {
 final String? userName;


 const ProfileHeader({super.key, this.userName});


 @override
 Widget build(BuildContext context) {
   return Container(
     decoration: BoxDecoration(
       color: Theme.of(context).brightness == Brightness.light
           ? const Color(0xFF2B054E).withOpacity(1.0)
           : const Color(0xFFF0EAF8).withOpacity(0.8),
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
           'Hello, $userName!',
           style: Theme.of(context).textTheme.headlineSmall!.copyWith(
               color: Theme.of(context).colorScheme.surface, fontSize: 26),
         ),
         const SizedBox(height: 13.0),
         Text(
           'Welcome to your profile! Here you can find featured lessons and edit the app theme.',
           style: Theme.of(context).textTheme.bodyLarge!.copyWith(
               color: Theme.of(context).colorScheme.surface, fontSize: 14),
         ),
       ],
     ),
   );
 }
}
