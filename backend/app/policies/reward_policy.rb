class RewardPolicy < ApplicationPolicy
  def index?
    true # customers can also see rewards via API
  end

  def show?
    true
  end
end
