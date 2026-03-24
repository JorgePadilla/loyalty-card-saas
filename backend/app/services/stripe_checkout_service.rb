class StripeCheckoutService
  PRICE_IDS = {
    "starter" => ENV.fetch("STRIPE_STARTER_PRICE_ID", "price_starter"),
    "pro" => ENV.fetch("STRIPE_PRO_PRICE_ID", "price_pro"),
    "enterprise" => ENV.fetch("STRIPE_ENTERPRISE_PRICE_ID", "price_enterprise")
  }.freeze

  def initialize(tenant:, plan:, success_url:, cancel_url:)
    @tenant = tenant
    @plan = plan
    @success_url = success_url
    @cancel_url = cancel_url
  end

  def call
    price_id = PRICE_IDS[@plan]
    raise ArgumentError, "Invalid plan: #{@plan}" unless price_id

    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      line_items: [{ price: price_id, quantity: 1 }],
      success_url: @success_url,
      cancel_url: @cancel_url,
      client_reference_id: @tenant.id.to_s,
      customer_email: @tenant.users.find_by(role: :owner)&.email_address,
      metadata: {
        tenant_id: @tenant.id,
        plan: @plan
      }
    )

    session.url
  end
end
