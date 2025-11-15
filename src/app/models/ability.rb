# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    # Visitantes no logueados
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

      # Puede ver todos los usuarios
      can :read, User

      # Puede crear usuarios, pero NO administradores
      can :create, User
      cannot :create, User, role: :admin

      # Puede editar/eliminar empleados y managers
      can [:update, :destroy], User, role: %i[employee manager]

      # No puede tocar administradores
      cannot [:update, :destroy], User, role: :admin

    when :employee
      can :manage, Product
      can :manage, Sale

      # No puede gestionar usuarios
      cannot :manage, User
    end

    # Todos pueden ver/editar su propia cuenta (menos el rol)
    can [:update], User, id: user.id
  end
end
