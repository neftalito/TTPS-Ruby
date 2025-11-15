# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Visitantes
    if user.nil?
      can :read, Product
      return
    end

    # Usuarios logueados
    case user.role.to_sym
    when :admin
      can :manage, :all

    when :manager
      can :manage, Product
      can :manage, Sale

      can :read, User
      can :create, User
      can [:update, :destroy], User, role: %i[employee manager]
      cannot [:create, :update, :destroy], User, role: :admin

    when :employee
      can :manage, Product
      can :manage, Sale
    end

    # todos pueden editar su propia cuenta (excepto rol)
    can [:read, :update], User, id: user.id
  end
end
