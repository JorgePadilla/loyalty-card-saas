class Webhooks::StripeController < ActionController::API
  def create
    payload = request.body.read
    sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
    webhook_secret = Rails.application.credentials.dig(:stripe, :webhook_secret) || ENV["STRIPE_WEBHOOK_SECRET"]

    begin
      event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
    rescue JSON::ParserError
      head :bad_request and return
    rescue Stripe::SignatureVerificationError
      head :bad_request and return
    end

    case event.type
    when "checkout.session.completed"
      handle_checkout_completed(event.data.object)
    when "customer.subscription.updated"
      handle_subscription_updated(event.data.object)
    when "customer.subscription.deleted"
      handle_subscription_deleted(event.data.object)
    when "invoice.payment_failed"
      handle_payment_failed(event.data.object)
    end

    head :ok
  end

  private

  def handle_checkout_completed(session)
    tenant_id = session.client_reference_id || session.metadata["tenant_id"]
    tenant = Tenant.find_by(id: tenant_id)
    return unless tenant

    plan = session.metadata["plan"]
    stripe_subscription = Stripe::Subscription.retrieve(session.subscription)

    subscription = tenant.subscription || tenant.build_subscription
    subscription.update!(
      stripe_subscription_id: stripe_subscription.id,
      stripe_price_id: stripe_subscription.items.data.first.price.id,
      status: map_status(stripe_subscription.status),
      current_period_end: Time.at(stripe_subscription.current_period_end)
    )

    tenant.update!(plan: plan) if plan.present?
  end

  def handle_subscription_updated(stripe_sub)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
    return unless subscription

    subscription.update!(
      status: map_status(stripe_sub.status),
      stripe_price_id: stripe_sub.items.data.first.price.id,
      current_period_end: Time.at(stripe_sub.current_period_end)
    )

    new_plan = plan_from_price(stripe_sub.items.data.first.price.id)
    subscription.tenant.update!(plan: new_plan) if new_plan
  end

  def handle_subscription_deleted(stripe_sub)
    subscription = Subscription.find_by(stripe_subscription_id: stripe_sub.id)
    return unless subscription

    subscription.update!(status: :canceled)
    subscription.tenant.update!(plan: :free)
  end

  def handle_payment_failed(invoice)
    subscription = Subscription.find_by(stripe_subscription_id: invoice.subscription)
    return unless subscription

    subscription.update!(status: :past_due)
  end

  def map_status(stripe_status)
    case stripe_status
    when "trialing" then :trialing
    when "active" then :active
    when "past_due" then :past_due
    when "canceled", "unpaid", "incomplete_expired" then :canceled
    else :active
    end
  end

  def plan_from_price(price_id)
    StripeCheckoutService::PRICE_IDS.key(price_id)
  end
end
