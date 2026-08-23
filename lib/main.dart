import 'package:flutter/material.dart';
import 'core/ai_notifier.dart';
import 'core/theme.dart';
import 'core/theme_notifier.dart';
import 'core/routes.dart';
import 'core/constants.dart';

void main() {
  runApp(const MarketingApp());
}

// ─────────────────────────────────────────────────────────────────────────────
// MarketingApp
//
// Converted to StatefulWidget so it can own the ThemeNotifier and rebuild
// MaterialApp.themeMode whenever the notifier fires.
// ─────────────────────────────────────────────────────────────────────────────

class MarketingApp extends StatefulWidget {
  const MarketingApp({super.key});

  @override
  State<MarketingApp> createState() => _MarketingAppState();
}

class _MarketingAppState extends State<MarketingApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier(initial: ThemeMode.light);
  final AiNotifier    _aiNotifier    = AiNotifier();

  @override
  void dispose() {
    _themeNotifier.dispose();
    _aiNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AiNotifier.provide is placed OUTSIDE the ListenableBuilder for
    // ThemeNotifier. This is critical: we must NOT rebuild MaterialApp (and
    // its Navigator) every time the AI panel opens/closes, because that would
    // destroy the route stack. AiNotifier propagates through its own
    // InheritedWidget scope without touching MaterialApp.
    return ThemeNotifier.provide(
      notifier: _themeNotifier,
      child: AiNotifier.provide(
        notifier: _aiNotifier,
        child: ListenableBuilder(
          listenable: _themeNotifier,
          builder: (context, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: AppConstants.appName,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _themeNotifier.mode,
              initialRoute: AppRoutes.splash,
              routes: AppRoutes.routes,
            );
          },
        ),
      ),
    );
  }
}
