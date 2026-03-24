class Admin::RewardsController < Admin::BaseController
  before_action :set_reward, only: %i[show edit update destroy]

  def index
    @rewards = Reward.order(created_at: :desc)
  end

  def show
  end

  def new
    @reward = Reward.new
  end

  def create
    @reward = Reward.new(reward_params)
    if @reward.save
      redirect_to admin_rewards_path, notice: "Reward created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @reward.update(reward_params)
      redirect_to admin_rewards_path, notice: "Reward updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reward.destroy
    redirect_to admin_rewards_path, notice: "Reward deleted."
  end

  private

  def set_reward
    @reward = Reward.find(params[:id])
  end

  def reward_params
    params.require(:reward).permit(:name, :description, :points_cost, :reward_type, :active, :tier_required, :image_url)
  end
end
