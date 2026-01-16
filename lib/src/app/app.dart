import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class JamuinApp extends ConsumerWidget {
  const JamuinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Jamuin',
      theme: AppTheme.light(),
      themeMode: ThemeMode.light, // Force light theme
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
