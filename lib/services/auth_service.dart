// ─────────────────────────────────────────────────────────────────────────────
// AuthService
//
// Wraps Supabase Auth for email/password login, sign-out, and profile loading.
// The logged-in user's application role, department, and status live in the
// public.users table (linked to auth.users via UUID).
//
// Usage:
//   final profile = await AuthService().signIn(email: '...', password: '...');
//   final role = profile['role'];          // 'admin', 'marketing_manager', …
//   final status = profile['status'];      // 'active', 'inactive', 'pending'
//
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart'
    show AuthException, AuthResponse, Session, Supabase, SupabaseClient, User;
import '../models/user_role_models.dart';

/// Application-level auth exception (distinct from Supabase's AuthException).
class AppAuthException implements Exception {
  final String message;
  const AppAuthException(this.message);
  @override
  String toString() => message;
}

class AuthService {
  AuthService._();
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Cached user profile from `public.users` — populated after sign-in.
  Map<String, dynamic>? _cachedProfile;

  /// The user's permission matrix, derived from their role.
  List<ModulePermission>? _cachedPermissions;

  // ── Sign in ──────────────────────────────────────────────────────────────

  /// Authenticates the user via email + password.
  ///
  /// Returns the user's application profile from `public.users`.
  ///
  /// Throws [AppAuthException] with spec-compliant messages for:
  ///   - Invalid credentials
  ///   - Missing profile
  ///   - Inactive account
  ///   - Pending account
  ///   - Network errors
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResponse res;
    try {
      res = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
    } on AuthException catch (e) {
      developer.log('Supabase AuthException: ${e.message}', name: 'AuthService');
      // Map Supabase error messages to user-friendly versions.
      final msg = e.message.toLowerCase();
      if (msg.contains('invalid login') ||
          msg.contains('invalid email') ||
          msg.contains('invalid password') ||
          msg.contains('email not confirmed')) {
        throw const AppAuthException('Invalid email or password.');
      }
      throw AppAuthException(e.message);
    } catch (e) {
      developer.log('Unexpected signIn error: $e', name: 'AuthService');
      throw const AppAuthException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }

    final user = res.user;
    if (user == null) {
      throw const AppAuthException('Invalid email or password.');
    }

    // ── Load application profile ───────────────────────────────────────────
    final Map<String, dynamic> profile;
    try {
      profile = await _loadProfile(user.id);
    } on AppAuthException {
      // Profile doesn't exist — sign out and reject.
      await _supabase.auth.signOut();
      rethrow;
    }

    // ── Check account status ───────────────────────────────────────────────
    final status = profile['status'] as String? ?? 'pending';
    if (status != 'active') {
      await _supabase.auth.signOut();
      if (status == 'pending') {
        throw const AppAuthException(
          'Your account is pending approval. Please contact an administrator.',
        );
      }
      throw const AppAuthException(
        'Your account is inactive. Please contact an administrator.',
      );
    }

    // ── Cache profile & permissions ────────────────────────────────────
    _cachedProfile = profile;
    _cachedPermissions =
        UserRoleRepository.getPermissionsForRole(profile['role'] as String? ?? 'viewer');

    return profile;
  }

  // ── Sign up ──────────────────────────────────────────────────────────────

  /// Registers a new user. The profile row is created automatically via
  /// a database trigger or must be inserted separately by an admin.
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'full_name': fullName},
      );
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw const AppAuthException(
        'Unable to connect to the server. Please check your internet connection.',
      );
    }
  }

  // ── Sign out ─────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    _cachedProfile = null;
    _cachedPermissions = null;
    await _supabase.auth.signOut();
  }

  // ── Current user / session ───────────────────────────────────────────────

  /// Returns the raw Supabase auth [User], or null if not authenticated.
  User? get currentUser => _supabase.auth.currentUser;

  /// Returns the current session, or null if expired/absent.
  Session? get currentSession => _supabase.auth.currentSession;

  /// Returns true if there is a valid Supabase session.
  bool get isAuthenticated => currentSession != null && currentUser != null;

  /// Alias for [currentUser] — returns the raw Supabase auth [User].
  User? getCurrentUser() => currentUser;

  // ── Profile helpers ──────────────────────────────────────────────────────

  /// The cached user profile. Only available after a successful signIn.
  /// Returns null if no user has signed in (or after signOut).
  Map<String, dynamic>? get currentProfile => _cachedProfile;

  /// The cached permission matrix for the current user.
  List<ModulePermission>? get currentPermissions => _cachedPermissions;

  /// Returns the cached role string, falling back to 'viewer'.
  String get currentRole =>
      _cachedProfile?['role'] as String? ?? 'viewer';

  /// Returns the cached full name, or 'User' if unavailable.
  String get currentName =>
      _cachedProfile?['full_name'] as String? ?? 'User';

  /// Returns the cached email, or an empty string.
  String get currentEmail =>
      _cachedProfile?['email'] as String? ?? '';

  /// Two-letter initials derived from the cached full name.
  String get currentInitials {
    final parts = currentName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Returns the cached status string, or 'pending'.
  String get currentStatus =>
      _cachedProfile?['status'] as String? ?? 'pending';

  /// Returns the cached department, or 'General'.
  String get currentDepartment =>
      _cachedProfile?['department'] as String? ?? 'General';

  /// Fetches the user's application profile from `public.users`.
  Future<Map<String, dynamic>> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) {
      throw const AppAuthException('No authenticated user.');
    }
    return _loadProfile(user.id);
  }

  /// Returns the application role string (e.g. 'admin', 'marketing_manager').
  Future<String> getCurrentRole() async {
    final profile = await getCurrentProfile();
    return profile['role'] as String? ?? 'viewer';
  }

  /// Returns true if the user's application status is 'active'.
  Future<bool> isActive() async {
    final profile = await getCurrentProfile();
    return profile['status'] == 'active';
  }

  /// Attempts to restore a cached profile from an existing session.
  /// Returns the profile if the session is valid and the user is active.
  /// Returns null if no session, missing profile, or inactive/pending status
  /// (and signs out the user in those cases).
  Future<Map<String, dynamic>?> restoreSession() async {
    if (!isAuthenticated) return null;

    try {
      final user = currentUser!;
      final profile = await _loadProfile(user.id);

      final status = profile['status'] as String? ?? 'pending';
      if (status != 'active') {
        await signOut();
        return null;
      }

      // Cache profile & permissions.
      _cachedProfile = profile;
      _cachedPermissions =
          UserRoleRepository.getPermissionsForRole(profile['role'] as String? ?? 'viewer');

      return profile;
    } catch (e) {
      developer.log('Session restore failed: $e', name: 'AuthService');
      await signOut();
      return null;
    }
  }

  // ── Permission helpers ───────────────────────────────────────────────────

  /// Checks whether the current user's role grants permission for the
  /// given module with at least [type] access.
  bool hasPermission(String module, PermissionType type) {
    if (_cachedPermissions == null) return false;
    for (final p in _cachedPermissions!) {
      if (p.module == module) {
        switch (type) {
          case PermissionType.view:   return p.view;
          case PermissionType.create: return p.create;
          case PermissionType.edit:   return p.edit;
          case PermissionType.delete: return p.delete;
        }
      }
    }
    return false;
  }

  /// Convenience: can the current user view [module]?
  bool canView(String module) => hasPermission(module, PermissionType.view);

  /// Convenience: can the current user create in [module]?
  bool canCreate(String module) => hasPermission(module, PermissionType.create);

  /// Convenience: can the current user edit [module]?
  bool canEdit(String module) => hasPermission(module, PermissionType.edit);

  /// Convenience: can the current user delete from [module]?
  bool canDelete(String module) => hasPermission(module, PermissionType.delete);

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _loadProfile(String userId) async {
    try {
      final data = await _supabase
          .from('users')
          .select('id, full_name, email, role, department, status, created_at')
          .eq('id', userId)
          .single();
      return data;
    } catch (e) {
      developer.log('Failed to load profile for $userId: $e', name: 'AuthService');
      throw const AppAuthException(
        'Your user profile could not be found. Please contact an administrator.',
      );
    }
  }
}
