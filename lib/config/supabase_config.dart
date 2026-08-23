// ─────────────────────────────────────────────────────────────────────────────
// SupabaseConfig
//
// Central place for Supabase connection settings.
//
// HOW TO CONFIGURE:
//   1. Open your project at https://supabase.com/dashboard
//   2. Go to Project Settings → API
//   3. Copy the "Project URL" into [url] below
//   4. Copy the anon/public "API Key" into [anonKey] below
//
// Until real values are provided the app still runs normally using the
// bundled seed data — every remote call fails silently and is ignored.
//
// SECURITY NOTE: the anon key is safe to embed in a client app ONLY when
// Row Level Security policies limit what it can access. See
// supabase_schema.sql at the repository root.
// ─────────────────────────────────────────────────────────────────────────────

class SupabaseConfig {
  SupabaseConfig._();

  static const String url =
      'https://tuquxbzoknjsnobendvb.supabase.co';

  static const String anonKey =
      'sb_publishable_lrBrGPqHKQurAnwVUtSt_A_2nq_UVtJ';

  /// True when real credentials have been filled in.
  static bool get isConfigured =>
      !url.contains('YOUR_PROJECT_REF') &&
      !anonKey.startsWith('YOUR_');
}
