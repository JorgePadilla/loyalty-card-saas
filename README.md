# Loyalty Card SaaS

A white-label loyalty card system for service businesses (barbershops, salons, spas, gyms). Built with **Flutter** (mobile) and **Rails 8** (web + API).

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Mobile | Flutter (iOS + Android) | Customer QR wallet + Staff scanner |
| Web | Rails 8 + Hotwire (Turbo + Stimulus) | Admin dashboard + Marketing site |
| API | Rails 8 JSON API | Mobile app backend |
| Database | PostgreSQL | Data + Solid Queue/Cache/Cable |
| Payments | Stripe | SaaS subscriptions + Connect |
| Styling | Tailwind CSS | Web UI (off-white + matte black theme) |

## Architecture

Single Rails 8 app serving two interfaces:

- **JSON API** → consumed by the Flutter mobile app
- **HTML + Hotwire** → admin dashboard + marketing pages

No Redis. No Devise. No separate frontend framework.

```
Flutter Mobile ──JSON──► Rails 8 ◄──HTML+Turbo── Browser
                           │
                      PostgreSQL + Stripe
```

## Project Structure

```
loyalty-card-saas/
├── docs/
│   ├── research.md          # Full research document
│   ├── architecture.md      # System architecture details
│   ├── database-schema.md   # Models and relationships
│   ├── api-endpoints.md     # JSON API reference
│   ├── theme-guide.md       # Off-white + matte black design system
│   └── mvp-scope.md         # Phase 1 vs Phase 2 features
├── backend/                 # Rails 8 app (to be created)
│   └── ...
├── mobile/                  # Flutter app (to be created)
│   └── ...
└── README.md
```

## Design Language

Off-white + matte black minimalism. Premium through restraint.

- Background: `#FAF9F6` (warm cream)
- Primary: `#1A1A1A` (matte black)
- Accent: `#C9A84C` (gold — used **only** on the loyalty card)
- Typography: Inter + Space Grotesk

## Quick Start

> Coming soon — Rails 8 backend and Flutter mobile app will be scaffolded here.

## Docs

- [Research Document](docs/research.md) — Full investigation: features, competitors, architecture, schema, tech choices
- [Architecture](docs/architecture.md) — System design and Hotwire specifics
- [Database Schema](docs/database-schema.md) — All models with field definitions
- [API Endpoints](docs/api-endpoints.md) — JSON API for the Flutter app
- [Theme Guide](docs/theme-guide.md) — Color palette, typography, design principles
- [MVP Scope](docs/mvp-scope.md) — What's in Phase 1 vs Phase 2

## License

Private — All rights reserved.
