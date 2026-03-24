class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.staff_or_above?
  end

  def show?
    user.staff_or_above?
  end

  def create?
    user.owner? || user.manager?
  end

  def new?
    create?
  end

  def update?
    user.owner? || user.manager?
  end

  def edit?
    update?
  end

  def destroy?
    user.owner?
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
