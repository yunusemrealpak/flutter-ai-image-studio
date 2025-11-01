import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/job_provider.dart';
import 'screens/editor_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => JobProvider(),
      child: MaterialApp(
        title: 'AI Image Editor',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const EditorScreen(),
      ),
    );
  }
}
