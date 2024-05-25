import 'package:flutter/material.dart';
import 'debate_topic_selection_screen.dart';
import '../utils/json_data_helper.dart';

class DebateSelectionScreen extends StatelessWidget {
  const DebateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Category>>(
        future: TopicService().loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available.'));
          }

          final categories = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.light
                        ? const Color(0xFF2B054E).withOpacity(1.0)
                        : const Color(0xFFF0EAF8).withOpacity(0.8),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to the Debate Practice Area!',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 24),
                      ),
                      const SizedBox(height: 13.0),
                      Text(
                        'Choose a category to start your practice session.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(color: Theme.of(context).colorScheme.surface, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final color = index % 2 == 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.secondary;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DebateTopicSelectionScreen(category: category),
                            ),
                          );
                        },
                        child: Card(
                          color: color,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.title,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category.description,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
