class UserPolicy < ApplicationPolicy
  def index?
    user.owner? || user.manager?
  end

  def show?
    user.owner? || user.manager?
  end

  def create?
    user.owner? || user.manager?
  end

  def update?
    user.owner? || user.manager?
  end

  def destroy?
    return false if record == user # can't delete yourself
    user.owner?
  end
end
