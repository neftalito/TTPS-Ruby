module UserHelper
  def translated_role(role)
    {
      "employee" => "Empleado",
      "manager" => "Gerente",
      "admin" => "Administrador"
    }[role] || role
  end

  def assignable_roles_for(current_user)
    return [] unless current_user

    if current_user.admin?
      User.roles.keys
    elsif current_user.manager?
      %w[manager employee]
    else
      []
    end
  end
end
