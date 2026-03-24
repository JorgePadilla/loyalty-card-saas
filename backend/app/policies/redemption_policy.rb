class RedemptionPolicy < ApplicationPolicy
  def create?
    true # customers can redeem
  end

  def update?
    user.staff_or_above?
  end
end
