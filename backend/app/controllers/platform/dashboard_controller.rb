class Platform::DashboardController < Platform::BaseController
  def show
    @total_tenants     = Tenant.count
    @active_tenants    = Tenant.active.count
    @suspended_tenants = Tenant.suspended.count
    @total_customers   = User.customers.count

    plans = Tenant.plans.keys
    @plan_breakdown = plans.index_with { |p| Tenant.where(plan: p).count }

    active_by_plan = plans.index_with do |p|
      Tenant.where(plan: p)
            .joins(:subscription)
            .merge(Subscription.where(status: %i[active trialing]))
            .count
    end
    @active_subscriptions = active_by_plan.values.sum
    @mrr = active_by_plan.sum { |plan, count| Tenant::PLAN_PRICES.fetch(plan, 0) * count }

    @recent_tenants = Tenant.order(created_at: :desc).limit(8)
  end
end
