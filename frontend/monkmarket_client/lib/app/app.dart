import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import 'router/app_router.dart';
import '../../features/settings/viewmodels/settings_viewmodel.dart';
import '../../features/auth/viewmodels/auth_viewmodel.dart';

class MonkMarketApp extends ConsumerStatefulWidget {
  const MonkMarketApp({super.key});

  @override
  ConsumerState<MonkMarketApp> createState() => _MonkMarketAppState();
}

class _MonkMarketAppState extends ConsumerState<MonkMarketApp> {
  @override
  void initState() {
    super.initState();
    // Restore session and load settings on startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(settingsViewModelProvider.notifier).loadSettings();
      await ref.read(authViewModelProvider.notifier).restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settingsState = ref.watch(settingsViewModelProvider);

    return MaterialApp.router(
      routerConfig: router,
      title: 'MonkMarket',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsState.themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: child!,
        );
      },
    );
  }
}
