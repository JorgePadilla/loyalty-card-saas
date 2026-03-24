class Api::V1::AuthController < Api::V1::BaseController
  include PlanEnforcement

  skip_before_action :authenticate_api_user!, only: %i[sign_in sign_up refresh]

  def sign_in
    user = User.find_by(email_address: params[:email]&.downcase)
    if user&.authenticate(params[:password])
      tokens = generate_tokens(user)
      render json: {
        user: user_payload(user),
        token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def sign_up
    tenant = Tenant.find_by!(slug: params[:tenant_slug])
    ActsAsTenant.with_tenant(tenant) do
      enforce_customer_limit!

      user = User.new(
        email_address: params[:email],
        password: params[:password],
        first_name: params[:first_name],
        last_name: params[:last_name],
        phone: params[:phone],
        role: :customer
      )
      if user.save
        LoyaltyCard.create!(user: user)
        tokens = generate_tokens(user)
        render json: {
          user: user_payload(user),
          token: tokens[:access_token],
          refresh_token: tokens[:refresh_token]
        }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  rescue PlanEnforcement::PlanLimitExceeded => e
    render json: { error: e.message }, status: :forbidden
  end

  def refresh
    user = User.find_by(refresh_token: params[:refresh_token])
    if user
      tokens = generate_tokens(user)
      render json: {
        token: tokens[:access_token],
        refresh_token: tokens[:refresh_token]
      }
    else
      render json: { error: "Invalid refresh token" }, status: :unauthorized
    end
  end

  private

  def generate_tokens(user)
    access_token = JwtService.encode({ user_id: user.id, tenant_id: user.tenant_id, role: user.role })
    refresh_token = JwtService.generate_refresh_token
    user.update_column(:refresh_token, refresh_token)
    { access_token: access_token, refresh_token: refresh_token }
  end

  def user_payload(user)
    {
      id: user.id,
      email: user.email_address,
      first_name: user.first_name,
      last_name: user.last_name,
      full_name: user.full_name,
      role: user.role,
      tenant_id: user.tenant_id
    }
  end
end
