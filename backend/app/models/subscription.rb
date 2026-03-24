class Subscription < ApplicationRecord
  acts_as_tenant(:tenant)

  enum :status, { trialing: 0, active: 1, past_due: 2, canceled: 3 }

  validates :status, presence: true

  def active_or_trialing?
    active? || trialing?
  end
end
