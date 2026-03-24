class Admin::BaseController < ApplicationController
  include Pundit::Authorization

  before_action :require_staff_role
  before_action :set_tenant

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def require_staff_role
    unless current_user&.staff_or_above?
      redirect_to root_path, alert: "You don't have access to the admin area."
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
    redirect_back fallback_location: admin_root_path, alert: "You are not authorized to perform this action."
  end
end
