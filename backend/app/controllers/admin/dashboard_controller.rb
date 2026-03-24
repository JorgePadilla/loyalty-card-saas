class Admin::DashboardController < Admin::BaseController
  def show
    @total_customers = User.customers.count
    @visits_today = Visit.today.count
    @points_this_week = PointTransaction.earnings.where(created_at: Time.current.beginning_of_week..Time.current.end_of_week).sum(:points)
    @pending_redemptions = Redemption.pending.count
    @recent_visits = Visit.recent.includes(:user, :staff).limit(10)
    @top_customers = LoyaltyCard.order(total_points: :desc).includes(:user).limit(5)
    @active_campaigns = Campaign.active_now
    @rewards = Reward.active.order(:points_cost)
    @visits_chart_data = Visit.where(checked_in_at: 30.days.ago..Time.current).group_by_day(:checked_in_at).count
  end
end
