import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  const TopicDetailScreen({
    super.key,
    required this.controller,
    required this.topicId,
  });
  final AppController controller;
  final int topicId;

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.controller.api.get(
      widget.controller.localizedPath('/topics/${widget.topicId}'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('topic_lessons'))),
      body: PagePadding(
        child: ApiFutureBuilder(
          future: _future,
          onRetry: () => setState(() {
            _load();
          }),
          builder: (context, response) {
            final topic = Map<String, dynamic>.from(response['data'] as Map);
            final lessons = List<Map<String, dynamic>>.from(
              (topic['lessons'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            );
            return ListView(
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: const Color(0xFF201A2D),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic['level'].toString().toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFFFF9B94),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        topic['title'].toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        topic['description'].toString(),
                        style: const TextStyle(
                          color: Color(0xFFD8D1DF),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '${lessons.length} masomo',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ...lessons.asMap().entries.map((entry) {
                  final lesson = entry.value;
                  final completed = lesson['is_completed'] == true;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        onTap: () =>
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LessonScreen(
                                  controller: widget.controller,
                                  lessonId: lesson['id'] as int,
                                ),
                              ),
                            ).then(
                              (_) => setState(() {
                                _load();
                              }),
                            ),
                        leading: CircleAvatar(
                          backgroundColor: completed
                              ? const Color(0xFFE7F8EF)
                              : const Color(0xFFFFE9E7),
                          foregroundColor: completed
                              ? Colors.green
                              : laravelRed,
                          child: completed
                              ? const Icon(Icons.check_rounded)
                              : Text(
                                  '${entry.key + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                        title: Text(
                          lesson['title'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            '${lesson['estimated_minutes']} dakika • Quiz ${lesson['best_score']}%',
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
