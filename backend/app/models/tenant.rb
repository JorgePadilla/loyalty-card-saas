class Tenant < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :loyalty_cards, dependent: :destroy
  has_many :rewards, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :campaigns, dependent: :destroy
  has_many :point_transactions, through: :loyalty_cards
  has_one :subscription, dependent: :destroy

  enum :plan, { free: 0, starter: 1, pro: 2, enterprise: 3 }

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }

  before_validation :generate_slug, on: :create

  def points_per_visit
    settings.fetch("points_per_visit", 10)
  end

  def currency
    settings.fetch("currency", "USD")
  end

  private

  def generate_slug
    self.slug ||= name&.parameterize
  end
end
