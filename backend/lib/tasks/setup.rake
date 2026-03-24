namespace :setup do
  desc "Seed production database with the barbershop tenant and initial data"
  task barbershop: :environment do
    puts "Setting up barbershop tenant..."

    tenant = Tenant.find_or_create_by!(slug: "padilla-barbershop") do |t|
      t.name = "Padilla's Barbershop"
      t.theme_color = "#C9A84C"
      t.plan = :starter
      t.settings = { "points_per_visit" => 10, "currency" => "USD" }
    end
    puts "  Tenant: #{tenant.name} (#{tenant.slug})"

    ActsAsTenant.with_tenant(tenant) do
      Subscription.find_or_create_by!(tenant: tenant) do |s|
        s.status = :active
        s.stripe_subscription_id = "pending_stripe_setup"
        s.stripe_price_id = "pending_stripe_setup"
        s.current_period_end = 30.days.from_now
      end
      puts "  Subscription created (configure Stripe to activate)"

      owner = User.find_or_create_by!(email_address: ENV.fetch("OWNER_EMAIL", "jorge@padillabarbershop.com")) do |u|
        u.first_name = "Jorge"
        u.last_name = "Padilla"
        u.password = ENV.fetch("OWNER_PASSWORD") { abort "Set OWNER_PASSWORD env var" }
        u.role = :owner
        u.phone = ENV.fetch("OWNER_PHONE", "")
      end
      puts "  Owner: #{owner.email_address}"

      rewards = [
        { name: "Free Haircut", description: "A complimentary haircut of your choice", points_cost: 100, reward_type: :free_service },
        { name: "50% Off Beard Trim", description: "Half off any beard trim", points_cost: 50, reward_type: :discount_percent },
        { name: "$5 Off Any Service", description: "Save $5 on your next visit", points_cost: 40, reward_type: :discount_fixed },
        { name: "Free Hair Product", description: "Any hair product from our shelf", points_cost: 150, reward_type: :product, tier_required: :silver },
        { name: "VIP Hot Towel Shave", description: "Premium hot towel straight razor shave", points_cost: 200, reward_type: :free_service, tier_required: :gold }
      ]

      rewards.each do |data|
        Reward.find_or_create_by!(name: data[:name]) do |r|
          r.description = data[:description]
          r.points_cost = data[:points_cost]
          r.reward_type = data[:reward_type]
          r.tier_required = data[:tier_required]
          r.active = true
        end
      end
      puts "  Created #{rewards.size} rewards"
    end

    puts "Barbershop setup complete!"
    puts ""
    puts "Next steps:"
    puts "  1. Log in at your domain with the owner credentials"
    puts "  2. Go to Admin > Subscription to connect Stripe"
    puts "  3. Add staff members from Admin > Customers"
    puts "  4. Share the tenant slug '#{tenant.slug}' with customers to sign up via the app"
  end
end
