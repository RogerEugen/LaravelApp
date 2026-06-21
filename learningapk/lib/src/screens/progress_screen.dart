import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => _future = widget.controller.api.get('/progress');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('progress_title'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              context.tr('progress_subtitle'),
              style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
      body: PagePadding(
        child: ApiFutureBuilder(
          future: _future,
          onRetry: () => setState(_load),
          builder: (context, response) {
            final items = List<Map<String, dynamic>>.from(
              (response['data'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            );
            if (items.isEmpty) {
              return EmptyState(
                icon: Icons.insights_rounded,
                title: context.tr('start_first_lesson'),
                message: context.tr('progress_empty'),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => setState(_load),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(
                            controller: widget.controller,
                            lessonId: item['lesson_id'] as int,
                          ),
                        ),
                      ).then((_) => setState(_load)),
                      leading: CircleAvatar(
                        backgroundColor: item['is_completed'] == true
                            ? const Color(0xFFE7F8EF)
                            : const Color(0xFFFFE9E7),
                        child: Icon(
                          item['is_completed'] == true
                              ? Icons.check
                              : Icons.play_arrow,
                          color: item['is_completed'] == true
                              ? Colors.green
                              : laravelRed,
                        ),
                      ),
                      title: Text(
                        item['lesson_title'].toString(),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${item['topic_title']} • Quiz ${item['best_score']}%',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
