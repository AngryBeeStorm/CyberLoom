import 'package:flutter/material.dart';
import 'package:molten_navigationbar_flutter/molten_navigationbar_flutter.dart';
import 'practice_screen.dart';
import 'learning_module_screen.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
 final Function toggleTheme;
 const HomeScreen({super.key, required this.toggleTheme});

 @override
 HomeScreenState createState() {
   return HomeScreenState();
 }
}

class HomeScreenState extends State<HomeScreen> {
 int _selectedIndex = 0;
 late List<Widget> _widgetOptions;

 @override
 void initState() {
   super.initState();
   _widgetOptions = <Widget>[
     ProfileScreen(toggleTheme: widget.toggleTheme),
     const PracticeScreen(),
     LearningModuleScreen(toggleTheme: widget.toggleTheme),
     const ExploreScreen(),
   ];
 }
 void _onItemTapped(int index) {
   setState(() {
     _selectedIndex = index;
   });
 }
 @override
 Widget build(BuildContext context) {
   return Scaffold(
     body: IndexedStack(
       index: _selectedIndex,
       children: _widgetOptions,
     ),
     bottomNavigationBar: MoltenBottomNavigationBar(
       selectedIndex: _selectedIndex,
       onTabChange: (clickedIndex) {
         setState(() {
           _selectedIndex = clickedIndex;
         });
       },
       tabs: [
         MoltenTab(
           icon: const Icon(Icons.person_outline_rounded),
           title: const Text("Profile"),
         ),
         MoltenTab(
           icon: const Icon(Icons.chat_bubble_outline),
           title: const Text("Practice"),
         ),
         MoltenTab(
           icon: const Icon(Icons.school_outlined),
           title: const Text("Learn"),
         ),
         MoltenTab(
           icon: const Icon(Icons.search_outlined),
           title: const Text("Analyze"),
         ),
       ],
       curve: Curves.fastOutSlowIn,
       domeCircleSize: 48.0,
       domeCircleColor: Theme.of(context).colorScheme.primary,
       barHeight: 60,
     ),
   );
 }
}
