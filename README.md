# MarkFlow — Marketing Management System

A full-stack **Flutter** marketing management dashboard backed by **Supabase (PostgreSQL)** with real authentication, role-based access control, and a complete user lifecycle.

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)

---

## Overview

MarkFlow is a cross-platform (web, desktop, mobile) marketing management system that allows teams to manage campaigns, customers, leads, sales opportunities, budgets, promotions, influencers, and content — all from a single responsive application.

### Key Capabilities

- **Real Authentication** — Supabase Auth with email/password login
- **Public Signup** — Self-registration with admin approval workflow
- **5-Role Permission System** — Administrator, Marketing Manager, Marketing Staff, Analyst, Viewer
- **Full CRUD** — Campaigns, Customers, Leads, Opportunities, Budgets, Promotions, Influencers, Content
- **Dynamic Profile** — Profile page always shows the authenticated user's real data
- **AI Assistant** — Rule-based marketing Q&A over live repository data
- **Dark Mode** — Full light/dark theme support
- **Responsive Layout** — Desktop sidebar, tablet drawer, mobile navigation

---

## User Lifecycle

```
  ┌─────────────┐
  │  NEW USER    │
  └──────┬──────┘
         ▼
  ┌─────────────────────────┐
  │  SignupScreen           │
  │  (Full Name, Email,     │
  │   Dept, Password)       │
  └──────────┬──────────────┘
             ▼
  ┌─────────────────────────┐
  │  Supabase Auth          │
  │  auth.users created     │
  └──────────┬──────────────┘
             ▼
  ┌─────────────────────────┐
  │  Database Trigger       │
  │  → public.users         │
  │  role = viewer          │
  │  status = pending       │
  └──────────┬──────────────┘
             ▼
  ┌─────────────────────────┐
  │  "Pending admin         │
  │   approval"             │
  └──────────┬──────────────┘
             ▼
  ┌─────────────────────────┐
  │  ADMIN                  │
  │  Users & Roles          │
  │  → Approve (active)     │
  │  → or Reject (inactive) │
  └──────────┬──────────────┘
             ▼
  ┌─────────────────────────┐
  │  USER logs in           │
  │  → Dashboard            │
  │  → Profile              │
  │  → Role-based UI        │
  └─────────────────────────┘
```

---

## Features by Module

| Module | Capabilities | Data Source |
|--------|-------------|-------------|
| **Auth** | Login, Signup, Sign Out, Session Restore | Supabase Auth |
| **Dashboard** | KPI cards, charts, dynamic welcome banner | Supabase profile |
| **Campaigns** | List, search, filter, create, edit, delete, details | Supabase |
| **Customers** | Segment stats, full CRUD, search | Supabase |
| **Leads** | Pipeline stats, scoring, full CRUD | Supabase |
| **Opportunities** | Kanban board, stage tracking, full CRUD | Supabase |
| **Budgets** | Allocation vs spend, utilization, full CRUD | Supabase |
| **Promotions** | Coupon codes, usage limits, full CRUD | Supabase |
| **Influencers** | Roster stats, full CRUD | Supabase |
| **Content** | Calendar/schedule views, duplicate-as-draft, full CRUD | Supabase |
| **Reports** | Create, update report records | Local |
| **Users & Roles** | User management, role assignment, approve/reject | Supabase |
| **Profile** | Dynamic user profile, edit dialog | Supabase profile |
| **Communications** | Working UI | Local |
| **Automation** | Working UI | Local |
| **Notifications** | Working UI | Local |
| **AI Assistant** | Rule-based Q&A over live data | n/a |

---

## Roles & Permissions

| Role | Dashboard | Campaigns | Customers | Leads | Reports | Users & Roles | Settings |
|------|-----------|-----------|-----------|-------|---------|---------------|----------|
| **Administrator** | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Full | ✅ Edit |
| **Marketing Manager** | 👁 View | ✅ Create/Edit | ✅ Create/Edit | ✅ Create/Edit | 👁 View | 👁 View | ❌ |
| **Marketing Staff** | 👁 View | ✅ Create/Edit | 👁 View | 👁 View | 👁 View | 👁 View | ❌ |
| **Analyst** | 👁 View | 👁 View | 👁 View | 👁 View | 👁 View | 👁 View | ❌ |
| **Viewer** | 👁 View | 👁 View | ❌ | ❌ | 👁 View | ❌ | ❌ |

---

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| **Flutter / Dart** | Cross-platform UI framework |
| **Supabase Flutter** | Database client + authentication |
| **fl_chart** | Charts and data visualization |
| **PostgreSQL** | Relational database (via Supabase) |
| **Database Triggers** | Auto-create user profiles on signup |
| **InheritedWidget** | Auth state propagation (`UserProfileProvider`) |
| **ChangeNotifier** | Theme and AI panel state management |

---

## Getting Started

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) 3.x
- A [Supabase](https://supabase.com) project (free tier works)

### 1. Set Up the Database

Open your Supabase dashboard → **SQL Editor** → **New query**, and run these migrations in order:

```sql
-- Step 1: Core schema (8 data tables)
-- Paste contents of: supabase_schema.sql

-- Step 2: Users table + seed data
-- Paste contents of: supabase/migrations/20260824_add_users_table.sql

-- Step 3: Production RLS policies
-- Paste contents of: supabase/migrations/20260824_production_rls.sql

-- Step 4: Signup trigger (auto-creates profiles)
-- Paste contents of: supabase/migrations/20260825_signup_trigger.sql
```

### 2. Configure Credentials

Edit `lib/config/supabase_config.dart`:

```dart
static const String url = 'https://YOUR_PROJECT.supabase.co';
static const String anonKey = 'YOUR_ANON_KEY';
```

### 3. Install & Run

```bash
flutter pub get
flutter run -d chrome      # Web
flutter run -d windows     # Windows desktop
flutter run -d macos       # macOS desktop
```

---

## Test Accounts

| Email | Password | Role | Department | Status |
|-------|----------|------|------------|--------|
| biruk.alemu@marketflow.et | Biruk@Admin2026! | Administrator | IT | Active |
| hana.tsegaye@marketflow.et | Hana@Manager2026! | Marketing Manager | Marketing | Active |
| robel.tesfaye@marketflow.et | Robel@Staff2026! | Marketing Staff | Creative | Active |
| tigist.bekele@marketflow.et | Tigist@Analyst2026! | Analyst | Analytics | Active |
| selamawit.girma@marketflow.et | Selam@Viewer2026! | Viewer | Sales | Active |
| dawit.haile@marketflow.et | Dawit@Staff2026! | Marketing Staff | Marketing | Inactive |
| yohannes.tadesse@marketflow.et | Yohannes@Manager2026! | Marketing Manager | Growth | Pending |
| marta.desta@marketflow.et | Marta@Analyst2026! | Analyst | Analytics | Pending |

> **Note:** Inactive and pending users will be rejected at login.

---

## Database Schema

| Table | Key Type | Description |
|-------|----------|-------------|
| `users` | UUID (FK → auth.users) | Application profiles linked to Supabase Auth |
| `campaigns` | TEXT | Marketing campaigns with JSONB arrays |
| `customers` | INT IDENTITY | Customer records with unique email |
| `leads` | INT IDENTITY | Sales leads with 0–100 score |
| `opportunities` | INT IDENTITY | Sales pipeline (5 stages) |
| `budgets` | TEXT | Budget allocations and spend tracking |
| `promotions` | TEXT | Coupons with text[] array columns |
| `influencers` | TEXT | Influencer roster |
| `content_items` | TEXT | Content calendar and assets |

All tables have **Row Level Security** enabled with authenticated-only access policies.

---

## Project Structure

```
lib/
├── main.dart                          # App entry: Supabase init → repos → runApp
├── config/
│   └── supabase_config.dart           # Project URL + anon key
├── core/
│   ├── routes.dart                    # Named route table (21 routes)
│   ├── theme.dart                     # Light/dark theme definitions
│   ├── colors.dart                    # AppColors palette
│   ├── constants.dart                 # Spacing, breakpoints, labels
│   ├── theme_notifier.dart            # Theme mode switching
│   └── ai_notifier.dart              # AI panel open/close state
├── models/
│   ├── campaign.dart                  # Campaign model + repository
│   ├── customer.dart                  # Customer model + repository
│   ├── lead.dart                      # Lead model + repository
│   ├── opportunity.dart               # Opportunity model + repository
│   ├── budget.dart                    # Budget model + repository
│   ├── promotion.dart                 # Promotion model + repository
│   ├── influencer.dart                # Influencer model + repository
│   ├── content_item.dart              # Content model + repository
│   ├── user_role_models.dart          # AppUser, AppRole, permissions
│   └── dashboard_models.dart          # KPI stats, chart data
├── services/
│   ├── auth_service.dart              # Auth: signIn, signUp, signOut, profile
│   ├── campaign_remote_service.dart   # Campaign Supabase operations
│   ├── entity_remote_stores.dart      # CRUD stores for all modules
│   ├── marketing_data_service.dart    # Read-only facade for AI
│   └── ai_service.dart               # Rule-based AI assistant
├── widgets/
│   ├── auth/
│   │   ├── auth_gate.dart             # Session restore + route guard
│   │   └── user_profile_provider.dart # InheritedWidget for auth state
│   ├── layout/
│   │   ├── app_layout.dart            # Master shell (sidebar + topbar + body)
│   │   ├── app_sidebar.dart           # Navigation sidebar
│   │   └── app_topbar.dart            # Top action bar
│   ├── common/
│   │   ├── custom_button.dart         # Reusable button component
│   │   └── custom_textfield.dart      # Reusable text field component
│   ├── cards/                         # StatCard, KPI cards
│   ├── charts/                        # Campaign, Leads, Charts
│   └── dashboard/                     # Dashboard widget components
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart          # Email/password login
│   │   └── signup_screen.dart         # Public account request
│   ├── dashboard/dashboard_screen.dart
│   ├── campaigns/                     # List, create, edit, details
│   ├── customers/customers_screen.dart
│   ├── leads/leads_screen.dart
│   ├── opportunities/opportunities_screen.dart
│   ├── influencers/influencers_screen.dart
│   ├── content/content_screen.dart
│   ├── promotions/promotions_screen.dart
│   ├── budget/budget_screen.dart
│   ├── communications/communications_screen.dart
│   ├── automation/automation_screen.dart
│   ├── reports/reports_screen.dart
│   ├── notifications/notifications_screen.dart
│   ├── users/users_screen.dart        # User management + roles
│   ├── profile/profile_screen.dart    # Authenticated user profile
│   └── settings/settings_screen.dart

supabase/
└── migrations/
    ├── 20260824_add_users_table.sql   # Users table + seed data
    ├── 20260824_production_rls.sql    # Production RLS policies
    └── 20260825_signup_trigger.sql    # Auto-create profile on signup
```

---

## Architecture

```
┌──────────────────────────────────────────────────┐
│                  Flutter App                      │
├──────────────────────────────────────────────────┤
│  MaterialApp.builder                             │
│    └── UserProfileProvider (auth state)          │
│          ├── AuthGate (route guard)              │
│          │     ├── LoginScreen                   │
│          │     ├── SignupScreen                  │
│          │     └── AppLayoutPage (authenticated) │
│          │           ├── AppSidebar              │
│          │           ├── AppTopBar               │
│          │           └── Page Content            │
│          └── Screens read auth via               │
│              UserProfileProvider.of(context)     │
├──────────────────────────────────────────────────┤
│  AuthService (singleton)                         │
│    ├── signIn() → profile + permissions cache    │
│    ├── signUp() → Supabase Auth + trigger        │
│    ├── signOut() → clear cache                   │
│    ├── listUsers() → admin user list             │
│    └── updateUserProfile() → admin edits         │
├──────────────────────────────────────────────────┤
│  Repositories (in-memory cache)                  │
│    └── init() at startup → mirrors to Supabase   │
├──────────────────────────────────────────────────┤
│  Supabase (PostgreSQL + Auth + RLS)              │
└──────────────────────────────────────────────────┘
```

**Key Design Decisions:**

- **`UserProfileProvider` via `MaterialApp.builder`** — ensures all routes (named and pushed) can access the authenticated profile
- **Fail-soft offline mode** — if Supabase is unreachable, the app uses bundled seed data
- **Self-seeding repositories** — empty remote tables are populated from sample data on first run
- **Guarded startup** — one failing module cannot block the app from launching

---

## Security

| Requirement | Implementation |
|-------------|---------------|
| No passwords in public.users | ✅ Supabase Auth handles credentials |
| No service_role in Flutter | ✅ Only anon key used client-side |
| Signup can't set role/status | ✅ Database trigger hardcodes `role=viewer`, `status=pending` |
| Pending users blocked | ✅ `signIn()` rejects non-active profiles |
| RLS on all tables | ✅ Authenticated-only policies |
| Admin operations secured | ✅ `get_my_role()` security-definer function |

---

## Roadmap

- [x] Supabase Auth integration
- [x] Public signup with pending approval
- [x] Admin user management (Users & Roles)
- [x] 5-role permission system
- [x] Dynamic profile page
- [x] Production RLS policies
- [x] Database trigger for signup
- [ ] Supabase Edge Function for admin user creation
- [ ] Live Dashboard KPIs from database
- [ ] Realtime updates via Supabase subscriptions
- [ ] Email notifications for account approval
- [ ] Password reset flow

---

## License

This project is for educational purposes.
