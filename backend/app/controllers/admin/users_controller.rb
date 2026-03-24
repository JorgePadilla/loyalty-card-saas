class Admin::UsersController < Admin::BaseController
  include PlanEnforcement

  before_action :set_user, only: %i[show edit update destroy]

  def index
    @role_filter = params[:role]
    @users = if @role_filter.present?
      User.where(role: @role_filter)
    else
      User.all
    end.order(created_at: :desc)
  end

  def show
    @loyalty_card = @user.loyalty_card
    @recent_visits = @user.visits.recent.limit(10) if @user.customer?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.password = params[:user][:password] if params[:user][:password].present?

    if @user.customer?
      enforce_customer_limit!
    elsif @user.staff_or_above?
      enforce_staff_limit!
    end

    if @user.save
      LoyaltyCard.create!(user: @user) if @user.customer?
      redirect_to admin_users_path, notice: "User created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  rescue PlanEnforcement::PlanLimitExceeded => e
    redirect_to admin_users_path, alert: e.message
  end

  def edit
  end

  def update
    update_params = user_params
    update_params = update_params.except(:password) if update_params[:password].blank?
    if @user.update(update_params)
      redirect_to admin_user_path(@user), notice: "User updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:email_address, :first_name, :last_name, :phone, :role, :password)
  end
end
