# Base for the SaaS-owner platform area. Deliberately inherits from
# ActionController::Base (NOT ApplicationController) so it shares NOTHING with
# the tenant auth/locale stack. Every action runs without a current tenant so
# queries span all tenants.
class Platform::BaseController < ActionController::Base
  include PlatformAuthentication
  include Pagy::Method

  layout "platform"
  allow_browser versions: :modern

  around_action :scope_platform_request

  private

  def scope_platform_request(&block)
    ActsAsTenant.without_tenant do
      I18n.with_locale(platform_locale, &block)
    end
  end

  def platform_locale
    candidate = current_platform_admin&.locale.presence ||
                cookies[:locale].presence ||
                request.env["HTTP_ACCEPT_LANGUAGE"].to_s[/[a-z]{2}/]
    I18n.available_locales.map(&:to_s).include?(candidate) ? candidate : I18n.default_locale
  end
end
