import 'dart:async';

import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../localization.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'lesson_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.controller,
    required this.onExplore,
  });
  final AppController controller;
  final VoidCallback onExplore;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _pageController = PageController(viewportFraction: .9);
  late Future<Map<String, dynamic>> _future;
  Timer? _timer;
  int _slide = 0;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      _slide = (_slide + 1) % 3;
      _pageController.animateToPage(
        _slide,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _load() {
    _future = widget.controller.api.get('/dashboard');
  }

  IconData _icon(String icon) => switch (icon) {
    'bolt' => Icons.bolt_rounded,
    'school' => Icons.school_rounded,
    _ => Icons.public_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ApiFutureBuilder(
        future: _future,
        onRetry: () => setState(() {
          _load();
        }),
        builder: (context, response) {
          final data = Map<String, dynamic>.from(response['data'] as Map);
          var hero = Map<String, dynamic>.from(data['hero'] as Map);
          final stats = Map<String, dynamic>.from(data['stats'] as Map);
          var slides = List<Map<String, dynamic>>.from(
            (data['slides'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );
          var benefits = List<Map<String, dynamic>>.from(
            (data['benefits'] as List).map(
              (item) => Map<String, dynamic>.from(item as Map),
            ),
          );
          if (widget.controller.locale.languageCode == 'en') {
            hero = {
              'eyebrow': 'LARAVEL FOR EVERYONE',
              'title': 'Build modern web applications with confidence.',
              'subtitle':
                  'Learn Laravel step by step with practical lessons, real code and community support.',
            };
            slides = [
              {
                'title': 'Trusted around the world',
                'description':
                    'Laravel is trusted by millions of developers and supported by an active global community.',
                'icon': 'public',
              },
              {
                'title': 'Build faster',
                'description':
                    'Routing, authentication, queues, validation and Eloquent ORM work together beautifully.',
                'icon': 'bolt',
              },
              {
                'title': 'Beginner to professional',
                'description':
                    'Practical lessons, real examples and quizzes help you build production-ready skills.',
                'icon': 'school',
              },
            ];
            benefits = [
              {
                'title': 'Elegant syntax',
                'description': 'Readable code that is easier to maintain.',
              },
              {
                'title': 'Powerful ecosystem',
                'description':
                    'Official tools and a large community for every stage.',
              },
              {
                'title': 'Career-ready skills',
                'description':
                    'Build APIs, dashboards, e-commerce and business systems.',
              },
            ];
          }
          final next = data['continue_learning'] as Map?;

          return RefreshIndicator(
            onRefresh: () async => setState(() {
              _load();
            }),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                Row(
                  children: [
                    const LaravelMark(size: 48),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Learn Laravel',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Kiswahili • Tanzania',
                            style: TextStyle(
                              color: Color(0xFF667085),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.controller.isAuthenticated)
                      UserAvatar(user: widget.controller.user!),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  hero['eyebrow'].toString(),
                  style: const TextStyle(
                    color: laravelRed,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  hero['title'].toString(),
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  hero['subtitle'].toString(),
                  style: const TextStyle(
                    color: Color(0xFF667085),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: widget.onExplore,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(context.tr('start_learning')),
                ),
                const SizedBox(height: 12),
                Text(
                  context.tr('guest_note'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF667085), fontSize: 12),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 220,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: slides.length,
                    onPageChanged: (value) => setState(() => _slide = value),
                    itemBuilder: (context, index) {
                      final slide = slides[index];
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: index == 1
                                ? const [Color(0xFF17324D), Color(0xFF205A70)]
                                : index == 2
                                ? const [Color(0xFF382253), Color(0xFF663765)]
                                : const [Color(0xFF201A2D), Color(0xFF4A2534)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .12),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                _icon(slide['icon'].toString()),
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              slide['title'].toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide['description'].toString(),
                              style: const TextStyle(
                                color: Color(0xFFD8D1DF),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: index == _slide ? 24 : 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: index == _slide
                            ? laravelRed
                            : const Color(0xFFD8DCE4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _NumberCard(
                        value: stats['developers'].toString(),
                        label: 'Developers duniani',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberCard(
                        value: stats['community_countries'].toString(),
                        label: 'Nchi zenye community',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NumberCard(
                        value: stats['total_lessons'].toString(),
                        label: 'Masomo ndani ya app',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  context.tr('why_laravel'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                ...benefits.map(
                  (benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFFFE9E7),
                          child: Icon(Icons.check_rounded, color: laravelRed),
                        ),
                        title: Text(
                          benefit['title'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text(benefit['description'].toString()),
                      ),
                    ),
                  ),
                ),
                if (next != null) ...[
                  const SizedBox(height: 14),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: laravelRed,
                        foregroundColor: Colors.white,
                        child: Icon(Icons.play_arrow),
                      ),
                      title: Text(
                        context.tr('continue_learning'),
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(next['lesson_title'].toString()),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LessonScreen(
                            controller: widget.controller,
                            lessonId: next['lesson_id'] as int,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NumberCard extends StatelessWidget {
  const _NumberCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 7),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: laravelRed,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFF667085)),
            ),
          ],
        ),
      ),
    );
  }
}
