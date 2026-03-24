# Loyalty Card SaaS — Progress Tracker

## Phase Status

| Phase | Status | Branch | Notes |
|-------|--------|--------|-------|
| P0: Tracking setup | done | main | PROGRESS.md created |
| P1: Rails foundation | done | main | 9 models, 11 migrations, seeds, all config |
| P2: Auth & authorization | done | main | JWT + cookies + Pundit policies |
| P3: Admin dashboard | done | main | Bento grid, Turbo Frames, all CRUD views |
| P4: Marketing pages | done | main | Landing, pricing, features, login/register |
| P5: JSON API | done | main | 6 blueprints, 3 services, 8 controllers |
| P6: Stripe billing | done | main | Checkout, webhooks, plan enforcement |
| P7: Flutter app | done | main | 34 Dart files, all screens + providers |
| P8: Real-time polish | done | main | Turbo Streams, 6 Stimulus controllers, chartkick |
| P9: Deploy & dogfood | done | main | Render config, env config, production rake task |

## What's Built

### Backend (Rails 8)
- 9 models with multi-tenancy (acts_as_tenant)
- Cookie auth (web) + JWT auth (mobile API)
- Pundit role-based authorization
- Admin dashboard with bento grid layout
- All CRUD for rewards, users, campaigns, visits
- Marketing pages (landing, pricing, features)
- JSON API with Blueprinter serialization
- Stripe Checkout + webhooks + plan enforcement
- Turbo Streams for live dashboard updates
- 6 Stimulus controllers (dropdown, sidebar, flash, clipboard, tabs, counter)
- Chartkick charts with Chart.js

### Mobile (Flutter)
- Core: theme, API client, auth interceptor, secure storage, GoRouter
- Auth: login, register screens with Riverpod state
- Loyalty card: gold card widget, card screen, point transactions
- Rewards: catalog, detail, redeem flow
- Staff: QR scanner, visits list, profile
- Customer: profile with tier progress
- Configurable API URL via --dart-define
- 0 errors on `flutter analyze`

### Deployment
- Dockerfile (multi-stage, Thruster + Puma, non-root user)
- render.yaml (Render Blueprint with PostgreSQL + env vars)
- bin/render-build.sh (build script)
- Procfile
- .env.example (all env vars documented)
- Production seed: `bin/rails setup:barbershop`
- Production.rb: SSL, allowed hosts, health check, Solid Trifecta
- Flutter EnvConfig for --dart-define API_BASE_URL

## Boot Instructions

```bash
# Backend (development)
cd backend
bundle install
bin/rails db:create db:migrate db:seed
bin/rails server

# Mobile (development)
cd mobile
flutter pub get
flutter run

# Mobile (production)
flutter run --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1
flutter build apk --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1
```

## Deploy to Render

1. Push code to GitHub
2. On Render, click "New" > "Blueprint" and select the repo
3. Render reads `render.yaml` and creates the web service + PostgreSQL
4. Set environment variables in Render dashboard:
   - `RAILS_MASTER_KEY` — from `backend/config/master.key`
   - `STRIPE_SECRET_KEY` — from Stripe dashboard
   - `STRIPE_PUBLISHABLE_KEY` — from Stripe dashboard
   - `STRIPE_WEBHOOK_SECRET` — create webhook in Stripe pointing to `https://your-app.onrender.com/webhooks/stripe`
   - `STRIPE_STARTER_PRICE_ID`, `STRIPE_PRO_PRICE_ID`, `STRIPE_ENTERPRISE_PRICE_ID` — create products in Stripe
   - `APP_HOST` — your-app.onrender.com (or custom domain)
5. Deploy triggers automatically
6. Run production seed: `bin/rails setup:barbershop` (via Render shell, set `OWNER_PASSWORD`)
7. Build Flutter app: `flutter build apk --dart-define=API_BASE_URL=https://your-app.onrender.com/api/v1`

## Seed Data (development)
- Owner: owner@demo.com / password123
- Staff: staff@demo.com / password123
- 5 sample customers with loyalty cards
- 5 rewards, 1 campaign, visits with points

## Blockers

None. All 9 phases complete.
