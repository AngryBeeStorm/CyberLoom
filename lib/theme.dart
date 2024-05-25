import 'package:flutter/material.dart';

class CustomTheme {
  static const Color darkIndigo = Color(0xFF46127A);
  static const Color lightBlueEgg = Color(0xFF29D5A3);
  static const Color whiteLavender = Color(0xFFF0EAF8);
  static const Color amethyst = Color(0xFF794BCD);
  static const Color grey = Color(0xFF9E9E9E);  // Equivalent to grey[500]

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: darkIndigo,
      colorScheme: ColorScheme.fromSwatch().copyWith(
        secondary: lightBlueEgg,
        primary: darkIndigo,
        tertiary: amethyst,
        surface: whiteLavender,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.black,
      ),
      scaffoldBackgroundColor: whiteLavender,
      appBarTheme: const AppBarTheme(
        backgroundColor: darkIndigo,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),

      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: darkIndigo),
        displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: darkIndigo),
        displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: darkIndigo),
        headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: darkIndigo),
        headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: darkIndigo),
        titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: darkIndigo),
        bodyLarge: TextStyle(fontSize: 14.0, color: darkIndigo),
        bodyMedium: TextStyle(fontSize: 12.0, color: darkIndigo),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: darkIndigo),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: darkIndigo),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: amethyst,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteLavender,
          textStyle: const TextStyle(color: amethyst),
          elevation: 2, // shadow elevation
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightBlueEgg,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: whiteLavender,
        shadowColor: grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: lightBlueEgg,
            width: 2,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: darkIndigo,
      colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
        secondary: lightBlueEgg,
        primary: darkIndigo, //dark indigo
        surface: const Color(0xFF1E1E1E),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Colors.white,
        tertiary: whiteLavender,

      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkIndigo,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
        displayMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 14.0, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 12.0, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white),
        titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteLavender,
          textStyle: const TextStyle(color: amethyst),
          elevation: 10, // shadow elevation
        ),
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: amethyst,
        textTheme: ButtonTextTheme.primary,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: lightBlueEgg,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF1E1E1E),
        shadowColor: grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E1E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: lightBlueEgg,
            width: 2,
          ),
        ),
      ),
    );
  }
}
