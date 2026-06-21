class Platform::SessionsController < Platform::BaseController
  skip_before_action :require_platform_admin, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_platform_session_url, alert: t("platform.login.rate_limited") }

  def new
  end

  def create
    admin = PlatformAdmin.authenticate_by(
      email_address: params[:email_address].to_s.strip.downcase,
      password: params[:password].to_s
    )
    if admin
      start_new_platform_session_for(admin)
      redirect_to platform_root_path
    else
      flash.now[:alert] = t("platform.login.invalid")
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_platform_session
    redirect_to new_platform_session_path
  end
end
