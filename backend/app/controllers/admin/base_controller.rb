class Admin::BaseController < ApplicationController
  include Pundit::Authorization
  include Pagy::Method

  layout "admin"

  before_action :require_staff_role
  before_action :set_tenant
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

  def current_user
    Current.session&.user
  end
  helper_method :current_user

  def user_not_authorized
    redirect_back fallback_location: admin_root_path, alert: t("admin.base.flash.not_authorized")
  end
end
