# Database Schema

## Models

### Tenant
The business that subscribes to our platform.

```ruby
Tenant
  - name                    # string
  - slug                    # string (unique, URL-friendly)
  - logo_url                # string
  - theme_color             # string (hex, for white-label customization)
  - stripe_customer_id      # string (their Stripe customer for billing us)
  - stripe_subscription_id  # string (their SaaS subscription)
  - plan                    # enum: free, starter, pro, enterprise
  - settings                # jsonb (points_per_visit, currency, etc.)
```

### User
Anyone: business owner, staff member, or end customer.

```ruby
User
  - tenant_id               # references Tenant
  - email                   # string
  - phone                   # string
  - encrypted_password      # string (via Rails 8 auth generator)
  - role                    # enum: owner, manager, staff, customer
  - stripe_customer_id      # string (for end-customer payments, optional)
```

### LoyaltyCard
One per customer per tenant.

```ruby
LoyaltyCard
  - tenant_id               # references Tenant
  - user_id                 # references User
  - qr_code                 # uuid (unique, used in QR generation)
  - tier                    # enum: bronze, silver, gold
  - total_points            # integer
  - redeemed_points         # integer
  - current_points          # integer (total - redeemed)
  - visits_count            # integer (counter cache)
  - streak_count            # integer
  - last_visit_at           # datetime
```

### PointTransaction
Immutable ledger of all point changes.

```ruby
PointTransaction
  - tenant_id               # references Tenant
  - loyalty_card_id         # references LoyaltyCard
  - kind                    # enum: earn, redeem, bonus, referral, adjustment
  - points                  # integer (positive or negative)
  - description             # string
  - staff_id                # references User (who processed it)
  - visit_id                # references Visit (nullable)
```

### Reward
Available rewards configured by the business owner.

```ruby
Reward
  - tenant_id               # references Tenant
  - name                    # string
  - description             # text
  - image_url               # string
  - points_cost             # integer
  - reward_type             # enum: free_service, discount_percent, discount_fixed, product
  - active                  # boolean
  - tier_required           # enum (nullable): bronze, silver, gold
```

### Redemption
When a customer redeems a reward.

```ruby
Redemption
  - tenant_id               # references Tenant
  - loyalty_card_id         # references LoyaltyCard
  - reward_id               # references Reward
  - points_spent            # integer
  - status                  # enum: pending, confirmed, expired
```

### Visit
Each time a customer checks in.

```ruby
Visit
  - tenant_id               # references Tenant
  - user_id                 # references User (customer)
  - staff_id                # references User (staff who checked them in)
  - service_name            # string
  - amount_cents            # integer
  - checked_in_at           # datetime
  - points_earned           # integer
```

### Campaign
Time-bound promotions created by the business owner.

```ruby
Campaign
  - tenant_id               # references Tenant
  - name                    # string
  - description             # text
  - multiplier              # decimal (e.g. 2.0 for double points)
  - starts_at               # datetime
  - ends_at                 # datetime
  - target_segment          # jsonb (filter criteria)
  - active                  # boolean
```

### Subscription
SaaS billing state (mirrors Stripe).

```ruby
Subscription
  - tenant_id               # references Tenant
  - stripe_subscription_id  # string
  - stripe_price_id         # string
  - status                  # enum: trialing, active, past_due, canceled
  - current_period_end      # datetime
```

## Relationships

```
Tenant
  ├── has_many :users
  ├── has_many :loyalty_cards
  ├── has_many :rewards
  ├── has_many :campaigns
  ├── has_many :visits
  ├── has_one  :subscription
  └── has_many :point_transactions (through loyalty_cards)

User
  ├── belongs_to :tenant
  ├── has_one    :loyalty_card (if role == customer)
  └── has_many   :visits (as staff or customer)

LoyaltyCard
  ├── belongs_to :tenant
  ├── belongs_to :user
  ├── has_many   :point_transactions
  └── has_many   :redemptions
```
