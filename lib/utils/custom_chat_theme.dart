import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class CustomChatTheme extends DefaultChatTheme {
  const CustomChatTheme()
      : super(
    inputTextDecoration: const InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 20),
      isCollapsed: true,
    ),
  );
}

