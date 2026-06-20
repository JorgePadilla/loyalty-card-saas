class Api::V1::BaseController < ActionController::API
  include Pundit::Authorization

  around_action :switch_api_locale
  before_action :authenticate_api_user!
  before_action :set_tenant

  rescue_from Pundit::NotAuthorizedError, with: :forbidden
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable

  private

  def authenticate_api_user!
    header = request.headers["Authorization"]
    token = header&.split(" ")&.last
    decoded = JwtService.decode(token)
    if decoded
      @current_api_user = User.find_by(id: decoded[:user_id])
      render json: { error: t("api.errors.unauthorized") }, status: :unauthorized unless @current_api_user
    else
      render json: { error: t("api.errors.unauthorized") }, status: :unauthorized
    end
  end

  def current_api_user
    @current_api_user
  end

  def set_tenant
    ActsAsTenant.current_tenant = current_api_user&.tenant
  end

  def render_json(data, status: :ok)
    render json: data, status: status
  end

  def render_error(message, status: :unprocessable_entity)
    render json: { error: message }, status: status
  end

  def forbidden
    render json: { error: t("api.errors.forbidden") }, status: :forbidden
  end

  def not_found
    render json: { error: t("api.errors.not_found") }, status: :not_found
  end

  def unprocessable(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end

  # Locale for API responses, from the client's Accept-Language header
  # (the mobile app sends its current language). Leak-safe via with_locale.
  def switch_api_locale(&action)
    I18n.with_locale(api_locale, &action)
  end

  def api_locale
    code = request.headers["Accept-Language"].to_s.split(",").first.to_s.split("-").first.strip.downcase
    I18n.available_locales.map(&:to_s).include?(code) ? code : I18n.default_locale
  end
end
