# SaaS-owner account. NOT tenant-scoped — exists outside acts_as_tenant and
# can only be created via the `platform:create_admin` rake task (no web signup).
class PlatformAdmin < ApplicationRecord
  has_secure_password
  has_many :platform_sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  validates :email_address, presence: true, uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true
end
