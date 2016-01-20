class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Report, user_id: user.id
    end
  end
end
