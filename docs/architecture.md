# Architecture

## Overview

The system is a **single Rails 8 app** that serves two interfaces from one codebase:

- **JSON API** → consumed by the Flutter mobile app (customer + staff)
- **HTML + Hotwire** → admin dashboard + marketing/landing pages (accessed via browser)

Shared models, shared business logic, shared authentication — zero duplication.

## System Diagram

```
┌────────────────────┐  ┌────────────────────────────────┐
│  Flutter Mobile    │  │  Hotwire Web (Browser)         │
│  (iOS + Android)   │  │                                │
│                    │  │  Marketing / Landing pages     │
│  Customer:         │  │  Pricing + Sign-up flow        │
│  - QR wallet       │  │                                │
│  - Points view     │  │  Admin Dashboard:              │
│  - Rewards         │  │  - Analytics (Turbo Frames)    │
│  - History         │  │  - Campaigns CRUD              │
│  - Profile         │  │  - Rewards CRUD                │
│                    │  │  - Staff management            │
│  Staff:            │  │  - Customer segments           │
│  - QR scanner      │  │  - Stripe billing portal       │
│  - Check-in        │  │                                │
│  - Redemptions     │  │  Tailwind CSS + Stimulus       │
└─────────┬──────────┘  └───────────────┬────────────────┘
          │ HTTPS/JSON                  │ HTTPS/HTML+Turbo
          ▼                             ▼
┌──────────────────────────────────────────────────────────┐
│                  Rails 8 (Full App)                      │
│                                                          │
│  app/controllers/                                        │
│    api/v1/       ← JSON responses for Flutter            │
│    admin/        ← Hotwire views (Turbo + Stimulus)      │
│    pages/        ← Marketing pages                       │
│                                                          │
│  Shared layer:                                           │
│  - Models & business logic                               │
│  - Authentication (built-in generator + JWT for API)     │
│  - Stripe billing (subscriptions + Connect)              │
│  - Solid Queue (background jobs)                         │
│  - Solid Cache (fragment + API caching)                  │
│  - Solid Cable (real-time via Turbo Streams)             │
│  - Multi-tenancy (acts_as_tenant)                        │
│  - Pundit (authorization)                                │
└───────────────────────────┬──────────────────────────────┘
                            │
                            ▼
              ┌──────────────────┐  ┌──────────────────┐
              │  PostgreSQL      │  │  Stripe API      │
              │  (+ Solid*)      │  │  - Customers     │
              │  - Tenants       │  │  - Subscriptions │
              │  - Users         │  │  - Payments      │
              │  - Points        │  │  - Webhooks      │
              │  - Rewards       │  │  - Products      │
              │  - Visits        │  │                  │
              └──────────────────┘  └──────────────────┘

* Solid Queue, Solid Cache, and Solid Cable all use
  the same PostgreSQL database — no Redis needed.
```

## Why One App, Not Two

Keeping API + web in a single Rails app avoids the classic trap of duplicating business logic across services. The loyalty engine (points calculation, tier promotion, campaign multipliers) lives once in the models and service objects. Controllers are thin — `Api::V1::LoyaltyCardsController` renders JSON, `Admin::LoyaltyCardsController` renders HTML via Turbo Frames. Same query, different format.

## Multi-Tenancy

Each business (barbershop, salon, etc.) is a **Tenant**. The `acts_as_tenant` gem scopes all queries automatically. One Rails deploy serves all businesses — true SaaS.

## Hotwire Specifics

- **Turbo Drive** — instant page navigation across admin and marketing (no full reloads).
- **Turbo Frames** — dashboard widgets load independently. Edit campaigns inline.
- **Turbo Streams** — real-time updates over WebSocket (Solid Cable). Check-in → dashboard counter updates live.
- **Stimulus** — lightweight JS for chart rendering, form validation, dropdowns, copy-to-clipboard.

## Rails 8 Solid Trifecta

- **Solid Queue** — Background jobs via PostgreSQL. Replaces Sidekiq/Redis. Battle-tested at HEY (20M+ jobs/day).
- **Solid Cache** — Database-backed caching. Replaces Redis/Memcached for fragment caching.
- **Solid Cable** — WebSocket adapter via database. Replaces Redis for ActionCable.

One PostgreSQL database handles everything — data, jobs, cache, WebSockets. No Redis.

## Authentication (Dual Mode)

- **Web (Hotwire):** Rails 8 built-in authentication generator. Cookie-based sessions.
- **Mobile (Flutter):** JWT tokens issued by `Api::V1::AuthController`. Stateless.
- **Authorization:** Pundit for role-based access across both interfaces.

## Rails App Structure

```
app/
  controllers/
    application_controller.rb
    pages_controller.rb              # Marketing: landing, pricing, features
    sessions_controller.rb           # Web login (built-in auth)
    registrations_controller.rb      # Web sign-up
    api/
      v1/
        base_controller.rb           # JWT auth, JSON responses
        auth_controller.rb           # Mobile login, token refresh
        loyalty_cards_controller.rb
        rewards_controller.rb
        redemptions_controller.rb
        staff/
          check_ins_controller.rb
          visits_controller.rb
          redemptions_controller.rb
    admin/
      base_controller.rb             # Web auth + tenant scoping
      dashboard_controller.rb
      campaigns_controller.rb
      rewards_controller.rb
      users_controller.rb
      subscriptions_controller.rb
    webhooks/
      stripe_controller.rb

  views/
    layouts/
      application.html.erb           # Marketing layout
      admin.html.erb                 # Admin dashboard layout
    pages/
      landing.html.erb
      pricing.html.erb
      features.html.erb
    admin/
      dashboard/
        show.html.erb
        _visits_chart.html.erb       # Turbo Frame
        _stats.html.erb              # Turbo Frame
        _activity.html.erb           # Turbo Frame
      campaigns/
      rewards/
      users/

  javascript/
    controllers/                     # Stimulus controllers
      chart_controller.js
      clipboard_controller.js
      dropdown_controller.js
      form_validation_controller.js

  models/                            # Shared across API + web
    tenant.rb
    user.rb
    loyalty_card.rb
    point_transaction.rb
    reward.rb
    redemption.rb
    visit.rb
    campaign.rb
```

## Key Gems

- `turbo-rails` + `stimulus-rails` — Hotwire (ships with Rails 8)
- `tailwindcss-rails` — Tailwind CSS (ships with Rails 8)
- `solid_queue` / `solid_cache` / `solid_cable` — ships with Rails 8
- `stripe` — official Stripe Ruby SDK
- `acts_as_tenant` — automatic tenant scoping
- `pundit` — authorization (role-based)
- `jwt` — JSON Web Tokens for Flutter API
- `rpush` or `fcm` — push notifications
- `rack-cors` — CORS for Flutter app
- `blueprinter` or `alba` — JSON serialization
- `pagy` — pagination
- `chartkick` + `groupdate` — admin dashboard charts
- `inline_svg` — SVG icons
