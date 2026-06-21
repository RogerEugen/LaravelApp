import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.controller,
    required this.lessonId,
  });
  final AppController controller;
  final int lessonId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Future<Map<String, dynamic>> _future;
  final Map<int, int> _answers = {};
  bool _submitting = false;
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _future = widget.controller.api.get(
      widget.controller.localizedPath('/lessons/${widget.lessonId}/quiz'),
    );
  }

  Future<void> _submit(List<Map<String, dynamic>> questions) async {
    if (_answers.length != questions.length) {
      showMessage(context, context.tr('answer_all'));
      return;
    }
    setState(() => _submitting = true);
    try {
      final response = await widget.controller.api.post(
        widget.controller.localizedPath('/lessons/${widget.lessonId}/quiz'),
        {
          'answers': questions
              .map(
                (question) => {
                  'quiz_id': question['id'],
                  'selected_option_id': _answers[question['id']],
                },
              )
              .toList(),
        },
      );
      if (mounted) {
        setState(
          () => _result = Map<String, dynamic>.from(response['data'] as Map),
        );
      }
    } catch (error) {
      if (mounted) showMessage(context, error.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('lesson_quiz'))),
      body: ApiFutureBuilder(
        future: _future,
        builder: (context, response) {
          final data = Map<String, dynamic>.from(response['data'] as Map);
          final questions = List<Map<String, dynamic>>.from(
            (data['questions'] as List).map(
              (e) => Map<String, dynamic>.from(e as Map),
            ),
          );
          if (_result != null) return _ResultView(result: _result!);
          if (questions.isEmpty) {
            return EmptyState(
              icon: Icons.quiz_outlined,
              title: context.tr('quiz_unavailable'),
              message: context.tr('quiz_unavailable_message'),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
            children: [
              Text(
                data['lesson_title'].toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_answers.length}/${questions.length} ${context.tr('answered')}',
                style: const TextStyle(color: Color(0xFF667085)),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _answers.length / questions.length,
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(height: 22),
              ...questions.asMap().entries.map((entry) {
                final question = entry.value;
                final options = List<Map<String, dynamic>>.from(
                  (question['options'] as List).map(
                    (e) => Map<String, dynamic>.from(e as Map),
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${context.tr('question')} ${entry.key + 1}',
                            style: const TextStyle(
                              color: laravelRed,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            question['question'].toString(),
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...options.map((option) {
                            final selected =
                                _answers[question['id']] == option['id'];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => setState(
                                  () => _answers[question['id'] as int] =
                                      option['id'] as int,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? const Color(0xFFFFE9E7)
                                        : const Color(0xFFF8F9FB),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: selected
                                          ? laravelRed
                                          : const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        selected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_off,
                                        color: selected
                                            ? laravelRed
                                            : const Color(0xFF98A2B3),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${option['option_key']}. ${option['option_text']}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              FilledButton.icon(
                onPressed: _submitting ? null : () => _submit(questions),
                icon: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(context.tr('submit_answers')),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});
  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
    final passed = result['passed'] == true;
    final details = List<Map<String, dynamic>>.from(
      (result['results'] as List).map(
        (e) => Map<String, dynamic>.from(e as Map),
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: passed ? const Color(0xFFE9F9F0) : const Color(0xFFFFF3E7),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Icon(
                passed ? Icons.emoji_events_rounded : Icons.replay_rounded,
                size: 60,
                color: passed ? Colors.green : Colors.orange,
              ),
              const SizedBox(height: 12),
              Text(
                '${result['score_percentage']}%',
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                passed
                    ? context.tr('passed_message')
                    : context.tr('retry_message'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...details.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          entry.value['is_correct'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: entry.value['is_correct'] == true
                              ? Colors.green
                              : laravelRed,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            entry.value['question'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${context.tr('correct_answer')}: ${entry.value['correct_answer']}',
                    ),
                    if (entry.value['explanation'] != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        entry.value['explanation'].toString(),
                        style: const TextStyle(color: Color(0xFF667085)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.tr('back_to_lesson')),
        ),
      ],
    );
  }
}
