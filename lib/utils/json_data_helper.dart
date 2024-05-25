import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

class JsonDataHelper {
  static Future<List<Module>> loadModules() async {
    final String response = await rootBundle.loadString('assets/data/lessons.json');
    final data = await json.decode(response);
    return (data['modules'] as List).map((json) => Module.fromJson(json)).toList();
  }

  static Future<List<Lesson>> loadAllLessons() async {
    final List<Module> modules = await loadModules();
    List<Lesson> allLessons = [];
    for (var module in modules) {
      allLessons.addAll(module.lessons);
    }
    return allLessons;
  }

}

class TopicService {
  Future<List<Category>> loadCategories() async {
    final jsonString = await rootBundle.loadString('assets/data/topics.json');
    final jsonResponse = json.decode(jsonString) as Map<String, dynamic>;
    return (jsonResponse['categories'] as List)
        .map((data) => Category.fromJson(data))
        .toList();
  }
}

class Category {
  final String title;
  final String description;
  final List<Topic> topics;

  Category({
    required this.title,
    required this.description,
    required this.topics,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      title: json['title'],
      description: json['description'],
      topics: (json['topics'] as List).map((data) => Topic.fromJson(data)).toList(),
    );
  }
}

class Topic {
  final String title;
  final String description;
  final String image;
  final String prompt;
  final String initialMessage;

  Topic({
    required this.title,
    required this.description,
    required this.image,
    required this.prompt,
    required this.initialMessage,
  });

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      title: json['title'],
      description: json['description'],
      image: json['image'],
      prompt: json['prompt'],
      initialMessage: json['initial_message'],
    );
  }
}
