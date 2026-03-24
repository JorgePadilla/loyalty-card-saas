class Campaign < ApplicationRecord
  acts_as_tenant(:tenant)

  validates :name, presence: true
  validates :multiplier, presence: true, numericality: { greater_than: 0 }
  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :ends_after_starts

  scope :active_now, -> {
    where(active: true)
      .where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current)
  }

  def active_now?
    active? && starts_at <= Time.current && ends_at >= Time.current
  end

  private

  def ends_after_starts
    return unless starts_at && ends_at
    errors.add(:ends_at, "must be after start date") if ends_at <= starts_at
  end
end
