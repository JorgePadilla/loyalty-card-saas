class Visit < ApplicationRecord
  acts_as_tenant(:tenant)

  belongs_to :user
  belongs_to :staff, class_name: "User"

  validates :checked_in_at, presence: true
  validates :points_earned, numericality: { greater_than_or_equal_to: 0 }

  scope :recent, -> { order(checked_in_at: :desc) }
  scope :today, -> { where(checked_in_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :this_week, -> { where(checked_in_at: Time.current.beginning_of_week..Time.current.end_of_week) }

  after_create_commit :broadcast_dashboard_update

  private

  def broadcast_dashboard_update
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard_#{tenant_id}",
      target: "visits_today_stat",
      partial: "shared/stat_card",
      locals: { label: "Visits Today", value: Visit.today.count }
    )
    Turbo::StreamsChannel.broadcast_replace_to(
      "dashboard_#{tenant_id}",
      target: "recent_activity",
      partial: "admin/dashboard/recent_activity",
      locals: { recent_visits: Visit.recent.includes(:user).limit(10) }
    )
  end
end
