import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/job_provider.dart';
import 'screens/editor_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Use path-based URL strategy (removes # from URLs)
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: Builder(
        builder: (context) {
          final router = GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const EditorScreen(),
              ),
              GoRoute(
                path: '/job/:jobId',
                builder: (context, state) {
                  final jobId = state.pathParameters['jobId'];
                  return EditorScreen(initialJobId: jobId);
                },
              ),
            ],
          );

          return MaterialApp.router(
            title: 'AI Image Editor',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
