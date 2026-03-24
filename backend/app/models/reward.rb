class Reward < ApplicationRecord
  acts_as_tenant(:tenant)

  has_many :redemptions, dependent: :destroy

  enum :reward_type, { free_service: 0, discount_percent: 1, discount_fixed: 2, product: 3 }
  enum :tier_required, { bronze: 0, silver: 1, gold: 2 }, prefix: :requires

  validates :name, presence: true
  validates :points_cost, presence: true, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }
  scope :available_for_tier, ->(tier) {
    active.where("tier_required IS NULL OR tier_required <= ?", tiers[tier] || 0)
  }
end
