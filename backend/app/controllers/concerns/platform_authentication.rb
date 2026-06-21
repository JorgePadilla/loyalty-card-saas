# Authentication for the SaaS-owner platform area. Fully separate from the
# tenant `Authentication` concern: its own model (PlatformAdmin), its own
# session table (PlatformSession), and a distinct signed cookie
# (`platform_session_id`) so it never overlaps with tenant logins.
module PlatformAuthentication
  extend ActiveSupport::Concern

  included do
    before_action :require_platform_admin
    helper_method :current_platform_admin
  end

  private

  def require_platform_admin
    resume_platform_session || redirect_to(new_platform_session_path)
  end

  def resume_platform_session
    Current.platform_session ||= find_platform_session_by_cookie
  end

  def find_platform_session_by_cookie
    PlatformSession.find_by(id: cookies.signed[:platform_session_id]) if cookies.signed[:platform_session_id]
  end

  def current_platform_admin
    Current.platform_session&.platform_admin
  end

  def start_new_platform_session_for(platform_admin)
    platform_admin.platform_sessions.create!(
      user_agent: request.user_agent, ip_address: request.remote_ip
    ).tap do |session|
      Current.platform_session = session
      cookies.signed.permanent[:platform_session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_platform_session
    Current.platform_session&.destroy
    cookies.delete(:platform_session_id)
  end
end
