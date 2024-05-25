class Module {
  final int id;
  final String title;
  final List<Lesson> lessons;

  Module({required this.id, required this.title, required this.lessons});

  factory Module.fromJson(Map<String, dynamic> json) {
    var lessonsList = json['lessons'] as List;
    List<Lesson> lessons = lessonsList.map((i) => Lesson.fromJson(i)).toList();

    return Module(
      id: json['id'],
      title: json['title'],
      lessons: lessons,
    );
  }
}

class Lesson {
  final int id;
  final String title;
  final String description;
  final List<Subsection> subsections;
  final String image;
  final Quiz? quiz;

  Lesson({required this.id, required this.title, required this.description, required this.subsections, required this.image, this.quiz});

  factory Lesson.fromJson(Map<String, dynamic> json) {
    var subsectionsList = json['subsections'] as List;
    List<Subsection> subsections = subsectionsList.map((i) => Subsection.fromJson(i)).toList();

    Quiz? quiz;
    if (json.containsKey('quiz')) {
      quiz = Quiz.fromJson(json['quiz']);
    }

    return Lesson(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subsections: subsections,
      image: json['image'],
      quiz: quiz,
    );
  }
}

class Subsection {
  final int id;
  final String title;
  final String content;
  final Quiz? quiz;
  final bool isCompleted;

  Subsection({
    required this.id,
    required this.title,
    required this.content,
    this.quiz,
    this.isCompleted = false
  });

  factory Subsection.fromJson(Map<String, dynamic> json) {
    return Subsection(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      quiz: json.containsKey('quiz') ? Quiz.fromJson(json['quiz']) : null,
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class Quiz {
  final String question;
  final List<String> answers;
  final int correctAnswerIndex;

  Quiz({
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    var answersList = json['answers'] as List;
    List<String> answers = List<String>.from(answersList);

    return Quiz(
      question: json['question'],
      answers: answers,
      correctAnswerIndex: json['correctAnswerIndex'],
    );
  }

}