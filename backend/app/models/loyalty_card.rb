class LoyaltyCard < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :user
  has_many :point_transactions, dependent: :destroy
  has_many :redemptions, dependent: :destroy

  enum :tier, { bronze: 0, silver: 1, gold: 2 }

  validates :qr_code, presence: true, uniqueness: true
  validates :user_id, uniqueness: { scope: :tenant_id }

  before_validation :generate_qr_code, on: :create

  scope :by_tier, ->(tier) { where(tier: tier) }

  def available_points
    current_points
  end

  def earn_points(amount)
    increment!(:total_points, amount)
    increment!(:current_points, amount)
    check_tier_promotion
  end

  def spend_points(amount)
    raise "Insufficient points" if current_points < amount
    increment!(:redeemed_points, amount)
    decrement!(:current_points, amount)
  end

  def record_visit!
    increment!(:visits_count)
    update!(last_visit_at: Time.current)
    update_streak!
  end

  private

  def generate_qr_code
    self.qr_code ||= SecureRandom.uuid
  end

  def check_tier_promotion
    new_tier = case total_points
               when 0...500 then :bronze
               when 500...2000 then :silver
               else :gold
               end
    update_column(:tier, self.class.tiers[new_tier]) if tier != new_tier.to_s
  end

  def update_streak!
    if last_visit_at.present? && last_visit_at > 7.days.ago
      increment!(:streak_count)
    else
      update_column(:streak_count, 1)
    end
  end
end
