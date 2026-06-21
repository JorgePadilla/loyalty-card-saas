Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Authentication (Rails 8 built-in)
  resource :session, only: %i[new create destroy]
  resources :passwords, param: :token, only: %i[new create edit update]
  resource :registration, only: %i[new create]

  # Marketing pages
  root "pages#landing"
  get "pricing", to: "pages#pricing"
  get "features", to: "pages#features"

  # Language switcher
  get "locale/:locale", to: "locale#update", as: :set_locale, constraints: { locale: /en|es/ }

  # Admin dashboard (Hotwire)
  namespace :admin do
    root to: "dashboard#show"
    resource :dashboard, only: :show
    get "dashboard/chart", to: "dashboard#chart", as: :dashboard_chart
    resources :rewards
    resources :customers, only: :index
    resources :users
    resources :campaigns
    resources :visits, only: %i[index show]
    resource :subscription, only: %i[show create] do
      post :billing_portal, on: :member
    end
  end

  # Platform (SaaS owner) super-admin — separate auth, sees all tenants
  namespace :platform do
    root to: "dashboard#show"
    resource :session, only: %i[new create destroy]
    resources :tenants, only: %i[index show] do
      member do
        post :suspend
        post :reactivate
        patch :update_plan
        post :impersonate
      end
    end
    resource :impersonation, only: :destroy
  end

  # JSON API for Flutter
  namespace :api do
    namespace :v1 do
      post "auth/sign_in", to: "auth#sign_in"
      post "auth/sign_up", to: "auth#sign_up"
      post "auth/refresh", to: "auth#refresh"

      resource :loyalty_card, only: :show
      resources :rewards, only: %i[index show]
      resources :redemptions, only: %i[create index]
      resources :point_transactions, only: :index

      namespace :staff do
        post "check_in", to: "check_ins#create"
        resources :visits, only: :index
        resources :redemptions, only: :update
      end
    end
  end

  # Stripe webhooks
  namespace :webhooks do
    post "stripe", to: "stripe#create"
  end
end
