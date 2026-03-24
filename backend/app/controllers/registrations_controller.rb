class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    ActiveRecord::Base.transaction do
      @tenant = Tenant.new(
        name: params[:business_name],
        plan: :free
      )
      unless @tenant.save
        @user = User.new
        flash.now[:alert] = @tenant.errors.full_messages.join(", ")
        return render :new, status: :unprocessable_entity
      end

      ActsAsTenant.with_tenant(@tenant) do
        @user = User.new(
          email_address: params[:email_address],
          password: params[:password],
          first_name: params[:first_name],
          last_name: params[:last_name],
          role: :owner
        )
        unless @user.save
          raise ActiveRecord::Rollback
        end

        Subscription.create!(
          tenant: @tenant,
          status: :active,
          stripe_subscription_id: "sub_free_#{SecureRandom.hex(8)}",
          stripe_price_id: "price_free",
          current_period_end: 100.years.from_now
        )
      end
    end

    if @user&.persisted?
      start_new_session_for @user
      redirect_to admin_root_path, notice: "Welcome! Your business is set up."
    else
      @user ||= User.new
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :new, status: :unprocessable_entity
    end
  end
end
