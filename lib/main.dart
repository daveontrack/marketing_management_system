import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'core/ai_notifier.dart';
import 'core/theme.dart';
import 'core/theme_notifier.dart';
import 'core/routes.dart';
import 'core/constants.dart';
import 'models/budget.dart';
import 'models/campaign.dart';
import 'models/content_item.dart';
import 'models/customer.dart';
import 'models/influencer.dart';
import 'models/lead.dart';
import 'models/opportunity.dart';
import 'models/promotion.dart';
import 'services/auth_service.dart';
import 'widgets/auth/auth_gate.dart';
import 'widgets/auth/user_profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file for local development (ignored in production builds
  // that use --dart-define).
  await dotenv.load();

  // ── Backend (Supabase) ────────────────────────────────────────────────────
  // initialize() itself never throws for placeholder credentials; remote
  // queries fail soft inside the remote stores, so the app falls back to
  // bundled seed data until real keys are provided in
  // lib/config/supabase_config.dart.
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // Load all synced modules from the database into their in-memory
  // repositories before the first screen renders. Falls back to seed data
  // when offline. Each init() runs once and seeds an empty remote table
  // automatically on first launch.
  //
  // Every init is additionally guarded below so that even if one repository
  // initialization throws unexpectedly, the remaining repositories still
  // finish and the app always reaches runApp().
  Future<void> safeInit(Future<void> Function() init) async {
    try {
      await init();
    } catch (_) {
      // Fail soft: this module keeps its bundled seed data.
    }
  }

  await Future.wait([
    CampaignRepository.init,
    CustomerRepository.init,
    LeadRepository.init,
    OpportunityRepository.init,
    BudgetRepository.init,
    PromotionRepository.init,
    InfluencerRepository.init,
    ContentRepository.init,
  ].map(safeInit));

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
              home: const AuthGate(),
              routes: AppRoutes.routes,
              // UserProfileProvider must be placed INSIDE the Navigator so
              // every route can find it via context. The builder callback
              // receives the Navigator's context, not MaterialApp's parent.
              builder: (context, child) {
                return UserProfileProvider(
                  authService: AuthService(),
                  child: child!,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
