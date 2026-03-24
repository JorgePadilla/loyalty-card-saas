puts "Seeding database..."

# Create demo tenant
tenant = Tenant.find_or_create_by!(slug: "demo-barbershop") do |t|
  t.name = "Demo Barbershop"
  t.theme_color = "#C9A84C"
  t.plan = :starter
  t.settings = { "points_per_visit" => 10, "currency" => "USD" }
end
puts "  Created tenant: #{tenant.name}"

ActsAsTenant.with_tenant(tenant) do
  # Create subscription
  Subscription.find_or_create_by!(tenant: tenant) do |s|
    s.status = :active
    s.stripe_subscription_id = "sub_demo_#{SecureRandom.hex(8)}"
    s.stripe_price_id = "price_starter_demo"
    s.current_period_end = 30.days.from_now
  end
  puts "  Created subscription (Starter plan)"

  # Create owner
  owner = User.find_or_create_by!(email_address: "owner@demo.com") do |u|
    u.first_name = "Jorge"
    u.last_name = "Padilla"
    u.password = "password123"
    u.role = :owner
    u.phone = "+1-555-0100"
  end
  puts "  Created owner: #{owner.email_address}"

  # Create staff
  staff = User.find_or_create_by!(email_address: "staff@demo.com") do |u|
    u.first_name = "Maria"
    u.last_name = "Garcia"
    u.password = "password123"
    u.role = :staff
    u.phone = "+1-555-0101"
  end
  puts "  Created staff: #{staff.email_address}"

  # Create 5 customers with loyalty cards
  customers = []
  customer_data = [
    { first: "Alex", last: "Johnson", email: "alex@example.com", phone: "+1-555-0201" },
    { first: "Sam", last: "Williams", email: "sam@example.com", phone: "+1-555-0202" },
    { first: "Chris", last: "Brown", email: "chris@example.com", phone: "+1-555-0203" },
    { first: "Jordan", last: "Davis", email: "jordan@example.com", phone: "+1-555-0204" },
    { first: "Taylor", last: "Martinez", email: "taylor@example.com", phone: "+1-555-0205" }
  ]

  customer_data.each do |data|
    user = User.find_or_create_by!(email_address: data[:email]) do |u|
      u.first_name = data[:first]
      u.last_name = data[:last]
      u.password = "password123"
      u.role = :customer
      u.phone = data[:phone]
    end

    card = LoyaltyCard.find_or_create_by!(user: user) do |c|
      c.tier = :bronze
    end

    customers << { user: user, card: card }
    puts "  Created customer: #{user.full_name} (card: #{card.qr_code})"
  end

  # Create rewards
  rewards_data = [
    { name: "Free Haircut", description: "A complimentary haircut of your choice", points_cost: 100, reward_type: :free_service },
    { name: "50% Off Beard Trim", description: "Half off any beard trim service", points_cost: 50, reward_type: :discount_percent },
    { name: "$5 Off Any Service", description: "Save $5 on your next visit", points_cost: 40, reward_type: :discount_fixed },
    { name: "Free Hair Product", description: "Choose any hair product from our shelf", points_cost: 150, reward_type: :product, tier_required: :silver },
    { name: "VIP Hot Towel Shave", description: "Premium hot towel straight razor shave", points_cost: 200, reward_type: :free_service, tier_required: :gold }
  ]

  rewards = rewards_data.map do |data|
    Reward.find_or_create_by!(name: data[:name]) do |r|
      r.description = data[:description]
      r.points_cost = data[:points_cost]
      r.reward_type = data[:reward_type]
      r.tier_required = data[:tier_required]
      r.active = true
    end
  end
  puts "  Created #{rewards.size} rewards"

  # Create campaign
  campaign = Campaign.find_or_create_by!(name: "Weekend Double Points") do |c|
    c.description = "Earn double points on all visits this weekend!"
    c.multiplier = 2.0
    c.starts_at = Time.current.beginning_of_week + 5.days
    c.ends_at = Time.current.beginning_of_week + 7.days
    c.active = true
    c.target_segment = { "tier" => "all" }
  end
  puts "  Created campaign: #{campaign.name}"

  # Create visits and point transactions for customers
  services = ["Classic Haircut", "Fade Haircut", "Beard Trim", "Hair & Beard Combo", "Kids Haircut"]
  amounts = [2500, 3000, 1500, 4000, 2000]

  customers.each do |customer|
    visit_count = rand(3..8)
    visit_count.times do
      days_ago = rand(1..60)
      points = tenant.points_per_visit
      service_idx = rand(services.length)

      visit = Visit.create!(
        user: customer[:user],
        staff: staff,
        service_name: services[service_idx],
        amount_cents: amounts[service_idx],
        checked_in_at: days_ago.days.ago,
        points_earned: points
      )

      PointTransaction.create!(
        loyalty_card: customer[:card],
        kind: :earn,
        points: points,
        description: "Visit: #{services[service_idx]}",
        staff: staff,
        visit: visit
      )

      customer[:card].increment!(:total_points, points)
      customer[:card].increment!(:current_points, points)
      customer[:card].increment!(:visits_count)
      customer[:card].update!(last_visit_at: days_ago.days.ago)
    end

    puts "  Created #{visit_count} visits for #{customer[:user].full_name} (#{customer[:card].total_points} points)"
  end

  # Create a sample redemption
  if customers.first[:card].current_points >= rewards.first.points_cost
    Redemption.create!(
      loyalty_card: customers.first[:card],
      reward: rewards.first,
      points_spent: rewards.first.points_cost,
      status: :pending
    )
    puts "  Created pending redemption for #{customers.first[:user].full_name}"
  end
end

puts "Seeding complete!"
