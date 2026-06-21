class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  attribute :platform_session
  delegate :platform_admin, to: :platform_session, allow_nil: true
end
