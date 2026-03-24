class PointTransaction < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :loyalty_card
  belongs_to :staff, class_name: "User", optional: true
  belongs_to :visit, optional: true

  enum :kind, { earn: 0, redeem: 1, bonus: 2, referral: 3, adjustment: 4 }

  validates :kind, presence: true
  validates :points, presence: true, numericality: { other_than: 0 }
  validates :description, presence: true

  scope :recent, -> { order(created_at: :desc) }
  scope :earnings, -> { where(kind: [:earn, :bonus, :referral]) }
  scope :spendings, -> { where(kind: :redeem) }
end
