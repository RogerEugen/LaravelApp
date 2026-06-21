import 'package:flutter/material.dart';

import '../../app_controller.dart';
import '../../theme.dart';
import '../../widgets/common.dart';

class AdminContentScreen extends StatefulWidget {
  const AdminContentScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<AdminContentScreen> createState() => _AdminContentScreenState();
}

class _AdminContentScreenState extends State<AdminContentScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late Future<Map<String, dynamic>> _topics;
  late Future<Map<String, dynamic>> _lessons;
  late Future<Map<String, dynamic>> _quizzes;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  void _load() {
    _topics = widget.controller.api.get('/admin/topics');
    _lessons = widget.controller.api.get('/admin/lessons');
    _quizzes = widget.controller.api.get('/admin/quizzes');
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final index = _tabs.index;
    var changed = false;
    if (index == 0) {
      changed =
          await showDialog<bool>(
            context: context,
            builder: (_) => TopicEditor(controller: widget.controller),
          ) ??
          false;
    } else if (index == 1) {
      final topicResponse = await widget.controller.api.get('/admin/topics');
      if (!mounted) return;
      changed =
          await showDialog<bool>(
            context: context,
            builder: (_) => LessonEditor(
              controller: widget.controller,
              topics: List<Map<String, dynamic>>.from(
                (topicResponse['data'] as List).map(
                  (item) => Map<String, dynamic>.from(item as Map),
                ),
              ),
            ),
          ) ??
          false;
    } else {
      final lessonResponse = await widget.controller.api.get('/admin/lessons');
      if (!mounted) return;
      changed =
          await showDialog<bool>(
            context: context,
            builder: (_) => QuizEditor(
              controller: widget.controller,
              lessons: List<Map<String, dynamic>>.from(
                (lessonResponse['data'] as List).map(
                  (item) => Map<String, dynamic>.from(item as Map),
                ),
              ),
            ),
          ) ??
          false;
    }
    if (changed) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learning content',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Topics'),
            Tab(text: 'Lessons'),
            Tab(text: 'Quizzes'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: const Text('Ongeza'),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ContentList(
            future: _topics,
            type: 'topics',
            controller: widget.controller,
            onChanged: () => setState(_load),
          ),
          _ContentList(
            future: _lessons,
            type: 'lessons',
            controller: widget.controller,
            onChanged: () => setState(_load),
          ),
          _ContentList(
            future: _quizzes,
            type: 'quizzes',
            controller: widget.controller,
            onChanged: () => setState(_load),
          ),
        ],
      ),
    );
  }
}

class _ContentList extends StatelessWidget {
  const _ContentList({
    required this.future,
    required this.type,
    required this.controller,
    required this.onChanged,
  });
  final Future<Map<String, dynamic>> future;
  final String type;
  final AppController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return PagePadding(
      child: ApiFutureBuilder(
        future: future,
        onRetry: onChanged,
        builder: (context, response) {
          final items = List<Map<String, dynamic>>.from(
            (response['data'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );
          return ListView.separated(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              final title = type == 'quizzes'
                  ? item['question'].toString()
                  : item['title'].toString();
              final subtitle = type == 'topics'
                  ? '${item['lessons_count']} lessons • ${item['level']}'
                  : type == 'lessons'
                  ? '${(item['topic'] as Map?)?['title']} • ${item['quizzes_count']} quiz'
                  : '${(item['lesson'] as Map?)?['title']} • ${item['difficulty']}';
              return Card(
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFE9E7),
                    child: Icon(
                      type == 'topics'
                          ? Icons.category
                          : type == 'lessons'
                          ? Icons.menu_book
                          : Icons.quiz,
                      color: laravelRed,
                    ),
                  ),
                  title: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(subtitle),
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action != 'delete') return;
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Thibitisha kufuta'),
                          content: Text('Unataka kufuta "$title"?'),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, false),
                              child: const Text('Ghairi'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.pop(dialogContext, true),
                              child: const Text('Futa'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await controller.api.delete(
                          '/admin/$type/${item['id']}',
                        );
                        onChanged();
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'delete', child: Text('Futa')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TopicEditor extends StatefulWidget {
  const TopicEditor({super.key, required this.controller});
  final AppController controller;

  @override
  State<TopicEditor> createState() => _TopicEditorState();
}

class _TopicEditorState extends State<TopicEditor> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  String _level = 'Beginner';
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ongeza topic'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Jina la topic'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Maelezo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _level,
              decoration: const InputDecoration(labelText: 'Level'),
              items: ['Beginner', 'Intermediate', 'Advanced']
                  .map(
                    (value) =>
                        DropdownMenuItem(value: value, child: Text(value)),
                  )
                  .toList(),
              onChanged: (value) => _level = value!,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Ghairi'),
        ),
        FilledButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  final slug = _title.text
                      .trim()
                      .toLowerCase()
                      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                      .replaceAll(RegExp(r'^-|-$'), '');
                  await widget.controller.api.post('/admin/topics', {
                    'title': _title.text.trim(),
                    'slug': slug,
                    'description': _description.text.trim(),
                    'icon': 'school',
                    'level': _level,
                    'order_number':
                        DateTime.now().millisecondsSinceEpoch ~/ 1000,
                    'is_active': true,
                  });
                  if (context.mounted) Navigator.pop(context, true);
                },
          child: const Text('Hifadhi'),
        ),
      ],
    );
  }
}

class LessonEditor extends StatefulWidget {
  const LessonEditor({
    super.key,
    required this.controller,
    required this.topics,
  });
  final AppController controller;
  final List<Map<String, dynamic>> topics;

  @override
  State<LessonEditor> createState() => _LessonEditorState();
}

class _LessonEditorState extends State<LessonEditor> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _content = TextEditingController();
  final _code = TextEditingController();
  int? _topicId;

  @override
  void initState() {
    super.initState();
    if (widget.topics.isNotEmpty) _topicId = widget.topics.first['id'] as int;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ongeza lesson'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _topicId,
                decoration: const InputDecoration(labelText: 'Topic'),
                items: widget.topics
                    .map(
                      (topic) => DropdownMenuItem<int>(
                        value: topic['id'] as int,
                        child: Text(topic['title'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _topicId = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _summary,
                decoration: const InputDecoration(
                  labelText: 'Short description',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _content,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Lesson content'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _code,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Code example'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Ghairi'),
        ),
        FilledButton(
          onPressed: () async {
            final slug = _title.text
                .trim()
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
                .replaceAll(RegExp(r'^-|-$'), '');
            await widget.controller.api.post('/admin/lessons', {
              'topic_id': _topicId,
              'title': _title.text.trim(),
              'slug': slug,
              'short_description': _summary.text.trim(),
              'content': _content.text.trim(),
              'code_example': _code.text.trim(),
              'real_life_example': '',
              'order_number': DateTime.now().millisecondsSinceEpoch ~/ 1000,
              'estimated_minutes': 10,
              'is_active': true,
            });
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Hifadhi'),
        ),
      ],
    );
  }
}

class QuizEditor extends StatefulWidget {
  const QuizEditor({
    super.key,
    required this.controller,
    required this.lessons,
  });
  final AppController controller;
  final List<Map<String, dynamic>> lessons;

  @override
  State<QuizEditor> createState() => _QuizEditorState();
}

class _QuizEditorState extends State<QuizEditor> {
  final _question = TextEditingController();
  final _explanation = TextEditingController();
  final _options = List.generate(4, (_) => TextEditingController());
  int? _lessonId;
  String _correct = 'A';

  @override
  void initState() {
    super.initState();
    if (widget.lessons.isNotEmpty) {
      _lessonId = widget.lessons.first['id'] as int;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ongeza quiz'),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                initialValue: _lessonId,
                decoration: const InputDecoration(labelText: 'Lesson'),
                items: widget.lessons
                    .map(
                      (lesson) => DropdownMenuItem<int>(
                        value: lesson['id'] as int,
                        child: Text(lesson['title'].toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) => _lessonId = value,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _question,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Swali'),
              ),
              const SizedBox(height: 10),
              ...List.generate(
                4,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _options[index],
                    decoration: InputDecoration(
                      labelText: 'Option ${String.fromCharCode(65 + index)}',
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<String>(
                initialValue: _correct,
                decoration: const InputDecoration(labelText: 'Jibu sahihi'),
                items: ['A', 'B', 'C', 'D']
                    .map(
                      (key) => DropdownMenuItem(value: key, child: Text(key)),
                    )
                    .toList(),
                onChanged: (value) => _correct = value!,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _explanation,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Explanation'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Ghairi'),
        ),
        FilledButton(
          onPressed: () async {
            await widget.controller.api.post('/admin/quizzes', {
              'lesson_id': _lessonId,
              'question': _question.text.trim(),
              'explanation': _explanation.text.trim(),
              'difficulty': 'Easy',
              'order_number': DateTime.now().millisecondsSinceEpoch ~/ 1000,
              'is_active': true,
              'options': _options.map((item) => item.text.trim()).toList(),
              'correct_key': _correct,
            });
            if (context.mounted) Navigator.pop(context, true);
          },
          child: const Text('Hifadhi'),
        ),
      ],
    );
  }
}
