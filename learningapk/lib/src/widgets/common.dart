import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme.dart';

class LaravelMark extends StatelessWidget {
  const LaravelMark({super.key, this.size = 58});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: laravelRed,
        borderRadius: BorderRadius.circular(size * .28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33FF2D20),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Icon(Icons.code_rounded, color: Colors.white, size: size * .55),
    );
  }
}

class PagePadding extends StatelessWidget {
  const PagePadding({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: child,
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: laravelRed),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ApiFutureBuilder extends StatelessWidget {
  const ApiFutureBuilder({
    super.key,
    required this.future,
    required this.builder,
    this.onRetry,
  });
  final Future<Map<String, dynamic>> future;
  final Widget Function(BuildContext, Map<String, dynamic>) builder;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 54,
                    color: laravelRed,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    error is ApiException
                        ? error.message
                        : 'Imeshindikana kupakia taarifa.',
                    textAlign: TextAlign.center,
                  ),
                  if (onRetry != null) ...[
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Jaribu tena'),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return builder(context, snapshot.data!);
      },
    );
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
