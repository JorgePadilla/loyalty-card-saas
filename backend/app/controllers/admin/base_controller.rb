class Admin::BaseController < ApplicationController
  include Pundit::Authorization
  include Pagy::Method

  layout "admin"

  before_action :require_staff_role
  before_action :set_tenant
  before_action :ensure_tenant_active
  after_action :verify_authorized

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def require_staff_role
    unless current_user&.staff_or_above?
      redirect_to root_path, alert: t("admin.base.flash.no_admin_access")
    end
  end

  def set_tenant
    ActsAsTenant.current_tenant = current_user&.tenant
  end

  # Block suspended tenants — unless a platform admin is impersonating (support).
  def ensure_tenant_active
    return if cookies.signed[:impersonator_id].present?

    if current_user&.tenant&.suspended?
      terminate_session
      redirect_to new_session_path, alert: t("auth.flash.tenant_suspended")
    end
  end

  def current_user
    Current.session&.user
  end
  helper_method :current_user

  def user_not_authorized
    redirect_back fallback_location: admin_root_path, alert: t("admin.base.flash.not_authorized")
  end
end
