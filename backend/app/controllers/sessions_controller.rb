class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  # rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "Try again later." }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: "Try another email address or password."
    end
  rescue => e
    Rails.logger.error "[LOGIN ERROR] #{e.class}: #{e.message}"
    Rails.logger.error e.backtrace&.first(10)&.join("\n")
    raise
  end

  def destroy
    terminate_session
    redirect_to new_session_path
  end

  private

  def after_authentication_url
    url = session.delete(:return_to_after_authenticating)
    return url if url.present?

    user = Current.session&.user
    if user&.staff_or_above?
      admin_root_path
    else
      root_path
    end
  end
end
