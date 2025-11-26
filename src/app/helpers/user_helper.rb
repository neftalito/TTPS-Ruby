module UserHelper
  def translated_role(role)
    {
      "employee" => "Empleado",
      "manager"  => "Gerente",
      "admin"    => "Administrador"
    }[role] || role
  end
end
