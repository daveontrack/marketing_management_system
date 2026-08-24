# MarketFlow — Marketing Management System

A cross-platform marketing admin dashboard built with **Flutter**, backed by a
**Supabase (PostgreSQL)** database. Manage campaigns, customers, leads, sales
opportunities, budgets, promotions, influencers, and content from one
responsive web/desktop/mobile app.

## Features

| Module | Capabilities | Persistence |
|---|---|---|
| Dashboard | KPI cards + 12 chart widgets, dynamic welcome banner | Supabase auth profile |
| Campaigns | list/search/filter, create, details, edit, delete | Supabase |
| Customers | segment stats, search/filter, full CRUD | Supabase |
| Leads | pipeline stats, scoring, full CRUD | Supabase |
| Opportunities | kanban board, stage tracking, full CRUD | Supabase |
| Budgets | allocation vs. spend charts, utilization status, full CRUD | Supabase |
| Promotions | coupon codes, usage limits, full CRUD | Supabase |
| Influencers | roster stats, full CRUD | Supabase |
| Content | calendar/schedule views, duplicate-as-draft, full CRUD | Supabase |
| Reports | create/update report records | local only |
| Users & Roles | user management, role assignment, approve/reject | Supabase |
| Communications / Automation / Notifications | working UI, screen-local state | local only |
| AI Assistant | rule-based Q&A over live repository data | n/a |
| **Auth** | **public signup → pending approval → admin activate → login** | **Supabase Auth** |
| **Profile** | **dynamic profile page showing authenticated user data** | **Supabase** |

## Authentication & User Lifecycle

MarketFlow implements a complete user management flow:

```
NEW USER
    │
    ▼
Create Account (SignupScreen)
    │
    ▼
Supabase Auth User (auth.users)
    │
    ▼
Database Trigger → public.users
    role = viewer
    status = pending
    │
    ▼
"Pending administrator approval"
    │
    ▼
ADMIN (Users & Roles)
    │
    ├──► Reject → status = inactive → cannot log in
    │
    └──► Approve → status = active
                │
                ▼
           USER receives invitation
                │
                ▼
           Set Password → Login
                │
                ▼
        Auth + Profile + Role + Permissions
                │
                ▼
        Correct Dashboard (role-based UI)
```

### Auth Flow Details

- **Public Signup**: Users request an account via `SignupScreen`. A database
  trigger automatically creates their profile with `role=viewer` and
  `status=pending`. They cannot log in until approved.
- **Admin Approval**: Admins can view all users in Users & Roles, toggle
  status between active/inactive, and edit roles and departments.
- **Login**: `AuthService.signIn()` validates credentials, loads the user
  profile from `public.users`, checks status, and caches role-based
  permissions.
- **Profile**: The Profile page reads from `UserProfileProvider` to display
  the currently authenticated user's real data — no hardcoded values.
- **Sign Out**: Clears cached profile and permissions, returns to login.

### Security

- Public signup **cannot** select role or status (enforced by database trigger)
- No passwords stored in `public.users` — Supabase Auth handles authentication
- No `service_role` key in Flutter client
- RLS policies restrict data access to authenticated users
- Admin operations use `get_my_role()` security-definer function

### Roles & Permissions

| Role | Description |
|---|---|
| Administrator | Full system access — manage all users, roles, settings, data |
| Marketing Manager | Campaigns, leads, team activities — create/edit most content |
| Marketing Staff | Executes tasks — limited create and edit rights |
| Analyst | Read-only access to reports, leads, campaign data |
| Viewer | Browse summaries and dashboards only |

## Architecture

```
Flutter Application
        │
     Screens            one folder per module; UI only
        │
   AuthService          signIn / signUp / signOut / profile helpers
        │
  UserProfileProvider   InheritedWidget via MaterialApp.builder
        │               — all routes can access auth state
  Repositories          in-memory list = fast sync source of truth;
        │               every mutation mirrors to remote + init() at startup
  Remote Stores         mappers between Dart models and PostgREST rows;
        │               all calls fail-soft (try/catch + timeout)
     Supabase           hosted Postgres + auto REST API + Auth + Edge Functions
        │
    PostgreSQL          see supabase_schema.sql (8 tables + users table)
```

Key behaviors:

- **Instant UI** — reads/writes hit the repository's in-memory cache synchronously.
- **Fire-and-forget sync** — mutations push to Supabase asynchronously.
- **Fail-soft offline mode** — if the backend is unreachable the app silently keeps bundled seed data and never crashes.
- **Self-seeding** — an empty remote table is populated from bundled sample data on first run.
- **Guarded startup** — `main.dart` initializes Supabase first, then loads all repositories in parallel; one failing module cannot block launch.
- **UserProfileProvider** — placed via `MaterialApp.builder` so every route (including all named routes) can access the authenticated user's profile.

## Tech Stack

- Flutter / Dart
- `supabase_flutter` — database client + auth
- `fl_chart` — charts
- ChangeNotifier + InheritedWidget for theme/AI panel state
- Database triggers (PostgreSQL) for signup profile creation

## Getting Started

### 1. Set up the database

1. Create a free project at [supabase.com](https://supabase.com).
2. Open **SQL Editor → New query**, paste the entire contents of
   [`supabase_schema.sql`](supabase_schema.sql), and click **Run**.
3. Apply the users table and production RLS:
   - [`supabase/migrations/20260824_add_users_table.sql`](supabase/migrations/20260824_add_users_table.sql)
   - [`supabase/migrations/20260824_production_rls.sql`](supabase/migrations/20260824_production_rls.sql)
4. Apply the signup trigger:
   - [`supabase/migrations/20260825_signup_trigger.sql`](supabase/migrations/20260825_signup_trigger.sql)

> The signup trigger creates a `handle_new_user()` function that automatically
> creates a `public.users` profile when someone signs up via Supabase Auth.

### 2. Configure credentials

Edit `lib/config/supabase_config.dart`:

```dart
static const String url = 'https://<your-project>.supabase.co';
static const String anonKey = '<your publishable/anon key>';
```

The anon key is a publishable key — safe for client apps, protected by RLS.

### 3. Run the app

```bash
flutter pub get
flutter run -d chrome      # web (easiest)
flutter run -d windows     # Windows desktop (needs VS C++ workload)
```

### 4. Test accounts

| Email | Password | Role | Department | Status |
|---|---|---|---|---|
| biruk.alemu@marketflow.et | Biruk@Admin2026! | Administrator | IT | active |
| hana.tsegaye@marketflow.et | Hana@Manager2026! | Marketing Manager | Marketing | active |
| robel.tesfaye@marketflow.et | Robel@Staff2026! | Marketing Staff | Creative | active |
| tigist.bekele@marketflow.et | Tigist@Analyst2026! | Analyst | Analytics | active |
| selamawit.girma@marketflow.et | Selam@Viewer2026! | Viewer | Sales | active |
| dawit.haile@marketflow.et | Dawit@Staff2026! | Marketing Staff | Marketing | inactive |
| yohannes.tadesse@marketflow.et | Yohannes@Manager2026! | Marketing Manager | Growth | pending |
| marta.desta@marketflow.et | Marta@Analyst2026! | Analyst | Analytics | pending |

## Database Schema

Tables in `supabase_schema.sql` plus the `users` table from migrations.

| Table | Primary key | Notes |
|---|---|---|
| users | uuid (auth.users FK) | application profile linked to Supabase Auth |
| campaigns | text | jsonb activities/coupons arrays |
| customers | int identity | unique email index |
| leads | int identity | score 0–100 check constraint |
| opportunities | int identity | five-stage pipeline |
| budgets | text | matches `lib/models/budget.dart` |
| promotions | text | `coupon_codes text[]` array column |
| influencers | text | avatar color derived in-app from id |
| content_items | text | type drives icon/color mapping |

Row Level Security is enabled on every table. Production RLS policies
enforce authenticated-only access with role-based admin restrictions.

## Project Structure

```
lib/
├── main.dart                  # init Supabase -> parallel repo init -> runApp
├── config/
│   └── supabase_config.dart   # project URL + anon key
├── core/                      # routes, theme, colors, constants, notifiers
├── models/                    # data classes + repositories (one per module)
├── services/
│   ├── auth_service.dart      # signIn / signUp / signOut / profile helpers
│   ├── campaign_remote_service.dart
│   ├── entity_remote_stores.dart   # Customer/Lead/Opportunity/Budget/
│   │                               # Promotion/Influencer/Content stores
│   ├── marketing_data_service.dart # read-only facade used by the AI
│   └── ai_service.dart             # rule-based assistant
├── widgets/
│   ├── auth/
│   │   ├── auth_gate.dart          # session restore + route guard
│   │   └── user_profile_provider.dart  # InheritedWidget for auth state
│   ├── layout/                     # sidebar, topbar, app shell
│   ├── common/                     # CustomButton, CustomTextField
│   └── ...                         # cards, badges, dialogs, charts
└── screens/
    ├── auth/
    │   ├── login_screen.dart       # email/password login
    │   └── signup_screen.dart      # public account request
    ├── dashboard/                  # KPI cards + charts
    ├── profile/                    # dynamic authenticated user profile
    ├── users/                      # user management + roles & permissions
    └── ...                         # 21 routed pages, one folder per module

supabase/
└── migrations/
    ├── 20260824_add_users_table.sql    # users table + seed data
    ├── 20260824_production_rls.sql     # production RLS policies
    └── 20260825_signup_trigger.sql     # auto-create profile on signup
```

## Adding a New Synced Module

Follow the established three-step pattern (see Influencers or Content for a
minimal example):

1. Add a remote store class in `lib/services/entity_remote_stores.dart`.
2. Give the model's repository `init/add/update/remove/nextId` methods that
   call the store fire-and-forget.
3. Register the repository's `init()` in `lib/main.dart` and create its table
   in `supabase_schema.sql`.

## Roadmap

- [x] Real authentication (Supabase Auth) wired into the login screen
- [x] Public signup with pending approval workflow
- [x] Admin user management (Users & Roles)
- [x] Role-based permission system (5 roles)
- [x] Profile page shows authenticated user data
- [ ] Supabase Edge Function for admin user creation (currently falls back to local)
- [ ] Point Dashboard KPIs/charts at live repository data
- [ ] Realtime updates via Supabase streams
- [ ] Email notifications for account approval

## Known Limitations

- Dashboard analytics currently render static demo numbers.
- Reports/Notifications/Automation/Communications reset on restart.
- Admin user creation falls back to local list when Edge Function is not deployed.
