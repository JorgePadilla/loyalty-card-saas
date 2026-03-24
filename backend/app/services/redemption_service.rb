class RedemptionService
  Result = Struct.new(:success?, :redemption, :error, keyword_init: true)

  def initialize(loyalty_card:, reward:)
    @loyalty_card = loyalty_card
    @reward = reward
  end

  def call
    return Result.new(success?: false, error: "Reward is not available") unless @reward.active?
    return Result.new(success?: false, error: "Insufficient points") if @loyalty_card.current_points < @reward.points_cost

    if @reward.tier_required.present?
      required_tier_value = LoyaltyCard.tiers[@reward.tier_required]
      current_tier_value = LoyaltyCard.tiers[@loyalty_card.tier]
      return Result.new(success?: false, error: "Tier requirement not met") if current_tier_value < required_tier_value
    end

    ActiveRecord::Base.transaction do
      redemption = Redemption.create!(
        loyalty_card: @loyalty_card,
        reward: @reward,
        points_spent: @reward.points_cost,
        status: :pending
      )

      @loyalty_card.spend_points(@reward.points_cost)

      PointTransaction.create!(
        loyalty_card: @loyalty_card,
        kind: :redeem,
        points: -@reward.points_cost,
        description: "Redeemed: #{@reward.name}"
      )

      Result.new(success?: true, redemption: redemption)
    end
  rescue ActiveRecord::RecordInvalid => e
    Result.new(success?: false, error: e.message)
  end
end
