# Loyalty Card SaaS — Research Document

**Goal:** Build a white-label loyalty card system. Flutter mobile app (iOS + Android) backed by a **Rails 8 API** with Stripe for subscriptions and one-time payments. Initial deployment for a barbershop, but architected to sell to any service-based business.

**Design language:** Off-white + matte black minimalism inspired by Apple Card, Aesop, and high-end editorial design. Premium through restraint — clean surfaces, perfect typography, zero visual clutter. A touch of gold reserved exclusively for the loyalty card itself.

---

## 1. What a Good Loyalty System Does

A modern loyalty app goes well beyond the old paper stamp card. The best systems combine four pillars: **earning**, **redeeming**, **engaging**, and **managing**.

### Earning mechanics

- **Points-per-visit:** Customer checks in (QR scan or NFC tap) and earns a fixed number of points. Simple and familiar — the digital version of a stamp card.
- **Points-per-dollar:** Points proportional to spend. Better for businesses with variable ticket sizes (a haircut vs. a haircut + beard trim + product).
- **Bonus multipliers:** 2x points on slow days (Tuesday afternoon), on specific services, or during a promotional window.
- **Streak rewards:** Extra points for consecutive weekly visits. Gamification that drives habit formation.
- **Referral points:** Customer shares a code; both parties earn points when the referred person visits.

### Redeeming mechanics

- **Free service after N visits:** The classic "10th haircut free" — still the most understood model.
- **Points marketplace:** Redeem points for discounts, free add-ons (beard oil, styling product), or partner offers.
- **Tiered rewards:** Bronze / Silver / Gold members unlock progressively better perks (priority booking, exclusive products, birthday freebies).

### Engagement features

- **Push notifications:** Remind customers who haven't visited in X days. Announce flash promotions.
- **Digital receipt + history:** Every visit logged with service, barber, and amount — useful for the customer and the business.
- **Referral program:** Shareable invite link or code with tracked attribution.
- **Gamification:** Badges, challenges ("Try 3 different services this month"), leaderboards.

### Business management (admin dashboard)

- **Real-time analytics:** Active users, redemption rate, average visit frequency, revenue per loyalty member vs. non-member.
- **Campaign builder:** Create time-bound promotions (double points weekend, happy hour specials).
- **Customer segments:** Filter by visit frequency, spend level, last visit date. Target lapsed customers differently from regulars.
- **Multi-location support:** Points work across all branches. Staff see a unified customer profile.
- **Staff accounts with roles:** Owner, manager, cashier — each with appropriate permissions.

---

## 2. Competitors and Market Landscape

Before building, it's worth knowing what exists.

| Product | Model | Strengths | Gaps for us |
|---------|-------|-----------|-------------|
| **Stamp Me** | White-label SaaS | Barber/salon focus, simple stamp cards | No Stripe billing, limited customization |
| **Square Loyalty** | Tied to Square POS | Deep POS integration | Locked to Square ecosystem |
| **FiveStars** | Hardware + SaaS | NFC/tablet check-in | Expensive, US-focused |
| **Open Loyalty** | Open-source engine | Extremely flexible rules engine | Complex setup, no Flutter SDK |
| **LoyaltyLion** | E-commerce plugin | Shopify/WooCommerce integration | Not for service businesses |

**Our opportunity:** A Flutter + Rails stack that is open, developer-friendly, and specifically designed for service businesses (barbershops, salons, spas, gyms) with Stripe-native billing so the business owner subscribes to *our* platform via Stripe, and optionally their end-customers can pay through Stripe too.

---

## 3. Proposed Architecture

The system is a **single Rails 8 app** that serves two interfaces from one codebase:

- **JSON API** → consumed by the Flutter mobile app (customer + staff)
- **HTML + Hotwire** → admin dashboard + marketing/landing pages (accessed via browser)

This means shared models, shared business logic, shared authentication — zero duplication.

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

### Why one app, not two

Keeping API + web in a single Rails app avoids the classic trap of duplicating business logic across services. The loyalty engine (points calculation, tier promotion, campaign multipliers) lives once in the models and service objects. Controllers are thin — `Api::V1::LoyaltyCardsController` renders JSON, `Admin::LoyaltyCardsController` renders HTML via Turbo Frames. Same query, different format.

### Multi-tenancy approach

Each business (barbershop, salon, etc.) is a **Tenant**. The `acts_as_tenant` gem scopes all queries automatically. This means one Rails deploy serves all businesses — true SaaS.

### Hotwire specifics

- **Turbo Drive** — makes page navigation instant across the admin and marketing site (no full reloads).
- **Turbo Frames** — the admin dashboard loads stats, charts, and tables in frames that update independently. Edit a campaign inline without leaving the page.
- **Turbo Streams** — real-time updates over WebSocket (Solid Cable). When a customer checks in via the mobile app, the admin dashboard visit counter updates live. When a reward is redeemed, the staff sees it instantly.
- **Stimulus** — lightweight JS for interactions: chart rendering, form validation, date pickers, dropdown menus, copy-to-clipboard for referral codes. No heavy JS framework needed.

---

## 4. Database Schema (Key Models)

```ruby
# Tenant = the business that subscribes to our platform
Tenant
  - name, slug, logo_url, theme_color
  - stripe_customer_id        # their Stripe customer for billing us
  - stripe_subscription_id    # their SaaS subscription
  - plan (enum: free, starter, pro, enterprise)
  - settings (jsonb)          # points_per_visit, currency, etc.

# User = anyone (business owner, staff, or end customer)
User
  - tenant_id
  - email, phone, encrypted_password
  - role (enum: owner, manager, staff, customer)
  - stripe_customer_id        # for end-customer payments (optional)

# LoyaltyCard
  - tenant_id, user_id
  - qr_code (UUID)
  - tier (enum: bronze, silver, gold)
  - total_points, redeemed_points, current_points
  - visits_count
  - streak_count, last_visit_at

# PointTransaction
  - tenant_id, loyalty_card_id
  - kind (enum: earn, redeem, bonus, referral, adjustment)
  - points (integer, positive or negative)
  - description
  - staff_id (who processed it)
  - visit_id (nullable)

# Reward
  - tenant_id
  - name, description, image_url
  - points_cost
  - reward_type (enum: free_service, discount_percent, discount_fixed, product)
  - active (boolean)
  - tier_required (enum, nullable)

# Redemption
  - tenant_id, loyalty_card_id, reward_id
  - points_spent
  - status (enum: pending, confirmed, expired)

# Visit
  - tenant_id, user_id, staff_id
  - service_name, amount_cents
  - checked_in_at
  - points_earned

# Campaign
  - tenant_id
  - name, description
  - multiplier (e.g. 2.0 for double points)
  - starts_at, ends_at
  - target_segment (jsonb)
  - active (boolean)

# Subscription (SaaS billing)
  - tenant_id
  - stripe_subscription_id
  - stripe_price_id
  - status (enum: trialing, active, past_due, canceled)
  - current_period_end
```

---

## 5. Rails 8 (Full App) — Key Design Decisions

### Why Rails 8

Rails 8 ships with the **Solid Trifecta** — three database-backed adapters that eliminate the need for Redis entirely:

- **Solid Queue** — Background job processing backed by PostgreSQL. Replaces Sidekiq/Redis for most use cases. Already battle-tested at HEY handling 20M+ jobs/day. Perfect for webhook processing, push notification delivery, and analytics aggregation.
- **Solid Cache** — Disk-backed caching via the database. Replaces Redis/Memcached for fragment caching. Caches persist across deploys and can be much larger than RAM-based caches.
- **Solid Cable** — WebSocket adapter backed by the database. Replaces Redis for ActionCable. Powers real-time Turbo Streams on the admin dashboard and real-time points updates for the mobile app.

This dramatically simplifies our deployment: one PostgreSQL database handles everything — data, jobs, cache, and WebSockets. No Redis to manage, monitor, or pay for.

### Full app, not API-only

We use `rails new loyalty_saas -d postgresql` (no `--api` flag). This gives us the full Rails stack: views, layouts, asset pipeline, Hotwire (Turbo + Stimulus), and Tailwind CSS out of the box. The same app serves:

- **HTML + Hotwire** for the admin dashboard and marketing pages
- **JSON API** for the Flutter mobile app

This is handled by controller namespacing and `respond_to` blocks where needed.

### Authentication (dual mode)

Rails 8 ships with a built-in **authentication generator** (`rails generate authentication`) that scaffolds sign-up, login, logout, forgot-password, and session management. We use this directly for the web (Hotwire) side — cookie-based sessions, the Rails default.

For the Flutter mobile app, we add a thin JWT layer on top: the `Api::V1::AuthController` issues JWT tokens on login, and a `before_action` in the API base controller validates them. This keeps the web side simple (cookies) and the mobile side stateless (JWT).

We still add `pundit` for role-based authorization across both interfaces.

### Hotwire for the admin dashboard

The admin dashboard is a first-class Hotwire app:

- **Turbo Drive** — instant navigation between admin pages, no full reloads.
- **Turbo Frames** — each dashboard widget (visits chart, top customers, recent redemptions) is a frame that loads and refreshes independently. Edit a campaign or reward inline without leaving the page.
- **Turbo Streams** — when a customer checks in via the mobile app, the admin dashboard updates live. The check-in creates a Visit, and a `after_create_commit` callback broadcasts a Turbo Stream that appends the new visit to the activity feed and increments the counter. All powered by Solid Cable (no Redis).
- **Stimulus** — lightweight JS controllers for: chart rendering (Chart.js or Chartkick), date range pickers, dropdown menus, form validation, copy-to-clipboard for referral codes, and toggle switches.

### Marketing pages

The public-facing marketing site (landing page, pricing, features, sign-up) lives in the same Rails app under `PagesController`. Static-ish pages rendered with ERB + Tailwind. Simple, fast, SEO-friendly. No JS framework needed — Turbo Drive handles page transitions.

### Tailwind CSS + our theme

Tailwind ships with Rails 8 by default. We extend it with our off-white + matte black palette:

```js
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        cream:     '#FAF9F6',
        surface:   '#FFFFFF',
        matte:     '#1A1A1A',
        secondary: '#6B6B6B',
        border:    '#E5E4E1',
        gold:      '#C9A84C',
        'gold-lt': '#E8D48B',
        success:   '#2D6A4F',
        danger:    '#C1292E',
      },
      fontFamily: {
        sans:  ['Inter', 'system-ui', 'sans-serif'],
        mono:  ['Space Grotesk', 'monospace'],
      },
    },
  },
}
```

This keeps the admin dashboard and marketing site visually consistent with the Flutter mobile app.

### Stripe integration (two layers)

**Layer 1 — SaaS billing (B2B):** The business owner subscribes to our platform. We create Stripe Products and Prices for our plans (Starter $29/mo, Pro $79/mo, Enterprise $199/mo). The sign-up and billing flow lives on the Hotwire web side — the owner clicks "Subscribe," Rails creates a Stripe Checkout Session, and they complete payment on Stripe's hosted page. Portal access for plan changes also on the web.

**Layer 2 — End-customer payments (B2C, optional):** If the business wants to accept payments through the app (prepaid packages, gift cards, service payments), we use Stripe Connect. Each Tenant gets a connected Stripe account. Payments flow through our platform with a percentage fee — an additional revenue stream for us.

### Webhook handling
Create a `Webhooks::StripeController` that verifies signatures and dispatches events to service objects. Webhook processing runs through **Solid Queue** for reliability and retries. Key events to handle:

- `checkout.session.completed` — activate subscription
- `customer.subscription.updated` — plan changes
- `invoice.payment_failed` — notify owner, grace period
- `customer.subscription.deleted` — downgrade to free

### Key gems

- `turbo-rails` + `stimulus-rails` — Hotwire (ships with Rails 8)
- `tailwindcss-rails` — Tailwind CSS (ships with Rails 8)
- `solid_queue` — background jobs (ships with Rails 8)
- `solid_cache` — caching (ships with Rails 8)
- `solid_cable` — WebSockets (ships with Rails 8)
- `stripe` — official Stripe Ruby SDK
- `acts_as_tenant` — automatic tenant scoping
- `pundit` — authorization (role-based)
- `jwt` — JSON Web Tokens for the Flutter API
- `rpush` or `fcm` — push notifications to mobile
- `rack-cors` — CORS for Flutter app
- `blueprinter` or `alba` — JSON serialization for API responses
- `pagy` — pagination
- `chartkick` + `groupdate` — admin dashboard charts (works beautifully with Turbo Frames)
- `inline_svg` — SVG icons in views

### Rails app structure

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
        loyalty_cards_controller.rb  # Customer's card
        rewards_controller.rb        # Browse rewards
        redemptions_controller.rb    # Redeem rewards
        staff/
          check_ins_controller.rb    # Staff scans QR
          visits_controller.rb       # Visit history
          redemptions_controller.rb  # Confirm redemption
    admin/
      base_controller.rb             # Web auth + tenant scoping
      dashboard_controller.rb        # Analytics overview
      campaigns_controller.rb        # CRUD campaigns
      rewards_controller.rb          # CRUD rewards
      users_controller.rb            # Manage staff & customers
      subscriptions_controller.rb    # Stripe billing portal
    webhooks/
      stripe_controller.rb           # Stripe webhook endpoint

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
        show.html.erb                # Main dashboard with Turbo Frames
        _visits_chart.html.erb       # Turbo Frame: visits chart
        _stats.html.erb              # Turbo Frame: key metrics
        _activity.html.erb           # Turbo Frame: live activity feed
      campaigns/
        index.html.erb
        _form.html.erb               # Turbo Frame: inline edit
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

### Route structure

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Marketing pages
  root "pages#landing"
  get "pricing", to: "pages#pricing"
  get "features", to: "pages#features"

  # Web auth (built-in generator)
  resource :session
  resource :registration

  # Admin dashboard (Hotwire)
  namespace :admin do
    get "/", to: "dashboard#show"
    resources :campaigns
    resources :rewards
    resources :users
    resource :subscription, only: [:show]  # Stripe portal
  end

  # Mobile API (JSON)
  namespace :api do
    namespace :v1 do
      post "auth/sign_in", to: "auth#sign_in"
      post "auth/sign_up", to: "auth#sign_up"
      post "auth/refresh", to: "auth#refresh"

      resource :loyalty_card, only: [:show]
      resources :rewards, only: [:index, :show]
      resources :redemptions, only: [:create, :index]
      resources :point_transactions, only: [:index]

      namespace :staff do
        post "check_in", to: "check_ins#create"
        resources :visits, only: [:index]
        resources :redemptions, only: [:update]
      end
    end
  end

  # Webhooks
  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end
end
```

---

## 6. Flutter Mobile App — Key Design Decisions

Flutter handles the **customer and staff experience only** — no admin dashboard, no marketing pages. Those live in the Hotwire web app. This keeps the Flutter codebase lean and focused on the two things that need to be native: the QR wallet and the camera scanner.

### Off-White + Matte Black Premium Theme

The app uses a light, editorial design language — premium through restraint. Think Apple Card, Aesop packaging, or a Cereal magazine layout. Every element earns its place on screen. No decoration, no gradients, no visual noise. The only "color" is a muted gold reserved for the loyalty card itself — everything else is black, white, and gray.

**Color palette:**

| Token | Hex | Usage |
|-------|-----|-------|
| `background` | `#FAF9F6` | Main background — warm cream, not harsh white |
| `surface` | `#FFFFFF` | Cards, modals, elevated surfaces |
| `surfaceVariant` | `#F0EFEC` | Input fields, secondary containers, section dividers |
| `primary` | `#1A1A1A` | Primary text, CTA buttons, icons — matte black |
| `primaryVariant` | `#2C2C2C` | Pressed/active state for buttons |
| `secondary` | `#6B6B6B` | Secondary text, labels, timestamps |
| `tertiary` | `#9E9E9E` | Placeholder text, disabled states |
| `border` | `#E5E4E1` | Card borders, dividers — barely visible |
| `cardGold` | `#C9A84C` | Used ONLY on the loyalty card widget (gradient, edge, tier badge) |
| `cardGoldLight` | `#E8D48B` | Loyalty card shimmer / highlight |
| `success` | `#2D6A4F` | Check-in confirmed — deep green, not neon |
| `error` | `#C1292E` | Errors — muted red |

**Typography:**
- Headlines: **Inter** at `FontWeight.w600` — bold enough to anchor but not shouty
- Body: **Inter** at `FontWeight.w400` — clean, legible, invisible (the best kind of type)
- Numbers/Points: **Space Grotesk** at `FontWeight.w500` — gives point balances a distinctive, tech-forward feel without looking like a calculator
- Captions/Labels: **Inter** at `FontWeight.w400`, sized 12-13px, in `#6B6B6B`
- Letter-spacing: Slightly increased (+0.3px) on uppercase labels for that editorial feel

**Design principles:**

1. **Extreme whitespace.** This is the #1 signal of premium. Cards have 24px padding, sections have 40-48px vertical spacing. The screen should feel half-empty — that's the point.
2. **No gradients on UI chrome.** Buttons are flat matte black with white text. No shadows on cards — use 1px `#E5E4E1` borders instead. The only gradient in the entire app is on the loyalty card itself.
3. **The loyalty card is the sole hero.** A full-width card with a subtle dark-to-gold gradient and embossed-style text — it's the one rich, indulgent element. Everything around it is deliberately plain so the card pops.
4. **Micro-animations, but tasteful.** Points increment with a counting animation. Screen transitions use subtle fades (200ms), not slides. Reward redemption gets a brief confetti animation (Lottie) — short, not overwhelming. No bounces, no jiggles.
5. **Photography over illustration.** If showing services or products, use real photos with a slight desaturation filter. No clip art, no icons as decoration.
6. **Black CTA buttons, always.** Primary actions are always matte black rectangles with white text and generous corner radius (12px). This consistency makes the app feel like one cohesive product.

**Key UI screens and their feel:**

- **Home / Card screen:** Cream background, loyalty card centered with the gold gradient as the visual anchor, points balance in large Space Grotesk numerals below the card, minimal activity feed in a flat list — no card wrappers around list items, just clean rows with hairline dividers.
- **QR scan (staff):** Full-screen camera with a thin matte-black scan frame. On successful scan, a green checkmark fades in. No flashy effects.
- **Rewards catalog:** Vertical list (not grid) with large whitespace between items. Each reward shows a photo, name, and a small black pill badge showing the points cost. "Redeem" button is matte black.
- **Login / Onboarding:** Nearly empty screen. Logo centered, email field, matte black "Continue" button. Nothing else.

### State management
**Riverpod** is the recommended choice in 2025/2026. It handles dependency injection, caching, and reactive state cleanly. Alternative: BLoC if the team prefers it.

### QR code flow (the core interaction)

1. **Customer opens app** → sees their loyalty card with a dynamic QR code (encodes `loyalty_card.qr_code` UUID + a short-lived HMAC token for security).
2. **Staff member scans** using the staff app's camera (via `mobile_scanner` package).
3. **Staff app calls** `POST /api/v1/staff/check_in` with the scanned data.
4. **Rails validates** the HMAC, finds the loyalty card, applies points (including any active campaign multipliers), creates a Visit and PointTransaction.
5. **Customer sees** points update in real-time (via polling or WebSocket).

### Key Flutter packages

- `mobile_scanner` — QR/barcode scanning (maintained, supports Android + iOS)
- `qr_flutter` — QR code generation for the customer's card
- `flutter_riverpod` — state management
- `dio` — HTTP client with interceptors for JWT refresh
- `flutter_secure_storage` — store tokens securely
- `go_router` — declarative routing
- `flutter_local_notifications` + `firebase_messaging` — push notifications
- `cached_network_image` — image caching
- `lottie` — animations for reward celebrations
- `flutter_animate` — chainable micro-animations (fades, counting numbers)

### App structure (feature-first)

```
lib/
  core/
    api/          # Dio client, interceptors, JWT refresh
    auth/         # Auth provider, JWT storage
    theme/
      app_colors.dart     # Off-white + matte black palette constants
      app_typography.dart  # Inter, Space Grotesk font styles
      app_theme.dart       # ThemeData assembly (light minimalist)
      loyalty_card.dart    # Reusable loyalty card widget (the one gold element)
    router/       # GoRouter config (role-based: customer vs staff)
    widgets/      # Shared matte-black buttons, clean loaders, etc.
  features/
    auth/         # Login, register, forgot password
    loyalty_card/ # Card view, QR display, points history
    rewards/      # Browse & redeem rewards
    profile/      # User settings, visit history
    staff/        # QR scanner, check-in, redemption confirm
  assets/
    lottie/       # Confetti, checkmark, loading animations
    fonts/        # Inter, Space Grotesk
```

Note: **No admin or subscription screens in Flutter.** Business owners manage everything through the Hotwire web dashboard at `yourdomain.com/admin`. This cuts the Flutter scope roughly in half.

### Stripe in the mobile app

Business owners subscribe and manage billing entirely through the Hotwire web dashboard — no Stripe UI in Flutter at all. The Flutter app only needs to check the tenant's plan status (via the API) to enforce feature gates (e.g., "Campaigns require Pro plan — upgrade at yourdomain.com/admin").

---

## 7. Stripe Pricing Model (for our SaaS)

| Plan | Price | Limits | Features |
|------|-------|--------|----------|
| **Free** | $0/mo | 50 customers, 1 staff | Basic stamp card, QR check-in |
| **Starter** | $29/mo | 500 customers, 5 staff | Custom rewards, push notifications, basic analytics |
| **Pro** | $79/mo | Unlimited customers, 15 staff | Campaigns, tiers, referrals, advanced analytics, API access |
| **Enterprise** | $199/mo | Unlimited everything | Multi-location, Stripe Connect payments, white-label branding, priority support |

Additional revenue: If using Stripe Connect for end-customer payments, charge a 2-3% platform fee on transactions.

---

## 8. MVP Scope (Phase 1)

For a first release, focus on the core loop that delivers value:

**Rails 8 + Hotwire (web):**
- Marketing landing page + pricing page
- Business owner sign-up + Stripe subscription (Starter plan)
- Admin dashboard: customer count, visits this week, recent activity (Turbo Frames)
- Admin: rewards CRUD (create/edit/delete rewards)
- Admin: staff management (invite, roles)
- Stripe billing portal link

**Flutter (mobile):**
- Customer registration + login (phone or email)
- Digital loyalty card with QR code
- Staff QR scanner to check in customers
- Points-per-visit earning
- Simple rewards catalog + redemption
- Push notifications (welcome, reward available)

**Defer to Phase 2:**
- Points-per-dollar (needs POS integration or manual entry)
- Tier system (Bronze/Silver/Gold)
- Campaigns and multipliers
- Referral program
- Stripe Connect for end-customer payments
- Multi-location support
- Advanced analytics and segments
- Turbo Streams real-time dashboard updates

**Estimated timeline for MVP:** 6-10 weeks for a solo developer (the Hotwire admin is faster to build than a Flutter admin would have been), 3-5 weeks for a small team.

---

## 9. Technical Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| **QR code spoofing** | Fake check-ins | HMAC-signed QR codes with short expiry (30 seconds), server-side validation |
| **Stripe webhook failures** | Missed subscription updates | Idempotent webhook handlers, Stripe retry mechanism, daily reconciliation job |
| **Multi-tenancy data leaks** | Customer data exposed across businesses | `acts_as_tenant` default scoping, DB-level row security as backup, thorough testing |
| **Flutter platform differences** | Camera/NFC behaves differently on iOS vs. Android | Use well-maintained packages (`mobile_scanner`), test on both platforms early |
| **Offline check-ins** | Poor connectivity at the barbershop | Queue check-ins locally on staff device, sync when online |
| **App Store rejection** | Flutter apps occasionally face review issues | Follow Apple/Google guidelines strictly, no hidden functionality |

---

## 10. Recommended Next Steps

1. **Set up the Rails 8 full app** with `rails new loyalty_saas -d postgresql`. Run `rails generate authentication` for the built-in auth scaffold. Add acts_as_tenant, Stripe gem, Tailwind config with our color palette. Scaffold the Tenant, User, and LoyaltyCard models. Solid Queue/Cache/Cable come pre-configured.

2. **Build the admin dashboard first (Hotwire).** Turbo Frames for the dashboard widgets, CRUD for rewards, staff management. This is your fastest path to something a business owner can see and get excited about. You already know Rails — this will fly.

3. **Build the marketing landing page.** Simple ERB + Tailwind. Pricing page with Stripe Checkout integration. Get the SaaS billing flow working end-to-end.

4. **Set up the Flutter project** with `flutter create loyalty_app`. Install Riverpod, Dio, mobile_scanner, qr_flutter. Build the login screen and the loyalty card display with the off-white + gold card theme.

5. **Wire the QR check-in flow end-to-end.** Staff scans customer's QR → Rails creates Visit + PointTransaction → customer sees points update. This is the core value proposition.

6. **Add Turbo Streams for real-time.** When a check-in happens, the admin dashboard updates live. This is where Hotwire really shines.

7. **Deploy and dogfood** at your own barbershop. Real usage reveals real problems.

---

## Sources

**Rails 8 & Solid Trifecta:**
- [Rails 8.0 Release Notes — Official Guides](https://guides.rubyonrails.org/8_0_release_notes.html)
- [Rails 8 & 8.1 New Features — Rubyroid Labs](https://rubyroidlabs.com/blog/2025/11/rails-8-8-1-new-features/)
- [Rails 8 Solid Trifecta: Solid Queue, Solid Cache, and Solid Cable — Devot](https://devot.team/blog/rails-solid-trifecta)
- [Rails 8.0 Authentication Generator — Codeminer42](https://blog.codeminer42.com/rails-8-0-is-out/)
- [Upgrading Rails 7 to 8 — Saeloun](https://blog.saeloun.com/2026/02/26/rails-7-to-8-upgrade-guide/)

**Flutter & Loyalty:**
- [Build a Flutter Loyalty Program That Drives Sales](https://www.ptolemay.com/post/maximize-e-commerce-growth-the-ultimate-guide-to-flutter-loyalty-programs)
- [Retail Loyalty System with Flutter — Codigee](https://codigee.com/case-studies/retail-loyalty-system-with-flutter)
- [Open Loyalty — Reduce Mobile Development Costs with Flutter](https://www.openloyalty.io/insider/reduce-mobile-loyalty-app-development-costs-with-flutter)
- [Flutter QR Code Scanner Packages — Flutter Gems](https://fluttergems.dev/qr-code-bar-code/)

**Stripe + Rails:**
- [Stripe Checkout + Customer Portal in Rails — Webcrunch](https://webcrunch.com/posts/stripe-checkout-billing-portal-ruby-on-rails)
- [Stripe Integration with Ruby on Rails — Simform](https://medium.com/simform-engineering/stripe-integration-with-ruby-on-rails-408ff4128fab)

**Competitors:**
- [The Ultimate Guide to Barber Shop Loyalty Programs — Stamp Me](https://www.stampme.com/blog/barber-shop-and-salons-loyalty-programs)
- [White Label SaaS: Salon Software Business — Iqonic](https://iqonic.design/blog/white-label-saas-salon-software-business/)
- [Best Salon Software with Loyalty Programs — GetApp](https://www.getapp.com/retail-consumer-services-software/salon/f/customer-loyalty-program/)
