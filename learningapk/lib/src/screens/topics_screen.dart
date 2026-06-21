import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'topic_detail_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key, required this.controller});
  final AppController controller;

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.controller.api.get(
      widget.controller.localizedPath('/topics'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.tr('topics_title'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            Text(
              context.tr('topics_subtitle'),
              style: const TextStyle(fontSize: 12, color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
      body: PagePadding(
        child: ApiFutureBuilder(
          future: _future,
          onRetry: () => setState(() {
            _load();
          }),
          builder: (context, response) {
            final topics = List<Map<String, dynamic>>.from(
              (response['data'] as List).map(
                (e) => Map<String, dynamic>.from(e as Map),
              ),
            );
            return RefreshIndicator(
              onRefresh: () async => setState(() {
                _load();
              }),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final total = topic['lesson_count'] as int;
                  final done = topic['completed_count'] as int;
                  return Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () =>
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TopicDetailScreen(
                                controller: widget.controller,
                                topicId: topic['id'] as int,
                              ),
                            ),
                          ).then(
                            (_) => setState(() {
                              _load();
                            }),
                          ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: index.isEven
                                    ? const Color(0xFFFFE9E7)
                                    : const Color(0xFFE8F2FF),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                index.isEven
                                    ? Icons.terminal_rounded
                                    : Icons.account_tree_rounded,
                                color: index.isEven ? laravelRed : Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          topic['title'].toString(),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        topic['level'].toString(),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: laravelRed,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    topic['description'].toString(),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF667085),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: LinearProgressIndicator(
                                            value: total == 0
                                                ? 0
                                                : done / total,
                                            minHeight: 6,
                                            backgroundColor: const Color(
                                              0xFFF0F1F5,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        '$done/$total',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.chevron_right_rounded),
                          ],
                        ),
                      ),
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
