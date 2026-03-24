class User < ApplicationRecord
  acts_as_tenant(:tenant)

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_one :loyalty_card, dependent: :destroy
  has_many :visits, dependent: :destroy
  has_many :staff_visits, class_name: "Visit", foreign_key: :staff_id, dependent: :nullify

  enum :role, { customer: 0, staff: 1, manager: 2, owner: 3 }

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :role, presence: true

  scope :customers, -> { where(role: :customer) }
  scope :staff_members, -> { where(role: [:staff, :manager, :owner]) }

  def full_name
    [first_name, last_name].compact_blank.join(" ")
  end

  def staff_or_above?
    staff? || manager? || owner?
  end
end
