# API Endpoints

JSON API consumed by the Flutter mobile app. All endpoints prefixed with `/api/v1`.

## Authentication

All API requests (except auth endpoints) require a Bearer token:
```
Authorization: Bearer <jwt_token>
```

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/sign_in` | Login, returns JWT + refresh token |
| POST | `/api/v1/auth/sign_up` | Register new customer account |
| POST | `/api/v1/auth/refresh` | Refresh expired JWT using refresh token |

## Customer Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/loyalty_card` | Get current user's loyalty card (points, tier, QR code) |
| GET | `/api/v1/rewards` | List available rewards for this tenant |
| GET | `/api/v1/rewards/:id` | Reward details |
| POST | `/api/v1/redemptions` | Redeem a reward (deducts points) |
| GET | `/api/v1/redemptions` | List user's redemption history |
| GET | `/api/v1/point_transactions` | Point history (earned, redeemed, bonuses) |

## Staff Endpoints

Requires `role: staff` or higher.

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/staff/check_in` | Scan customer QR → create visit + award points |
| GET | `/api/v1/staff/visits` | List recent visits for this tenant |
| PATCH | `/api/v1/staff/redemptions/:id` | Confirm or reject a pending redemption |

## Routes (Rails)

```ruby
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
```

## QR Check-In Flow

1. Customer opens app → sees QR code (encodes `loyalty_card.qr_code` UUID + short-lived HMAC)
2. Staff scans with camera → `POST /api/v1/staff/check_in` with scanned payload
3. Rails validates HMAC, finds card, applies points (including active campaign multipliers)
4. Creates Visit + PointTransaction records
5. Customer sees points update
