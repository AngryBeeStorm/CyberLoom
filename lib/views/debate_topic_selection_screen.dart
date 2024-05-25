import 'package:flutter/material.dart';
import 'debate_chat_screen.dart';
import '../utils/json_data_helper.dart';

class DebateTopicSelectionScreen extends StatefulWidget {
  final Category category;

  const DebateTopicSelectionScreen({super.key, required this.category});

  @override
  _DebateTopicSelectionScreenState createState() => _DebateTopicSelectionScreenState();
}

class _DebateTopicSelectionScreenState extends State<DebateTopicSelectionScreen> {
  int _selectedTopicIndex = 0;

  void _onTopicChanged(int index) {
    setState(() {
      _selectedTopicIndex = index;
    });
  }

  void _onStartPressed() {
    final selectedTopic = widget.category.topics[_selectedTopicIndex];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DebateChatScreen(
          topic: selectedTopic.title,
          prompt: selectedTopic.prompt,
          initialMessage: selectedTopic.initialMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choose a Topic in ${widget.category.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select a topic to debate:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                itemCount: widget.category.topics.length,
                onPageChanged: _onTopicChanged,
                controller: PageController(viewportFraction: 0.8),
                itemBuilder: (context, index) {
                  final topic = widget.category.topics[index];
                  return AnimatedBuilder(
                    animation: PageController(viewportFraction: 0.8),
                    builder: (context, child) {
                      return Transform.scale(
                        scale: index == _selectedTopicIndex ? 1.0 : 0.9,
                        child: child,
                      );
                    },
                    child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      shadowColor: Theme.of(context).cardTheme.shadowColor,
                      shape: Theme.of(context).cardTheme.shape,
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(topic.image, height: 250),
                            const SizedBox(height: 50),
                            Text(
                              topic.title,
                              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimary)
                            ),
                            const SizedBox(height: 10),
                            Text(
                              topic.description,
                              style: TextStyle(fontSize: 16.0, color: Theme.of(context).colorScheme.onPrimary),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _onStartPressed,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.primary),
                  foregroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.onPrimary),
                  padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                  textStyle: WidgetStateProperty.all(
                    const TextStyle(fontSize: 22),
                  ),
                ),
                child: const Text('Start Debate'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
