class Admin::RewardsController < Admin::BaseController
  before_action :set_reward, only: %i[show edit update destroy]

  def index
    authorize Reward
    @rewards = Reward.order(created_at: :desc)
  end

  def show
    authorize @reward
  end

  def new
    @reward = Reward.new
    authorize @reward
  end

  def create
    @reward = Reward.new(reward_params)
    authorize @reward
    if @reward.save
      redirect_to admin_rewards_path, notice: t("admin.rewards.flash.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @reward
  end

  def update
    authorize @reward
    if @reward.update(reward_params)
      redirect_to admin_rewards_path, notice: t("admin.rewards.flash.updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @reward
    @reward.destroy
    redirect_to admin_rewards_path, notice: t("admin.rewards.flash.deleted")
  end

  private

  def set_reward
    @reward = Reward.find(params[:id])
  end

  def reward_params
    params.require(:reward).permit(:name, :description, :points_cost, :reward_type, :active, :tier_required, :image_url)
  end
end
