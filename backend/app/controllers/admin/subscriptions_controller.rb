class Admin::SubscriptionsController < Admin::BaseController
  def show
    @subscription = current_user.tenant.subscription
    @tenant = current_user.tenant
  end

  def create
    plan = params[:plan]

    unless %w[starter pro enterprise].include?(plan)
      redirect_to admin_subscription_path, alert: t("admin.subscriptions.flash.invalid_plan")
      return
    end

    if current_user.tenant.plan == plan
      plan_name = t("enums.tenant.plan.#{plan}", default: plan.capitalize)
      redirect_to admin_subscription_path, notice: t("admin.subscriptions.flash.already_on_plan", plan: plan_name)
      return
    end

    checkout_url = StripeCheckoutService.new(
      tenant: current_user.tenant,
      plan: plan,
      success_url: admin_subscription_url(checkout: "success"),
      cancel_url: admin_subscription_url(checkout: "canceled")
    ).call

    redirect_to checkout_url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to admin_subscription_path, alert: t("admin.subscriptions.flash.billing_error", message: e.message)
  end

  def billing_portal
    subscription = current_user.tenant.subscription
    unless subscription&.stripe_subscription_id&.start_with?("sub_")
      redirect_to admin_subscription_path, alert: t("admin.subscriptions.flash.no_active_billing")
      return
    end

    stripe_sub = Stripe::Subscription.retrieve(subscription.stripe_subscription_id)
    portal_session = Stripe::BillingPortal::Session.create(
      customer: stripe_sub.customer,
      return_url: admin_subscription_url
    )

    redirect_to portal_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to admin_subscription_path, alert: t("admin.subscriptions.flash.billing_error", message: e.message)
  end
end
