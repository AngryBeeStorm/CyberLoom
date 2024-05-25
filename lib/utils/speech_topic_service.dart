import 'dart:convert';
import 'package:flutter/services.dart';

class SpeechTopic {
  final String title;
  final String description;
  final String prompt;

  SpeechTopic({
    required this.title,
    required this.description,
    required this.prompt,
  });

  factory SpeechTopic.fromJson(Map<String, dynamic> json) {
    return SpeechTopic(
      title: json['title'],
      description: json['description'],
      prompt: json['prompt'],
    );
  }
}

class SpeechTopicService {
  Future<List<SpeechTopic>> loadTopics() async {
    final jsonString = await rootBundle.loadString('assets/data/speech_topics.json');
    final jsonResponse = json.decode(jsonString) as Map<String, dynamic>;
    return (jsonResponse['topics'] as List)
        .map((data) => SpeechTopic.fromJson(data))
        .toList();
  }
}
