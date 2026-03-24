# Loyalty Card SaaS — Claude Code Instructions

## Project Overview

White-label loyalty card SaaS. Monorepo with two apps:

- `backend/` — Rails 8 full app (Hotwire web admin + JSON API for mobile)
- `mobile/` — Flutter app (customer QR wallet + staff scanner)

Owner: Jorge Padilla (Rails developer, owns a barbershop — first customer).

## Architecture

Single Rails 8 app serving two interfaces from one codebase:

- **JSON API** (`/api/v1/`) → Flutter mobile app (customer + staff)
- **HTML + Hotwire** (`/admin/`, `/pages/`) → admin dashboard + marketing pages

PostgreSQL only. No Redis — uses Solid Queue, Solid Cache, Solid Cable (Rails 8 Solid Trifecta).

## Tech Stack

### Backend (Rails 8)
- Rails 8.0 with `load_defaults 8.0`
- PostgreSQL (only database)
- Hotwire: Turbo Drive, Turbo Frames, Turbo Streams, Stimulus
- Tailwind CSS via `tailwindcss-rails` gem
- Importmap (no Node.js/esbuild/webpack)
- Authentication: Rails 8 built-in auth generator (cookie sessions for web) + JWT for mobile API
- Authorization: Pundit (roles: owner, manager, staff, customer)
- Multi-tenancy: `acts_as_tenant` gem — every model scoped to Tenant
- Stripe: SaaS billing (subscriptions). Stripe Connect deferred to Phase 2
- JSON serialization: Blueprinter
- Charts: Chartkick + Groupdate
- Background jobs: Solid Queue
- Caching: Solid Cache
- WebSockets: Solid Cable
- Pagination: Pagy

### Mobile (Flutter)
- State management: Riverpod
- HTTP: Dio
- Routing: GoRouter
- QR scanning: mobile_scanner
- QR generation: qr_flutter

## Design Theme — Off-White + Matte Black

Premium through restraint. Think Apple Card, Aesop, Cereal magazine.

- Background: `#FAF9F6` (warm cream)
- Primary: `#1A1A1A` (matte black) — text, buttons, icons
- Secondary: `#6B6B6B` — labels, timestamps
- Border: `#E5E4E1` — card borders, dividers
- Gold: `#C9A84C` — **ONLY on the loyalty card widget** (gradient, edge, tier badge)
- Success: `#2D6A4F` — deep green
- Error: `#C1292E` — muted red
- Fonts: Inter (body), Space Grotesk (numbers/points)
- NO gradients on UI chrome. Flat matte black buttons. 1px borders, no shadows.
- The loyalty card is the sole rich/indulgent element.

## Database Schema

9 models with multi-tenancy:

```
Tenant → has_many :users, :loyalty_cards, :rewards, :campaigns, :visits; has_one :subscription
User → belongs_to :tenant; has_one :loyalty_card (if customer); roles: owner/manager/staff/customer
LoyaltyCard → belongs_to :user; tiers: bronze/silver/gold/platinum; has QR code UUID
PointTransaction → immutable ledger; kinds: earned/redeemed/adjusted/expired
Reward → points_cost, reward_type, tier_required, active flag
Redemption → status: pending/confirmed/rejected/expired
Visit → check-in/check-out, service_name, amount, points_earned
Campaign → multiplier, date range, target_segment JSONB
Subscription → mirrors Stripe subscription state
```

## SaaS Pricing Tiers

| Plan | Price | Limits |
|------|-------|--------|
| Free | $0/mo | 50 customers, 1 staff |
| Starter | $29/mo | 500 customers, 5 staff |
| Pro | $79/mo | Unlimited customers, 15 staff |
| Enterprise | $199/mo | Unlimited everything |

## Current State

The backend has all models, controllers, views, services, policies, blueprints, and migrations scaffolded. The mobile app has all screens, providers, repositories, and models scaffolded.

### What needs to happen to boot the Rails app:

```bash
cd backend
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

If `bin/rails` doesn't work, use `bundle exec rails` instead.

### Seed data creates:
- Demo Barbershop tenant (Starter plan)
- Owner: owner@demo.com / password123
- Staff: staff@demo.com / password123
- 5 sample customers with loyalty cards
- 5 rewards, 1 campaign, visits

## Build Order (MVP)

1. ✅ Rails 8 app setup — models, controllers, views, migrations, config
2. ✅ Flutter project setup — screens, providers, repositories, models
3. ✅ Rails boots clean — `bin/rails db:create db:migrate db:seed && bin/rails server`
4. ✅ Admin dashboard with real data (Turbo Frames, bento grid)
5. ✅ Marketing pages (landing, pricing, features)
6. ✅ JSON API for Flutter (blueprints, services, controllers)
7. ✅ Stripe subscription billing (checkout, webhooks, plan enforcement)
8. ✅ Real-time updates (Turbo Streams, Stimulus controllers, Chartkick)
9. 🔲 Deploy and dogfood at barbershop

## Key Conventions

- Controllers are thin. Business logic in models and service objects.
- API controllers inherit from `Api::V1::BaseController` (JWT auth, JSON responses).
- Admin controllers inherit from `Admin::BaseController` (cookie auth, Turbo/HTML responses).
- All database queries are auto-scoped to current tenant via `acts_as_tenant`.
- Use Turbo Frames for dashboard widgets and inline editing.
- Use Turbo Streams (over Solid Cable) for real-time updates.
- Stimulus controllers for client-side behavior (charts, dropdowns, clipboard).
- Blueprinter for all JSON API serialization (not Jbuilder).
- Pagy for pagination.

## Docs

See `docs/` folder for detailed specs:
- `architecture.md` — system diagram, Hotwire specifics, why single app
- `database-schema.md` — all models and relationships
- `api-endpoints.md` — full API spec for Flutter
- `theme-guide.md` — colors, typography, Tailwind config, design principles
- `mvp-scope.md` — phases, timeline, build order, pricing
