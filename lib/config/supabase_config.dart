import 'package:flutter_dotenv/flutter_dotenv.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SupabaseConfig
//
// Central place for Supabase connection settings.
//
// Configuration priority:
//   1. --dart-define (production builds & CI)
//   2. .env file (local development)
//
// HOW TO CONFIGURE:
//   1. Open your project at https://supabase.com/dashboard
//   2. Go to Project Settings → API
//   3. Copy the "Project URL" into SUPABASE_URL
//   4. Copy the anon/public "API Key" into SUPABASE_ANON_KEY
//
// SECURITY NOTE: the anon key is safe to embed in a client app ONLY when
// Row Level Security policies limit what it can access. See
// supabase_schema.sql at the repository root.
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  SupabaseConfig._();

  // Read from --dart-define first, then .env file.
  static String get url =>
      const String.fromEnvironment('SUPABASE_URL') != ''
          ? const String.fromEnvironment('SUPABASE_URL')
          : dotenv.env['SUPABASE_URL'] ?? '';

  static String get anonKey =>
      const String.fromEnvironment('SUPABASE_ANON_KEY') != ''
          ? const String.fromEnvironment('SUPABASE_ANON_KEY')
          : dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  /// True when real credentials have been provided.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
