import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../auth_gate.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'quiz_screen.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({
    super.key,
    required this.controller,
    required this.lessonId,
  });
  final AppController controller;
  final int lessonId;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Future<Map<String, dynamic>> _future;
  bool _completing = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() =>
      _future = widget.controller.api.get('/lessons/${widget.lessonId}');

  Future<void> _complete() async {
    if (!await requireCommunityLogin(context, widget.controller)) return;
    setState(() => _completing = true);
    try {
      final response = await widget.controller.api.post(
        '/lessons/${widget.lessonId}/complete',
      );
      if (mounted) {
        showMessage(context, response['message'].toString());
        setState(_load);
      }
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('lesson'))),
      body: ApiFutureBuilder(
        future: _future,
        onRetry: () => setState(_load),
        builder: (context, response) {
          final lesson = Map<String, dynamic>.from(response['data'] as Map);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Text(
                lesson['topic_title'].toString(),
                style: const TextStyle(
                  color: laravelRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                lesson['title'].toString(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 18,
                    color: Color(0xFF667085),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${lesson['estimated_minutes']} ${context.tr('minutes')}',
                    style: const TextStyle(color: Color(0xFF667085)),
                  ),
                  if (lesson['is_completed'] == true) ...[
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      context.tr('completed'),
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 24),
              _SectionCard(
                title: context.tr('lesson_content'),
                icon: Icons.auto_stories_rounded,
                child: Text(
                  lesson['content'].toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.65,
                    color: ink,
                  ),
                ),
              ),
              if (lesson['code_example'] != null) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: context.tr('code_example'),
                  icon: Icons.terminal_rounded,
                  dark: true,
                  child: SelectableText(
                    lesson['code_example'].toString(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      color: Color(0xFFE7EAF0),
                      height: 1.55,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
              if (lesson['real_life_example'] != null) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: context.tr('real_life_example'),
                  icon: Icons.lightbulb_outline_rounded,
                  child: Text(
                    lesson['real_life_example'].toString(),
                    style: const TextStyle(height: 1.55),
                  ),
                ),
              ],
              const SizedBox(height: 22),
              if (lesson['is_completed'] != true)
                FilledButton.icon(
                  onPressed: _completing ? null : _complete,
                  icon: _completing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(context.tr('complete_lesson')),
                ),
              if (lesson['has_quiz'] == true) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () async {
                    if (!await requireCommunityLogin(
                      context,
                      widget.controller,
                    )) {
                      return;
                    }
                    if (!context.mounted) return;
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuizScreen(
                          controller: widget.controller,
                          lessonId: widget.lessonId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.quiz_outlined),
                  label: Text(context.tr('take_quiz')),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.dark = false,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF161923) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: dark ? null : Border.all(color: const Color(0xFFE9ECF2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: dark ? const Color(0xFFFF776E) : laravelRed),
              const SizedBox(width: 9),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: dark ? Colors.white : ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
