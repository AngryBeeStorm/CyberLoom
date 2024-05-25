import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final int lessonIndex;
  final int moduleIndex;

  const LessonCard({super.key, required this.lessonIndex, required this.moduleIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
      border: Border.all(color: Colors.black54, width: 3),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(color: Colors.deepPurple.shade500, offset: const Offset(6.0, 6.0),),
      ],
    ),
    child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Text(
            'Lesson ${moduleIndex + 1}-${lessonIndex + 1}',
            style: const TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
    );
  }
}
