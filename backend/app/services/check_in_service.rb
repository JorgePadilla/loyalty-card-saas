class CheckInService
  Result = Struct.new(:success?, :visit, :points_earned, :error, keyword_init: true)

  def initialize(tenant:, qr_code:, staff:, service_name: nil, amount_cents: 0)
    @tenant = tenant
    @qr_code = qr_code
    @staff = staff
    @service_name = service_name || "Check-in"
    @amount_cents = amount_cents
  end

  def call
    loyalty_card = LoyaltyCard.find_by(qr_code: @qr_code)
    return Result.new(success?: false, error: "Invalid QR code") unless loyalty_card

    base_points = @tenant.points_per_visit
    multiplier = active_campaign_multiplier
    points = (base_points * multiplier).to_i

    ActiveRecord::Base.transaction do
      visit = Visit.create!(
        user: loyalty_card.user,
        staff: @staff,
        service_name: @service_name,
        amount_cents: @amount_cents,
        checked_in_at: Time.current,
        points_earned: points
      )

      PointTransaction.create!(
        loyalty_card: loyalty_card,
        kind: :earn,
        points: points,
        description: "Visit: #{@service_name}#{multiplier > 1 ? " (#{multiplier}x campaign)" : ""}",
        staff: @staff,
        visit: visit
      )

      loyalty_card.earn_points(points)
      loyalty_card.record_visit!

      Result.new(success?: true, visit: visit, points_earned: points)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, error: e.message)
  end

  private

  def active_campaign_multiplier
    campaign = Campaign.active_now.order(multiplier: :desc).first
    campaign&.multiplier || 1.0
  end
end
