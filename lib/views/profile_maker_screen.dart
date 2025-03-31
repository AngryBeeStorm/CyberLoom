import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import 'home_screen.dart';


class ProfileScreen extends StatefulWidget {
 final Function toggleTheme;


 const ProfileScreen({super.key, required this.toggleTheme});


 @override
 _ProfileScreenState createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {
 final TextEditingController _nameController = TextEditingController();


 void _saveProfile() async {
   String name = _nameController.text.trim();
   if (name.isNotEmpty) {
     DatabaseHelper dbHelper = DatabaseHelper.instance;
     try {
       await dbHelper.saveUserProfile(name);
       Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => HomeScreen(toggleTheme: widget.toggleTheme)),
       );
     } catch (e) {
       // Show error message if needed
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error saving profile: $e')),
       );
     }
   } else {
     ScaffoldMessenger.of(context).showSnackBar(
       const SnackBar(content: Text('Name cannot be empty')),
     );
   }
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: Stack(
       fit: StackFit.expand,
       children: [
         Image.asset(
           'assets/images/lesson_thumbnails/thumbnail.png',
           fit: BoxFit.cover,
         ),
         Center(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Card(
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
               elevation: 10,
               child: Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Column(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     const Text(
                       'Enter your name',
                       style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                     ),
                     const SizedBox(height: 16),
                     TextField(
                       controller: _nameController,
                       decoration: const InputDecoration(
                         labelText: 'Name',
                         border: OutlineInputBorder(),
                       ),
                     ),
                     const SizedBox(height: 16),
                     ElevatedButton(
                       onPressed: _saveProfile,
                       child: const Text('Save'),
                     ),
                     const SizedBox(height: 16),
                     IconButton(
                       icon: const Icon(Icons.brightness_6),
                       onPressed: () {
                         widget.toggleTheme();
                       },
                     ),
                   ],
                 ),
               ),
             ),
           ),
         ),
       ],
     ),
   );
 }
}
