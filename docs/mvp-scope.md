# MVP Scope

## Phase 1 — Core Loop

### Rails 8 + Hotwire (Web)
- [ ] Marketing landing page + pricing page
- [ ] Business owner sign-up + Stripe subscription (Starter plan)
- [ ] Admin dashboard: customer count, visits this week, recent activity (Turbo Frames)
- [ ] Admin: rewards CRUD (create/edit/delete rewards)
- [ ] Admin: staff management (invite, roles)
- [ ] Stripe billing portal link

### Flutter (Mobile)
- [ ] Customer registration + login (phone or email)
- [ ] Digital loyalty card with QR code
- [ ] Staff QR scanner to check in customers
- [ ] Points-per-visit earning
- [ ] Simple rewards catalog + redemption
- [ ] Push notifications (welcome, reward available)

### Estimated Timeline
- Solo developer: 6-10 weeks
- Small team (2-3 devs): 3-5 weeks

---

## Phase 2 — Growth Features

- [ ] Points-per-dollar (POS integration or manual entry)
- [ ] Tier system (Bronze / Silver / Gold)
- [ ] Campaigns and multipliers (double points weekends)
- [ ] Referral program
- [ ] Stripe Connect for end-customer payments
- [ ] Multi-location support
- [ ] Advanced analytics and customer segments
- [ ] Turbo Streams real-time dashboard updates

---

## Build Order (Recommended)

1. **Rails 8 app setup** — `rails new loyalty_saas -d postgresql`, auth generator, acts_as_tenant, Stripe gem, Tailwind config
2. **Admin dashboard (Hotwire)** — fastest path to a demo. Turbo Frames, rewards CRUD, staff management
3. **Marketing landing page** — ERB + Tailwind. Pricing page with Stripe Checkout
4. **Flutter project setup** — Riverpod, Dio, mobile_scanner, qr_flutter. Login + loyalty card display
5. **QR check-in flow end-to-end** — the core value proposition
6. **Turbo Streams for real-time** — check-in → dashboard updates live
7. **Deploy and dogfood** at the barbershop

## Stripe Pricing (Our SaaS)

| Plan | Price | Limits | Features |
|------|-------|--------|----------|
| Free | $0/mo | 50 customers, 1 staff | Basic stamp card, QR check-in |
| Starter | $29/mo | 500 customers, 5 staff | Custom rewards, push notifications, basic analytics |
| Pro | $79/mo | Unlimited customers, 15 staff | Campaigns, tiers, referrals, advanced analytics |
| Enterprise | $199/mo | Unlimited | Multi-location, Stripe Connect, white-label, priority support |
