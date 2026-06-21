import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

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

  void _load() {
    _future = widget.controller.api.get(
      widget.controller.localizedPath('/lessons/${widget.lessonId}'),
    );
  }

  Future<void> _complete() async {
    if (!await requireCommunityLogin(context, widget.controller)) return;
    setState(() => _completing = true);
    try {
      final response = await widget.controller.api.post(
        '/lessons/${widget.lessonId}/complete',
      );
      if (mounted) {
        showMessage(context, response['message'].toString());
        setState(() {
          _load();
        });
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
        onRetry: () => setState(() {
          _load();
        }),
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
              if (lesson['video_url'] != null) ...[
                const SizedBox(height: 16),
                _LessonVideo(
                  url: lesson['video_url'].toString(),
                  durationSeconds:
                      lesson['video_duration_seconds'] as int? ?? 60,
                ),
              ],
              if ((lesson['resources'] as List?)?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Learning resources',
                  icon: Icons.link_rounded,
                  child: Column(
                    children: (lesson['resources'] as List).map((raw) {
                      final resource = Map<String, dynamic>.from(raw as Map);
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.open_in_new_rounded),
                        title: Text(resource['title'].toString()),
                        subtitle: resource['description'] != null
                            ? Text(resource['description'].toString())
                            : null,
                        onTap: () => launchUrl(
                          Uri.parse(resource['url'].toString()),
                          mode: LaunchMode.externalApplication,
                        ),
                      );
                    }).toList(),
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

class _LessonVideo extends StatefulWidget {
  const _LessonVideo({required this.url, required this.durationSeconds});

  final String url;
  final int durationSeconds;

  @override
  State<_LessonVideo> createState() => _LessonVideoState();
}

class _LessonVideoState extends State<_LessonVideo> {
  late final VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'One-minute demo video',
      icon: Icons.play_circle_fill_rounded,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: _controller.value.isInitialized
                ? _controller.value.aspectRatio
                : 16 / 9,
            child: _controller.value.isInitialized
                ? VideoPlayer(_controller)
                : const Center(child: CircularProgressIndicator()),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filled(
                onPressed: !_controller.value.isInitialized
                    ? null
                    : () {
                        setState(() {
                          _controller.value.isPlaying
                              ? _controller.pause()
                              : _controller.play();
                        });
                      },
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Text('Maximum ${widget.durationSeconds} seconds'),
            ],
          ),
        ],
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
