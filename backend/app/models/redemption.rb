class Redemption < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :loyalty_card
  belongs_to :reward

  enum :status, { pending: 0, confirmed: 1, expired: 2 }

  validates :points_spent, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }

  after_create_commit :broadcast_pending_count

  private

  def broadcast_pending_count
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard_#{tenant_id}",
      target: "pending_redemptions_stat",
      partial: "shared/stat_card",
      locals: { label: "Pending Redemptions", value: Redemption.pending.count }
    )
  end
end
