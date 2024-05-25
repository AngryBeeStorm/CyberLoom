import 'package:flutter/material.dart';

class AppStyles {
  static InputDecoration textFieldDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.purple, width: 2.0),
      borderRadius: BorderRadius.circular(8.0),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.orange, width: 2.5),
      borderRadius: BorderRadius.circular(8.0),
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
  );
}

