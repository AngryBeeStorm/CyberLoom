import 'package:flutter/material.dart';
import 'theme.dart';
import 'views/home_screen.dart';
import 'views/profile_maker_screen.dart';
import 'utils/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;
  bool _hasUserProfile = false;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  void _checkUserProfile() async {
    DatabaseHelper dbHelper = DatabaseHelper.instance;
    bool exists = await dbHelper.userProfileExists();
    setState(() {
      _hasUserProfile = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArgueRight',
      theme: _isDarkMode ? CustomTheme.darkTheme : CustomTheme.lightTheme,
      home: _hasUserProfile ? HomeScreen(toggleTheme: _toggleTheme) : ProfileScreen(toggleTheme: _toggleTheme),
      debugShowCheckedModeBanner: false,
    );
  }

  // Toggle theme mode
  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }
}