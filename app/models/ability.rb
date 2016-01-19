class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Report
    end
  end
end
