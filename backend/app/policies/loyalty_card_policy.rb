class LoyaltyCardPolicy < ApplicationPolicy
  def show?
    true # customers can see their own card
  end
end
